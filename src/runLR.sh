
src=`cd $(dirname $0); pwd -P`
#echo "$src"
pipline=$(basename $0)
LRname="LR"
minclip_num=2
lhe_cutoff_left=0.4
lhe_cutoff_right=0.6
lrbk_cutoff=0.65
LRavg_depth=100
max_depratio=0.05
mapquality=20
minindel=20
next_clip_dis=50000
x="map-hifi";
t=5
report_SNV="F"

for com in perl samtools minimap2 
do
        mg=$(command -v $com)
        if [ "$mg" == "" ]
        then
                echo -e "\n\tError: Command $com is NOT in you PATH. Please check.\n"
                exit 1
        fi
done


Usage="\nUsage:\n\t$pipline -g  Genome.fa -z  Genome.fa.size -1 SMS_sorted.bam -m minclip_num -q mapq -f lhe_cutoff_left -h lhe_cutoff_right -r lrbk_cutoff \nor\t$pipline -g  Genome.fasta -z  Genome.fasta.size -1 SMS.fa.gz -x map-hifi -m minclip_num -q mapq -f lhe_cutoff_left -h lhe_cutoff_right -r lrbk_cutoff -n max_depratio"

while getopts "a:g:x:z:1:d:m:q:f:h:d:r:t:v:" opt
do
    case $opt in
        g)      ref_fa=$OPTARG ;;
        z)      ref_fa_size=$OPTARG;;
        1)      inquery=$OPTARG;;
	m)	minclip_num=$OPTARG;;
	a)	LRavg_depth=$OPTARG;;
	d)	next_clip_dis=$OPTARG;;
	f)	lhe_cutoff_left=$OPTARG;;
	h)	lhe_cutoff_right=$OPTARG;;
	r)	lrbk_cutoff=$OPTARG;;	
	q)	mapquality=$OPTARG;;
	n)	max_depratio=$OPTARG;;
	v)	report_SNV=$OPTARG;;
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

if [ `echo "$lhe_cutoff_left < 0"|bc` -eq 1 ] ; then
        echo -e "\n\t min_bkrate ERROR: $lhe_cutoff_left  Exit !"
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
                #if [ ! -e $inquery".bai" ];then
                #echo -e "\n\t $inquery".bai" is not found, cannot read index for $inquery \n\t$Usage \n"
                #exit 1
                #fi

     input_bam=$inquery
     echo -e "[M::worker_pipeline:: Filtering bamfiles]"
     #samtools view -@ $t $input_bam | perl $src/seqid.pl - >LRout/LR_raw.id
     samtools view -h -q $mapquality -F 1796 -@ $t $input_bam |  perl $src/lrsam_cigar_filter.pl - | samtools view -h -S -b -@ $t -  -o LRout/$LRname"_sort.bam"
     #samtools index LRout/$LRname"_sort.bam"
     #samtools view -@ $t LRout/$LRname"_sort.bam" | perl $src/seqid.pl - >LRout/LR_filterd.id

     
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
        	#samtools index LRout/tmp_bam/$query"_sort.bam"
		rm LRout/tmp_bam/$query"_unsort.bam"

		mv LRout/tmp_bam/$query"_sort.bam" LRout/tmp_bam/tmp_lr_merge.bam

		done

      	# echo -e "[M::worker_pipeline:: Merge bamfiles]"
       	# samtools merge -@ $t -f LRout/tmp_bam/tmp_lr_merge.bam  LRout/tmp_bam/*_sort.bam 
	#rm  LRout/tmp_bam/*_sort.bam*
       	 
	 input_bam="LRout/tmp_bam/tmp_lr_merge.bam"
         #samtools view $input_bam -@ $t | perl $src/seqid.pl - >LRout/LR_raw.id 
	 
	 echo -e "[M::worker_pipeline:: Filtering bamfiles]"
         samtools view -h -q $mapquality -F 1796  $input_bam -@ $t | perl $src/lrsam_cigar_filter.pl - | samtools view -h -S -b -@ $t -  -o LRout/$LRname"_sort.bam"
         #samtools index LRout/$LRname"_sort.bam"
	 #samtools view LRout/$LRname"_sort.bam" -@ $t |perl $src/seqid.pl - >LRout/LR_filterd.id
	rm -r LRout/tmp_bam/
     fi	 
     
     else
     echo -e "Error, query should be fasta, fq or a sorted.bam  \n!"
     exit 1
fi


echo -e "[M::worker_pipeline:: Compute effective SMS coverage]"
	samtools depth -a  LRout/$LRname"_sort.bam" | perl $src/avgdep.pl LRout seq.size - > LRout/$LRname"_sort.depth" 
        LRavg_depth=$(cat LRout/Avgcov)
echo -e "[M::SMS mapping coverage: $LRavg_depth]"
	rm LRout/Avgcov

	perl $src/LReffect_size.pl LRout/$LRname"_sort.depth" $LRavg_depth $max_depratio >LRout/$LRname"_eff.size"

