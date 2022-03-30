src=`cd $(dirname $0); pwd -P`
pipline=$(basename $0)
Usage="\nUsage:\n\t#Genome assessing using AQI:\n\t$pipline -g  Genome.fasta -z  Genome.fasta.size -e SRout/SR_eff.size  -c SRout/SR_putative.ER -C LRout/LR_putative.ER  -d SRout/SR_sort.depth  -D LRout/LR_sort.depth  [default: -f 0.1 -w 50000 -n 10 -j 1 -b F ]"

name="out"
skewned_rate=0.1
LRmax_depth=1000
min_gap_len=10
gapmodel=1
breakmj=F
mincontigsize=50000
norm_window=50000
regional_window=50000
window_strER=50000

while getopts "s:g:z:e:c:d:C:D:f:e:n:w:m:j:b:o" opt
do
    case $opt in
        g)      ref_fa=$OPTARG ;;
        z)      ref_fa_size=$OPTARG;;
        e)      Eff_size=$OPTARG;;
        c)      SR_coverRate=$OPTARG;;
        C)      LR_coverRate=$OPTARG;;
	d)      SR_normdep=$OPTARG;;
        D)      LR_normdep=$OPTARG;;
	f)      skewned_rate=$OPTARG;;
	n)	min_gap_len=$OPTARG;;
	s)	norm_window=$OPTARG;;
	w)	regional_window=$OPTARG;;
	m)	mincontigsize=$OPTARG;;
	j)	gapmodel=$OPTARG;;
	b)	breakmj=$OPTARG;;
	o)      name=$OPTARG;;
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

if [ ! -e "$Eff_size" ]
then
       echo -e "\n\teffect_size_file is not found,  please check the README.md for the requirements of input files!\n\t$Usage \n"
       exit 1
fi

if [ ! -e "$SR_normdep" ]
then
       echo -e "\n\tShort reads depthfile is not found,  please check the README.md for the requirements of input files!\n\t$Usage \n"
       exit 1
fi

if [ ! -e "$LR_normdep" ]
then
       echo -e "\n\tLong reads depthfile is not found,  please check the README.md for the requirements of input files!\n\t$Usage \n"
       exit 1
fi

if [ ! -e "$SR_coverRate" ]
then
       echo -e "\n\tSR_putative.ER not found,  please check the README.md for the requirements of input files!\n\t$Usage \n"
       exit 1
fi

if [ ! -e "$LR_coverRate" ]
then
       echo -e "\n\tLR_putative.ER not found,  please check the README.md for the requirements of input files!\n\t$Usage \n"
       exit 1
fi


if [ `echo "$skewned_rate < 0"|bc` -eq 1 ] ; then
        echo -e "\n\t$skewned_rate ERROR: $skewned_rate not in (0,1), default 0.1  Exit !"
        exit 1
fi

#echo -e "Local collapsed cutoff : $skewned_rate"

mkdir -p runAQI_out/Gap_out  runAQI_out/locER_out  runAQI_out/strER_out 

###echo -e "[M::worker_pipeline:: Get Genomic Gap]"
perl $src/getGap.pl  $ref_fa | perl $src/gap_filter.pl - $ref_fa_size $min_gap_len  >runAQI_out/Gap_out/$name"_gap.out"

echo -e "[M::worker_pipeline:: Filter putative SER]"
perl $src/get_ER.pl $LR_normdep  $SR_coverRate  10 20 $skewned_rate  >runAQI_out/locER_out/$name"_lrfilter_SER.out"

if [[ $gapmodel == 2 ]];then

perl -alne  '{print "$F[0]\t1\t1\tGap\n$F[0]\t$F[1]\t$F[1]\tGap"}' $ref_fa_size > runAQI_out/locER_out/tmp.size
perl $src/merge_gap_ER.pl   runAQI_out/locER_out/tmp.size  runAQI_out/locER_out/$name"_lrfilter_SER.out" >runAQI_out/locER_out/$name"_SER.merge.tmp"
#rm runAQI_out/locER_out/tmp.size
else
perl $src/merge_gap_ER.pl   runAQI_out/Gap_out/$name"_gap.out"  runAQI_out/locER_out/$name"_lrfilter_SER.out" >runAQI_out/locER_out/$name"_SER.merge.tmp"
fi


