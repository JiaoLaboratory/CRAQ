
src=`cd $(dirname $0); pwd -P`
SRname="SR"

she_cutoff_left=0.25
she_cutoff_right=0.6
srbk_cutoff=0.75

SRavg_depth=100
mapquality=20
t=5
minclip_num=2

pipline=$(basename $0)

for com in perl minimap2 samtools 
do
        mg=$(command -v $com)
        if [ "$mg" == "" ]
        then
                echo -e "\n\tError: Command $com is NOT in you PATH. Please check.\n"
                exit 1
        fi
done


Usage="\nUsage:\n\t$pipline -g  Genome.fa  -z Genome.fa.size  -1 NGS_sort.bam \n or \t$pipline -g  Genome.fa  -z Genome.fa.size  -1 fq1.gz -2 fq2.gz -f she_cutoff_left -h she_cutoff_right -r srbk_cutoff \n\t[default: -q 20 -f 0.4 -h 0.6 -r 0.75 -m 2 -a 100 -t 5]"

while getopts "g:z:1:2:q:f:h:r:m:a:t:" opt
do
    case $opt in
        g)	ref_fa=$OPTARG ;;
        z)	ref_fa_size=$OPTARG ;;
        1)	query_1=$OPTARG ;;
        2)	query_2=$OPTARG ;;
	q)	mapquality=$OPTARG ;;
	m)	minclip_num=$OPTARG ;;
	f)	she_cutoff_left=$OPTARG ;;
	h)	she_cutoff_right=$OPTARG ;;
	r)	srbk_cutoff=$OPTARG ;;
	a)	SRavg_depth=$OPTARG ;;
        t)	t=$OPTARG ;;
        ?)
        echo ":| WARNING: Unknown option. Ignoring: Exiting!"
        exit 1;;
    esac
done


if [ ! -e "$ref_fa" ];then
        echo -e "\n\tgenome.fa is not found,  please check the README.md for the requirements of input files!\n\t$Usage \n"
        exit 1
        fi

if [ ! -e "$ref_fa_size" ]
then
       echo -e "\n\tGenome.fasta.size is not found,  please check the README.md for the requirements of input files!\n\t$Usage \n" 
       exit 1
fi
if [ `echo "$minclip_num < 0"|bc` -eq 1 ] ; then
        echo -e "\n\tminclip_num ERROR: $minclip_num  Exit !"
        exit 1
fi


if [ `echo "$t <= 0"|bc` -eq 1 ] ; then
        echo -e "\n\tthread ERROR: $t  Exit !"
        exit 1
fi

if [ `echo "$she_cutoff_left < 0"|bc` -eq 1 ] ; then
        echo -e "\n\tshe_cutoff_left ERROR: $she_cutoff_left  Exit !"
        exit 1
fi

query_1_tmp=$(echo $query_1 | tr [A-Z] [a-z])
query_2_tmp=$(echo $query_2 | tr [A-Z] [a-z])
if [[ "$query_1_tmp" =~ (fa$)|(fq$)|(fasta$)|(fastq$)|(fa.gz$)|(fq.gz$)|(fasta.gz$)|(fastq.gz$)|(bam$) ]]; then
	if [ -d "SRout" ];then
        echo -e "Error::  SRout already exists, Exit !"
        exit 1
        fi
        mkdir SRout
	if [[ "$query_1_tmp" =~ (bam$) ]];then
		if [ ! -e "$query_1" ];then
		echo -e "\n\t $query_1 is not found,  please check the README.md for the requirements of input files!\n\t$Usage \n"
                exit 1
                fi
                #if [ ! -e $query_1".bai" ];then
                #echo -e "\n\t $query_1".bai" is not found, cannot read index for $query_1 \n\t$Usage \n"
                #exit 1
                #fi

	        input_bam=$query_1
		echo -e "Skipping alignment::\n[M::worker_pipeline:: Filtering bamfiles]"
	samtools view -h  -F 1796  $input_bam  -t $t | perl $src/srsam_cigar_filter.pl $mapquality - | samtools view -h -S -b -@ $t -  -o SRout/$SRname"_sort.bam"
		samtools index SRout/$SRname"_sort.bam"
	fi
	
	if [[ "$query_1_tmp" =~ (fa$)|(fq$)|(fasta$)|(fastq$)|(fa.gz$)|(fq.gz$)|(fasta.gz$)|(fastq.gz$) ]]; then
		if [ ! -e "$query_1" ];then
                echo -e "\n\t $query_1 is not found,  please check the README.md for the requirements of input files!\n\t$Usage \n"
                exit 1
                fi
		if [ ! -e "$query_2" ];then
                echo -e "worker_pipeline::\nWARNING: Short pair_end read pair_2 is not found, only $query_1 used"
                fi
		if [[  -e "$query_2"   ]];then
			if [[ "$query_2_tmp" =~  (fa$)|(fq$)|(fasta$)|(fastq$)|(fa.gz$)|(fq.gz$)|(fasta.gz$)|(fastq.gz$) ]]; then
			echo -e "worker_pipeline::"
			else 
               		echo -e "\n\t $query_2 should be fastq/fa suffix,  please check the README.md for the requirements of input files!\n\t$Usage \n"
			exit 1
			fi	
                fi

	        echo -e "worker_pipeline:: NGS reads aligning and filtering"
                minimap2 -ax sr -R "@RG\tID:foo\tSM:bar1\tLB:lib" $ref_fa  $query_1 $query_2  -t $t | perl  $src/srsam_cigar_filter.pl $mapquality -  | samtools view -h -F 1796 -S -b -@ $t -  -o SRout/$SRname"_unsort.bam"

		echo -e "[M::worker_pipeline:: Sort bamfiles]"
      		samtools sort SRout/$SRname"_unsort.bam"   -@ $t -o SRout/$SRname"_sort.bam" 
      		rm SRout/$SRname"_unsort.bam" && samtools index SRout/$SRname"_sort.bam" 
	fi
