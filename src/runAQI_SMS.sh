src=`cd $(dirname $0); pwd -P`
pipline=$(basename $0)
Usage="\nUsage:\n\t#Genome assessing using AQI:\n\t$pipline -g  Genome.fa -z  Genome.fa -e LRout/LR_eff.size  -C LRout/LR_putative.ER.HR  -D LRout/LR_sort.depth  [default:  -R 0.65 -P 0.4 -Q 0.6 -M 10000 -w 1000000 -n 10 -j 1 -b F -m 1000000]"

name="out"
LRmax_depth=1000
min_gap_len=10
gapmodel=1
breakmj=F
report_minctgsize=1000000
mincontigsize=50000

lrbk_cutoff=0.65
lhe_cutoff_left=0.4
lhe_cutoff_right=0.6

norm_window=50000
regional_window=1000000
merge_strER_window=10000

while getopts "g:z:e:C:D:n:s:w:m:M:j:b:R:P:Q:o" opt
do
    case $opt in
        g)      ref_fa=$OPTARG ;;
        z)      ref_fa_size=$OPTARG;;
        e)      Eff_size=$OPTARG;;
        #c)      SR_coverRate=$OPTARG;;
        C)      LR_coverRate=$OPTARG;;
	#d)      SR_normdep=$OPTARG;;
        D)      LR_normdep=$OPTARG;;
	#f)      skewned_rate=$OPTARG;;
	n)	min_gap_len=$OPTARG;;
	s)	norm_window=$OPTARG;;
	w)	regional_window=$OPTARG;;
	m)	report_minctgsize=$OPTARG;;
	M)	merge_strER_window=$OPTARG;;
	j)	gapmodel=$OPTARG;;
	b)	breakmj=$OPTARG;;
	R)	lrbk_cutoff=$OPTARG;;
	P)	lhe_cutoff_left=$OPTARG;;
	Q)	lhe_cutoff_right=$OPTARG;;
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


if [ ! -e "$LR_normdep" ]
then
       echo -e "\n\tLong reads depthfile is not found,  please check the README.md for the requirements of input files!\n\t$Usage \n"
       exit 1
fi


if [ ! -e "$LR_coverRate" ]
then
       echo -e "\n\tLR_putative.ER not found,  please check the README.md for the requirements of input files!\n\t$Usage \n"
       exit 1
fi



#echo -e "Local collapsed cutoff : $skewned_rate"

mkdir -p runAQI_out/Gap_out  runAQI_out/locER_out  runAQI_out/strER_out 

###echo -e "[M::worker_pipeline:: Get Genomic Gap]"
perl $src/getGap.pl  $ref_fa | perl $src/gap_filter.pl - $ref_fa_size $min_gap_len  >runAQI_out/Gap_out/$name"_gap.out"

perl -alne  '{print "$F[0]\t1\t1\tGap\n$F[0]\t$F[1]\t$F[1]\tGap"}' $ref_fa_size > runAQI_out/locER_out/tmp.size

touch runAQI_out/locER_out/$name"_lrfilter_SER.out" runAQI_out/locER_out/$name"_lrfilter_SHR.out"

if [[ $gapmodel == 2 ]];then
perl $src/merge_gap_ER.pl   runAQI_out/locER_out/tmp.size  runAQI_out/locER_out/$name"_lrfilter_SER.out" >runAQI_out/locER_out/$name"_SER.merge.tmp"

else
perl $src/merge_gap_ER.pl   runAQI_out/Gap_out/$name"_gap.out"  runAQI_out/locER_out/$name"_lrfilter_SER.out" >runAQI_out/locER_out/$name"_SER.merge.tmp"
fi

perl $src/merge_gap_ER.pl   runAQI_out/locER_out/tmp.size  runAQI_out/locER_out/$name"_lrfilter_SHR.out" |grep -v 'Gap'  > runAQI_out/locER_out/$name"_SHR.merge.tmp"

perl -alne 'print "$F[0]\t$F[1]\tSER"' runAQI_out/locER_out/$name"_SER.merge.tmp" >runAQI_out/locER_out/$name"_final.SER.out.tmp"
perl -alne 'print "$F[0]\t$F[1]\tSHR"' runAQI_out/locER_out/$name"_SHR.merge.tmp" >runAQI_out/locER_out/$name"_final.SHR.out.tmp"

###################################################################l
echo -e "[M::worker_pipeline:: Filter putative LER]"
perl -alne ' $ratio=($F[3]/$F[4]); print if( $ratio <= '$lhe_cutoff_right' && $ratio >= '$lhe_cutoff_left'  )' $LR_coverRate >runAQI_out/strER_out/$name"_putative.LHR"
perl -alne ' $ratio=($F[3]/$F[4]); print if( $ratio > '$lrbk_cutoff'  )' $LR_coverRate >runAQI_out/strER_out/$name"_putative.LER"


cat runAQI_out/strER_out/$name"_putative.LER" |sort -k 1,1 -k 2,2n |uniq  >runAQI_out/strER_out/$name"_srfilter_LER.out"
cat runAQI_out/strER_out/$name"_putative.LHR" |sort -k 1,1 -k 2,2n |uniq  >runAQI_out/strER_out/$name"_srfilter_LHR.out"

