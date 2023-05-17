
src=`cd $(dirname $0); pwd -P`
#echo "$src"
pipline=$(basename $0)
LRname="LR"
minclip_num=2
minbkrate=0.4
LRavg_depth=100
x="map-pb";
t=5


for com in perl samtools minimap2 
do
        mg=$(command -v $com)
        if [ "$mg" == "" ]
        then
                echo -e "\n\tError: Command $com is NOT in you PATH. Please check.\n"
                exit 1
        fi
done


Usage="\nUsage:\n\t$pipline -g  Genome.fasta -z  Genome.fasta.size -1  SMS_sorted.bam -m minclip_num -f minbkrate\nor\t$pipline -g  Genome.fasta -z  Genome.fasta.size -1 SMS.fa.gz -x map-pb -m minclip_num -f minbkrate -a 100"

while getopts "a:g:x:z:1:m:f:t:" opt
do
    case $opt in
        g)      ref_fa=$OPTARG ;;
        z)      ref_fa_size=$OPTARG;;
        1)      inquery=$OPTARG;;
	m)	minclip_num=$OPTARG;;
	a)	LRavg_depth=$OPTARG;;
	f)	minbkrate=$OPTARG;;
	t)      t=$OPTARG;;
	x)	x=$OPTARG;;
        ?)
        echo ":| WARNING: Unknown option. Ignoring: Exiting!"
        exit 1;;
    esac
done

 if [ ! -e "$ref_fa" ]
then
       echo -e "\n\tgenome.fa is not found,  please check the README.md for the requirements of input files!\n\t$Usage \n"
       exit 1
fi

if [ ! -e "$ref_fa_size" ]
then
       echo -e "\n\tGenome.fasta.size is not found,  please check the README.md for the requirements of input files!\n\t$Usage \n"
       exit 1
fi

if [ `echo "$minclip_num < 1"|bc` -eq 1 ] ; then
        echo -e "\n\t  minclip_num ERROR: $minclip_num  Exit !"
        exit 1
fi

if [ `echo "$minbkrate < 0"|bc` -eq 1 ] ; then
        echo -e "\n\t min_bkrate ERROR: $minbkrate  Exit !"
        exit 1
fi


if [ `echo "$t <= 0"|bc` -eq 1 ] ; then
        echo -e "\n\tthread ERROR: $t  Exit !"
        exit 1
fi

if [ -d "LRout" ];then
   echo -e "Error::  LRout already exists, Exit !"	
	exit 1
fi
mkdir LRout
#echo "$inquery"
inquery_tmp=$(echo $inquery | tr [A-Z] [a-z])
if [[ "$inquery_tmp" =~ (fa$)|(fq$)|(fasta$)|(fastq$)|(fa.gz$)|(fq.gz$)|(fasta.gz$)|(fastq.gz$)|(bam$) ]]; then
        echo "worker_pipeline::"

     if [[ "$inquery" =~ (bam$) ]];then
		echo "Skipping alignment::"
                if [ ! -e "$inquery" ];then
                echo -e "\n\t $inquery is not found,  please check the README.md for the requirements of input files!\n\t$Usage \n"
                exit 1
                fi
                if [ ! -e $inquery".bai" ];then
                echo -e "\n\t $inquery".bai" is not found, cannot read index for $inquery \n\t$Usage \n"
                exit 1
                fi

     input_bam=$inquery
     echo -e "[M::worker_pipeline:: Filtering bamfiles]"
     samtools view -h -q 20 -F 1796 -@ $t $input_bam |  perl $src/sam_cigar_filter.pl - | samtools view -h -S -b -@ $t -  -o LRout/$LRname"_sort.bam"
     samtools index LRout/$LRname"_sort.bam"
     fi

     if [[ "$inquery_tmp" =~ (fa$)|(fq$)|(fasta$)|(fastq$)|(fa.gz$)|(fq.gz$)|(fasta.gz$)|(fastq.gz$) ]]; then
	mkdir  -p LRout/tmp_bam
	array=(${inquery//,/ })   
	for query in ${array[@]}
         	do
		if [ ! -e "$query" ];then
        	echo -e "\n\t $query is not found,  please check the README.md for the requirements of input files!\n\t$Usage \n"
        	exit 1
		fi
	       done
	 for query in ${array[@]}
 	        do
	 	minimap2 -ax $x -R "@RG\tID:foo\tSM:bar1\tLB:lib" $ref_fa  $query -t $t | samtools view -h  -S -b -@ $t -  -o LRout/tmp_bam/$query"_unsort.bam"
        	samtools sort LRout/tmp_bam/$query"_unsort.bam"  -@ $t -o LRout/tmp_bam/$query"_sort.bam"
        	samtools index LRout/tmp_bam/$query"_sort.bam"
		rm LRout/tmp_bam/$query"_unsort.bam"
		done

      	 echo -e "[M::worker_pipeline:: Merge bamfiles]"
       	 samtools merge -@ $t -f LRout/tmp_bam/tmp_lr_merge.bam  LRout/tmp_bam/*_sort.bam 
	 rm  LRout/tmp_bam/*_sort.bam*
       	 input_bam="LRout/tmp_bam/tmp_lr_merge.bam"
       	 echo -e "[M::worker_pipeline:: Filtering bamfiles]"
         samtools view -h -q 20 -F 1796  $input_bam -@ $t | perl $src/sam_cigar_filter.pl - | samtools view -h -S -b -@ $t -  -o LRout/$LRname"_sort.bam"
         samtools index LRout/$LRname"_sort.bam"
	rm -r LRout/tmp_bam/
     fi	 
     
     else
     echo -e "Error, query should be fasta, fq or a sorted.bam  \n!"
     exit 1
fi


echo -e "[M::worker_pipeline:: Get SMS mapping coverage]"
	samtools depth -a  LRout/$LRname"_sort.bam"  > LRout/$LRname"_sort.depth" 
echo -e "[M::worker_pipeline:: Compute effective coverage]"
perl $src/SReffect_size.pl LRout/$LRname"_sort.depth" >LRout/$LRname"_eff.size"


echo -e "[M::worker_pipeline:: Extract SMS clipping signal]"
samtools view  LRout/$LRname"_sort.bam"  -@ $t |   perl   $src/caculate_breakpoint_depth.pl    -  > LRout/$LRname"_clipped.cov"

echo -e "[M::worker_pipeline:: Collect potential LER]"
	perl -alne  'print if($F[3]>='$minclip_num')' LRout/$LRname"_clipped.cov" >LRout/$LRname"_clipped.cov.tmp"
	perl   $src/synthesize_LRbkdep_and_alldep_theory1.pl LRout/$LRname"_clipped.cov.tmp"  LRout/$LRname"_sort.depth"  >LRout/$LRname"_clip.coverRate"
	perl -alne  'print if($F[4]< 2*'$LRavg_depth' && $F[3]>='$minclip_num' && $F[3]/$F[4]>'$minbkrate')' LRout/$LRname"_clip.coverRate" >LRout/$LRname"_clip.coverRate.filter"
   	perl $src/LER_softclip_filter.pl LRout/$LRname"_clipped.cov"   LRout/$LRname"_clip.coverRate.filter" >LRout/$LRname"_clip.coverRate.softclip.tmp"
	perl -alne  'print if($F[5]<0.1)' LRout/$LRname"_clip.coverRate.softclip.tmp" |cut  -f -5 >LRout/$LRname"_putative.ER.HR"

rm LRout/$LRname"_clipped.cov.tmp" 

#echo -e "\n##########################################################################################\n"
echo -e "LR clipping analysis completed. Check current directory LRout for final results!\n"