else
     echo -e "Error, query should be fasta, fq or a sorted.bam  \n!"
     exit 1
fi
#echo -e "\n##########################################################################################\n"
echo -e "[M::worker_pipeline:: Compute effective NGS coverage]"
#-------------------------------------------------------------------------------------------------------------
#samtools depth -a  SRout/$SRname"_sort.bam"  > SRout/$SRname"_sort.depth" 
samtools view -h -@ $t -q $mapquality SRout/$SRname"_sort.bam" |samtools depth -a - >SRout/$SRname"_sort.depth"

perl $src/SReffect_size.pl SRout/$SRname"_sort.depth" >SRout/$SRname"_eff.size"
#echo -e "\n##########################################################################################\n"
#echo -e "[M::worker_pipeline:: Get clipping cover rate]"
#-------------------------------------------------------------------------------------------------------------
if (($minclip_num >=1)); then
     echo -e "[M::worker_pipeline:: Collect potential CRE|H]"
        samtools view -@ $t -q $mapquality SRout/$SRname"_sort.bam" | perl $src/caculate_breakpoint_depth.pl -  > SRout/$SRname"_clipped.cov"
        perl -alne  'print if($F[3]>='$minclip_num')' SRout/$SRname"_clipped.cov" >SRout/$SRname"_clipped.cov.tmp"
	perl   $src/synthesize_SRbkdep_and_alldep.pl  SRout/$SRname"_clipped.cov.tmp" SRout/$SRname"_sort.depth" >SRout/$SRname"_clip.coverRate" 
        perl -alne  'print if($F[3]>='$minclip_num' && $F[4]>=1 && $F[4] < 2*'$SRavg_depth' && $F[3]/$F[4] >'$she_cutoff_left')' SRout/$SRname"_clip.coverRate" > SRout/$SRname"_clip.coverRate.tmp"
#get putative.SHR
	perl -alne  'print if( $F[3]/$F[4] <= '$she_cutoff_right' )' SRout/$SRname"_clip.coverRate.tmp" >SRout/$SRname"_putative.RH"
#get putative.SER
	perl -alne  'print if( $F[3]/$F[4] >= '$srbk_cutoff' )' SRout/$SRname"_clip.coverRate.tmp" >SRout/$SRname"_putative.RE"
	cat SRout/$SRname"_putative.RH" SRout/$SRname"_putative.RE" >SRout/$SRname"_putative.RE.RH"
	rm SRout/$SRname"_clipped.cov.tmp" SRout/$SRname"_clip.coverRate.tmp"

fi

if (($minclip_num == 0)); then
     echo -e "[M::worker_pipeline:: Collect potential CRE|RH]"
#######start extract clipped reads
     samtools view -@ $t -q $mapquality SRout/$SRname"_sort.bam" | perl $src/caculate_breakpoint_depth.pl  -  > SRout/$SRname"_clipped.cov"
     perl -alne  'print if($F[3]>=2)' SRout/$SRname"_clipped.cov" >SRout/$SRname"_clipped.cov.tmp"
     perl   $src/synthesize_SRbkdep_and_alldep.pl  SRout/$SRname"_clipped.cov.tmp" SRout/$SRname"_sort.depth" >SRout/$SRname"_clip.coverRate"
     perl -alne  'print if($F[3]>=2 && $F[4]>=1 && $F[4] < 2*'$SRavg_depth' && $F[3]/$F[4] >'$she_cutoff_left' )' SRout/$SRname"_clip.coverRate" >SRout/$SRname"_putative.RE.bk.tmp"
#     rm SRout/$SRname"_clipped.cov.tmp"
#######finish extract clipped reads

     perl $src/search_dep0.pl SRout/$SRname"_sort.depth" >SRout/$SRname"_putative.RE.0.tmp"
     perl $src/srbk_merge_srnoncov.pl SRout/$SRname"_putative.RE.bk.tmp" SRout/$SRname"_putative.RE.0.tmp" |sort -k 1,1 -k 2,2n >SRout/$SRname"_putative.RE.RH"
     rm SRout/$SRname"_putative.RE.0.tmp" SRout/$SRname"_putative.RE.bk.tmp"

fi

#echo -e "\n##########################################################################################\n"
echo -e "SR clipping analysis completed. Check current directory SRout for final results!"