###Merge LER
perl $src/merge_misjunction_gap.pl runAQI_out/strER_out/$name"_srfilter_LER.out"  runAQI_out/Gap_out/$name"_gap.out" >runAQI_out/strER_out/$name"_havegap_srfilter_ER.tmp"
perl $src/merge_misjunction_gap.pl runAQI_out/strER_out/$name"_srfilter_LHR.out"  runAQI_out/Gap_out/$name"_gap.out" >runAQI_out/strER_out/$name"_havegap_srfilter_HR.tmp"
perl $src/search_Misjunction.pl   -a $LRmax_depth -w $merge_strER_window -m $mincontigsize   -z $ref_fa_size -j $gapmodel  -i runAQI_out/strER_out/$name"_havegap_srfilter_ER.tmp" >runAQI_out/strER_out/$name"_merge.strER.out.tmp"
perl $src/search_Misjunction.pl   -a $LRmax_depth -w $merge_strER_window -m $mincontigsize   -z $ref_fa_size -j $gapmodel  -i runAQI_out/strER_out/$name"_havegap_srfilter_HR.tmp" >runAQI_out/strER_out/$name"_merge.strHR.out.tmp"

#Get final LER
perl $src/filter_endLER.pl $ref_fa_size runAQI_out/strER_out/$name"_merge.strER.out.tmp" 5000 >runAQI_out/strER_out/$name"_strER.merge.tmp"
perl $src/filter_endLER.pl $ref_fa_size runAQI_out/strER_out/$name"_merge.strHR.out.tmp" 5000 >runAQI_out/strER_out/$name"_strHR.merge.tmp"
perl -alne 'print "$F[0]\t$F[1]\tLER"' runAQI_out/strER_out/$name"_strER.merge.tmp" >runAQI_out/strER_out/$name"_final.LER.out"
perl -alne 'print "$F[0]\t$F[1]\tLHR"' runAQI_out/strER_out/$name"_strHR.merge.tmp" >runAQI_out/strER_out/$name"_final.LHR.out"

if [ "$breakmj" == "T" ] ; then
	echo -e "[M::worker_pipeline:: Break at Misjunct]"
perl $src/break_at_Misjunction.pl $ref_fa runAQI_out/strER_out/$name"_final.LER.out"  >runAQI_out/out_correct.fa
fi
rm -rf runAQI_out/strER_out/*merge.str* runAQI_out/strER_out/*_havegap_* 

perl $src/srbk_rm_lrbk.pl runAQI_out/strER_out/$name"_final.LER.out" runAQI_out/locER_out/$name"_final.SER.out.tmp" 500 >runAQI_out/locER_out/$name"_final.SER.out"

#Quality Benchmarking
########################################################################
echo -e "[M::worker_pipeline:: Quality benchmarking"

cat  runAQI_out/strER_out/$name"_final.LER.out" runAQI_out/locER_out/$name"_final.SER.out" >runAQI_out/tmp_merged.loc.str.ER
cat  runAQI_out/strER_out/$name"_final.LHR.out"  >runAQI_out/tmp_merged.loc.str.HR
ERname="ER"
HRname="HR"
perl $src/get_ER_junctionstat_window.pl $ref_fa_size  runAQI_out/tmp_merged.loc.str.ER $norm_window $norm_window $Eff_size $ERname  >runAQI_out/seq.ER.stat
perl $src/get_ER_junctionstat_window.pl $ref_fa_size  runAQI_out/tmp_merged.loc.str.HR $norm_window $norm_window $Eff_size $HRname  >runAQI_out/seq.HR.stat


echo -e "[M::worker_pipeline:: Create CRAQ metrics]"
perl $src/regional_AQI.pl $ref_fa_size $regional_window $regional_window runAQI_out/tmp_merged.loc.str.ER >runAQI_out/out_regional.Report
perl -alne  'print "$F[0]\t$F[1]\t$F[2]\t$F[-1]"' runAQI_out/out_regional.Report |grep -v 'AQI'  >runAQI_out/out_regional.AQI.bdg

echo -e "[M::worker_pipeline:: Plot regional metrics]"
python $src/CRAQcircos.py --genome_size $ref_fa_size --genome_error_loc runAQI_out/tmp_merged.loc.str.ER --genome_score runAQI_out/out_regional.AQI.bdg --output runAQI_out/out_circos.pdf

echo -e "[M::worker_pipeline:: Create final report]"
perl $src/final_short_report_minlen.pl runAQI_out/seq.ER.stat  0.85 $report_minctgsize  >runAQI_out/$name"_final.ER.Report.tmp"
perl $src/final_short_report_minlen.pl runAQI_out/seq.HR.stat  0.85 $report_minctgsize  >runAQI_out/$name"_final.HR.Report.tmp"
perl $src/merge_final_short_report.pl runAQI_out/$name"_final.HR.Report.tmp" runAQI_out/$name"_final.ER.Report.tmp" >runAQI_out/$name"_final.Report.tmp"

cp LRout/uncertain_region.bed runAQI_out/
perl $src/intergrate_uncertain.pl $ref_fa_size runAQI_out/uncertain_region.bed runAQI_out/$name"_final.Report.tmp" >runAQI_out/$name"_final.Report"

mv runAQI_out/Gap_out/* runAQI_out/tmp_sequence.gapN
perl -alne  '$a=$F[1]+1;print  "$F[0]\t$F[1]\t$a\t$F[-1]"' runAQI_out/strER_out/out_final.LER.out >runAQI_out/strER_out/out_final.LER.bed
perl -alne  '$a=$F[1]+1;print  "$F[0]\t$F[1]\t$a\t$F[-1]"' runAQI_out/strER_out/out_final.LHR.out >runAQI_out/strER_out/out_final.LHR.bed

rm -rf  ER.tmp_N.stat HR.tmp_N.stat  runAQI_out/*Report.tmp  runAQI_out/Gap_out/ runAQI_out/tmp_seq* runAQI_out/locER_out/out_final.S*R.out runAQI_out/strER_out/out_final.L*R.out runAQI_out/strER_out/*tmp runAQI_out/locER_out/*tmp runAQI_out/locER_out runAQI_out/strER_out/*_putative*
rm  runAQI_out/tmp_merged*
echo -e "CRAQ analysis is finished. Check current directory runAQI_out for final results!\n"