echo -e "[M::worker_pipeline:: Extract SMS clipping signal]"
	samtools view  LRout/$LRname"_sort.bam"  -@ $t | perl   $src/splitBam_by_chrid.pl -
	for i in LRout/*sam; do
	  perl $src/caculate_breakpoint_depth.pl $i |perl $src/LR_clipped_cov_motify.pl -  >> LRout/$LRname"_clipped.cov"
	done
#samtools view  LRout/$LRname"_sort.bam"  -@ $t |   perl   $src/caculate_breakpoint_depth.pl - |perl $src/LR_clipped_cov_motify.pl -  > LRout/$LRname"_clipped.cov"

echo -e "[M::worker_pipeline:: Collect potential CSE|H]"
	perl -alne  'print if($F[3]>='$minclip_num')' LRout/$LRname"_clipped.cov" >LRout/$LRname"_clipped.cov.tmp"
	perl   $src/synthesize_LRbkdep_and_alldep.pl LRout/$LRname"_clipped.cov.tmp"  LRout/$LRname"_sort.depth"  >LRout/$LRname"_clip.coverRate"
	perl -alne  'print if($F[4]< 3*'$LRavg_depth' && $F[3]>='$minclip_num' && $F[3]/$F[4]>'$lhe_cutoff_left')' LRout/$LRname"_clip.coverRate" >LRout/$LRname"_clip.coverRate.filter"

#get putative.HR
	perl -alne 'print if($F[3]/$F[4]<='$lhe_cutoff_right'  )' LRout/$LRname"_clip.coverRate.filter" >LRout/$LRname"_clip.coverRate.filter.SH"
        perl $src/LER_softclip_filter.pl LRout/$LRname"_clipped.cov"  LRout/$LRname"_clip.coverRate.filter.SH" $next_clip_dis >LRout/$LRname"_putative.SH.tmp"
        perl -alne  'print if($F[5]>0.5)' LRout/$LRname"_putative.SH.tmp" |cut  -f -5 >LRout/$LRname"_putative.SH"

#get putative.ER
        perl -alne 'print if($F[3]/$F[4]>='$lrbk_cutoff'  )' LRout/$LRname"_clip.coverRate.filter" >LRout/$LRname"_clip.coverRate.filter.SE"
        perl $src/LER_softclip_filter.pl LRout/$LRname"_clipped.cov"  LRout/$LRname"_clip.coverRate.filter.SE" $next_clip_dis >LRout/$LRname"_putative.SE.tmp"
        perl -alne  'print if($F[5]<0.1)' LRout/$LRname"_putative.SE.tmp" |cut  -f -5 > LRout/$LRname"_putative.SE"

cat LRout/$LRname"_putative.SE" LRout/$LRname"_putative.SH" >LRout/$LRname"_putative.SE.SH"
rm LRout/*tmp  LRout/LR_clip.coverRate.filter.S*

echo -e "[M::worker_pipeline:: Collect potential CRE|H]"

if [ "$report_SNV" != "T" ] ; then
	for j in LRout/*sam; do  
		perl $src/caculate_clipDI_cov.pl $j 3 >>LRout/$LRname"_DI.cov.dimin3.tmp"
	 done

#	samtools view  LRout/$LRname"_sort.bam" -@ $t|perl $src/caculate_clipDI_cov.pl - 3 >LRout/$LRname"_DI.cov.dimin3.tmp"
        perl $src/synthesize_clipDIcov_and_alldep.pl LRout/$LRname"_DI.cov.dimin3.tmp" LRout/$LRname"_sort.depth" >LRout/$LRname"_DI.cov.dimin3.tmp.dep" 
	perl -alne  'print if($F[5]>='$minindel')' LRout/$LRname"_DI.cov.dimin3.tmp.dep" > LRout/$LRname"_DI.covRate.filter.R"
fi

if [ "$report_SNV" == "T" ] ; then
	for j in LRout/*sam; do
                perl $src/caculate_clipDI_cov.pl $j 1 >>LRout/$LRname"_DI.cov"
         done
       #samtools view  LRout/$LRname"_sort.bam"  -@ $t | perl $src/caculate_clipDI_cov.pl  - 1 > LRout/$LRname"_DI.cov"
        perl $src/synthesize_clipDIcov_and_alldep.pl LRout/$LRname"_DI.cov" LRout/$LRname"_sort.depth" >LRout/$LRname"_DI.covRate.filter.all"
	perl -alne 'print if($F[5]>= '$minindel')' LRout/$LRname"_DI.covRate.filter.all" >LRout/$LRname"_DI.covRate.filter.R"

	perl -alne 'print if($F[5] < '$minindel')' LRout/$LRname"_DI.covRate.filter.all" >LRout/$LRname"_DI.covRate.filter.SNV"
        perl -alne  '$a=$F[3]/$F[4]; print if($a >=0.9 && $F[7]>0.7  )' LRout/$LRname"_DI.covRate.filter.SNV" |perl -alne 'print "$F[0]\t$F[1]\t$F[3]\t$F[4]\t$F[5]$F[6]"' >LRout/out_final_indel.err
        perl -alne  '$a=$F[3]/$F[4]; print if($a >='$lhe_cutoff_left' && $a <='$lhe_cutoff_right' &&  $F[7]>0.7  )' LRout/$LRname"_DI.covRate.filter.SNV" |perl -alne 'print "$F[0]\t$F[1]\t$F[3]\t$F[4]\t$F[5]$F[6]"' >LRout/out_final_indel.het
	
	perl -alne  'print if($F[5]>=3)' LRout/$LRname"_DI.covRate.filter.all" >LRout/$LRname"_DI.cov.dimin3.tmp.dep"
	rm LRout/$LRname"_DI.covRate.filter.all" 
fi
        rm LRout/*.sam 

#echo -e "\n##########################################################################################\n"
echo -e "SMS data analysis completed. Check current directory LRout for final results!\n"