perl -alne 'print "$F[0]\t$F[1]\tSER"' runAQI_out/locER_out/$name"_SER.merge.tmp" >runAQI_out/locER_out/$name"_final.SER.out.tmp"

#####################################################################
echo -e "[M::worker_pipeline:: Filter putative LER]"
perl $src/lrbk_have_srbk.pl $SR_coverRate   $LR_coverRate 500    >runAQI_out/strER_out/$name"_LER_overlap_srbk.out" 
perl $src/LRcoverRate_srdep_filter.pl $SR_normdep $LR_coverRate  >  runAQI_out/strER_out/$name"_LER_overlap_srdep0.out"
cat runAQI_out/strER_out/$name"_LER_overlap_srbk.out" runAQI_out/strER_out/$name"_LER_overlap_srdep0.out" |sort -k 1,1 -k 2,2n |uniq >runAQI_out/strER_out/$name"_srfilter_LER.out"

perl $src/merge_misjunction_gap.pl runAQI_out/strER_out/$name"_srfilter_LER.out"  runAQI_out/Gap_out/$name"_gap.out" >runAQI_out/strER_out/$name"_havegap_srfilter_ER.tmp"

perl $src/search_Misjunction.pl   -a $LRmax_depth -w $window_strER -m $mincontigsize   -z $ref_fa_size -j $gapmodel  -i runAQI_out/strER_out/$name"_havegap_srfilter_ER.tmp" >runAQI_out/strER_out/$name"_merge.strER.out.tmp"
perl $src/filter_endLER.pl $ref_fa_size runAQI_out/strER_out/$name"_merge.strER.out.tmp" 2000 >runAQI_out/strER_out/$name"_strER.merge.tmp"

perl -alne 'print "$F[0]\t$F[1]\tLER"' runAQI_out/strER_out/$name"_strER.merge.tmp" >runAQI_out/strER_out/$name"_final.LER.out"

rm runAQI_out/strER_out/$name"_merge.strER.out.tmp" runAQI_out/strER_out/$name"_LER_overlap_srdep0.out" runAQI_out/strER_out/$name"_LER_overlap_srbk.out"
if [ "$breakmj" == "T" ] ; then
	echo -e "[M::worker_pipeline:: Break at Misjunct]"
perl $src/break_at_Misjunction.pl $ref_fa runAQI_out/strER_out/$name"_final.LER.out"  >runAQI_out/out_correct.fa
fi


rm -rf runAQI_out/strER_out/$name"_havegap_srfilter_ER.tmp"
perl $src/srbk_rm_lrbk.pl runAQI_out/strER_out/$name"_final.LER.out" runAQI_out/locER_out/$name"_final.SER.out.tmp" 500 >runAQI_out/locER_out/$name"_final.SER.out"
rm -rf runAQI_out/locER_out/$name"_final.SER.out.tmp" 

#Quality Benchmarking
########################################################################
echo -e "[M::worker_pipeline:: Quality benchmarking"

cat runAQI_out/locER_out/$name"_final.SER.out"  runAQI_out/strER_out/$name"_final.LER.out"  >runAQI_out/tmp_merged.loc.str.ER
perl $src/get_ER_junctionstat_window.pl $ref_fa_size  runAQI_out/tmp_merged.loc.str.ER $norm_window $norm_window $Eff_size  >runAQI_out/tmp_sequence.stat

echo -e "[M::worker_pipeline:: Create regional metrics]"
perl $src/weight_regional_QER.pl $ref_fa_size $regional_window $regional_window tmp_NER.stat >runAQI_out/out_regional.Report

echo -e "[M::worker_pipeline:: Create final report]"
perl $src/final_short_report.pl runAQI_out/tmp_sequence.stat  0.85  >runAQI_out/$name"_final.Report"

mv tmp_NER.stat  runAQI_out/
mv runAQI_out/Gap_out/* runAQI_out/tmp_sequence.gapN
rm -rf runAQI_out/Gap_out/
echo -e "CRAQ analysis is finished. Check current directory runAQI_out for final results!\n"
