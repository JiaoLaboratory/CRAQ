src=`cd $(dirname $0); pwd -P`
pipline=$(basename $0)
Usage="\nUsage:\n\t#Genome assessing using AQI:\n\t$pipline -g  Genome.fa -z  Genome.fa.size -e LRout/LR_eff.size  -c SRout/SR_putative.RE.RH  -C LRout/LR_putative.SE.SH  -d SRout/SR_sort.depth  -D LRout/LR_sort.depth  [default: -r 0.75 -p 0.4 -q 0.6 -R 0.75 -P 0.4 -Q 0.6 -f 0.1 -M 10000  -n 10 -j 1 -b F -m 1000000 -s 50000 -u T  -w 1000000 -y T -x seq.size ]"

name="out"
skewned_rate=0.1
LRmax_depth=1000
min_gap_len=10
gapmodel=1
breakmj=F
report_minctgsize=1000000

mincontigsize=50000
srbk_cutoff=0.75
she_cutoff_left=0.4
she_cutoff_right=0.6

lrbk_cutoff=0.75
lhe_cutoff_left=0.4
lhe_cutoff_right=0.6

#norm_window=50000
regional_window=1000000
merge_strER_window=10000
plot=F
search_cluster=F
report_SNV=F

while getopts "s:g:z:e:c:d:C:D:f:e:n:w:m:M:j:b:r:p:q:R:P:Q:y:x:u:v:o" opt
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
	m)	report_minctgsize=$OPTARG;;
	M)	merge_strER_window=$OPTARG;;
	j)	gapmodel=$OPTARG;;
	b)	breakmj=$OPTARG;;
	r)	srbk_cutoff=$OPTARG;;	
	p)	she_cutoff_left=$OPTARG;;
	q)	she_cutoff_right=$OPTARG;;
	R)	lrbk_cutoff=$OPTARG;;
	P)	lhe_cutoff_left=$OPTARG;;
	Q)	lhe_cutoff_right=$OPTARG;;
	y)	plot=$OPTARG;;
	x)	your_chrid=$OPTARG;;
	u)	search_cluster=$OPTARG;;
	v)	report_SNV=$OPTARG;;
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

if [ ! -n "$norm_window" ]
then
        norm_window=$(perl $src/compute_norm_window.pl  $ref_fa_size)
fi


#echo -e "Local collapsed cutoff : $skewned_rate"

mkdir -p runAQI_out/Gap_out  runAQI_out/locER_out  runAQI_out/strER_out 

###echo -e "[M::worker_pipeline:: Get Genomic Gap]"
perl $src/getGap.pl  $ref_fa | perl $src/gap_filter.pl - $ref_fa_size $min_gap_len  >runAQI_out/Gap_out/$name"_gap.out"
cp runAQI_out/Gap_out/*_gap.out runAQI_out/tmp_sequence.gapN

echo -e "[M::worker_pipeline:: Filter putative CRE]"
perl $src/get_ER.pl $LR_normdep  $SR_coverRate  10 20 $skewned_rate  >runAQI_out/locER_out/$name"_lrfilter.out"
perl -alne '$ratio=($F[3]/$F[4]);print if($ratio > '$srbk_cutoff')' runAQI_out/locER_out/$name"_lrfilter.out" | perl $src/remove_smsH_ngsCRE.pl LRout/LR_DI.cov.dimin3.tmp.dep -  >runAQI_out/locER_out/$name"_lrfilter_CRE.out.1.tmp"
#perl -alne ' $ratio=($F[3]/$F[4]); print if( $ratio <= '$she_cutoff_right' && $ratio >= '$she_cutoff_left'  )' runAQI_out/locER_out/$name"_lrfilter.out"  >runAQI_out/locER_out/$name"_lrfilter_CRH.out.1.tmp"
touch runAQI_out/locER_out/$name"_lrfilter_CRH.out.1.tmp"

perl $src/add_DI.pl LRout/LR_DI.covRate.filter.R runAQI_out/locER_out/$name"_lrfilter_CRE.out.1.tmp" RE $srbk_cutoff 1  >runAQI_out/locER_out/$name"_lrfilter_CRE.out.2.tmp"
perl $src/remove_ngs_normal.pl SRout/SR_clip.coverRate SRout/Nonmap.loc runAQI_out/locER_out/$name"_lrfilter_CRE.out.2.tmp" >runAQI_out/locER_out/$name"_lrfilter_CRE.out"

perl $src/add_DI.pl LRout/LR_DI.covRate.filter.R runAQI_out/locER_out/$name"_lrfilter_CRH.out.1.tmp" RH $she_cutoff_left $she_cutoff_right  >runAQI_out/locER_out/$name"_lrfilter_CRH.out"
#perl $src/remove_ngs_normal.pl SRout/SR_clip.coverRate SRout/Nonmap.loc runAQI_out/locER_out/$name"_lrfilter_CRH.out" >runAQI_out/locER_out/$name"_lrfilter_CRH.out.NEW"


perl -alne  '{print "$F[0]\t1\t1\tGap\n$F[0]\t$F[1]\t$F[1]\tGap"}' $ref_fa_size > runAQI_out/locER_out/tmp.size
if [[ $gapmodel == 2 ]];then
perl $src/merge_gap_ER.pl   runAQI_out/locER_out/tmp.size  runAQI_out/locER_out/$name"_lrfilter_CRE.out" >runAQI_out/locER_out/$name"_SER.merge.tmp"

else
perl $src/merge_gap_ER.pl   runAQI_out/Gap_out/$name"_gap.out"  runAQI_out/locER_out/$name"_lrfilter_CRE.out" >runAQI_out/locER_out/$name"_SER.merge.tmp"
fi

perl $src/merge_gap_ER.pl   runAQI_out/locER_out/tmp.size  runAQI_out/locER_out/$name"_lrfilter_CRH.out" |grep -v 'Gap'  > runAQI_out/locER_out/$name"_SHR.merge.tmp"

perl -alne 'print "$F[0]\t$F[1]\tSER"' runAQI_out/locER_out/$name"_SER.merge.tmp" >runAQI_out/locER_out/$name"_final.SER.out.tmp"
perl -alne 'print "$F[0]\t$F[1]\tSHR"' runAQI_out/locER_out/$name"_SHR.merge.tmp" >runAQI_out/locER_out/$name"_final.SHR.out.tmp"

###################################################################l
echo -e "[M::worker_pipeline:: Filter putative CSE]"
perl -alne ' $ratio=($F[3]/$F[4]); print if( $ratio <= '$lhe_cutoff_right' && $ratio >= '$lhe_cutoff_left'  )' $LR_coverRate >runAQI_out/strER_out/$name"_putative.LHR"
perl -alne ' $ratio=($F[3]/$F[4]); print if( $ratio > '$lrbk_cutoff'  )' $LR_coverRate >runAQI_out/strER_out/$name"_putative.LER"
perl -alne ' $ratio=($F[3]/$F[4]); print if( $ratio <= '$she_cutoff_right' && $ratio >= '$she_cutoff_left'  )' $SR_coverRate >runAQI_out/strER_out/$name"_putative.SHR"
perl -alne ' $ratio=($F[3]/$F[4]); print if( $ratio > '$srbk_cutoff'  )' $SR_coverRate >runAQI_out/strER_out/$name"_putative.SER"

##add nonmap region as putative LER
perl $src/get_dep0_region.pl LRout/Nonmap.loc LRout/Nonmap.loc |perl $src/merge_dep0_region.pl - |perl -alne 'print "$F[0]\t$F[1]\t+\t3.1\t3.1"' >>runAQI_out/strER_out/$name"_putative.LER"

perl $src/lrbk_have_srbk.pl runAQI_out/strER_out/$name"_putative.SER" runAQI_out/strER_out/$name"_putative.LER" 500    >runAQI_out/strER_out/$name"_pLER_overlap_pSER.out" 
perl $src/lrbk_have_srbk.pl runAQI_out/strER_out/$name"_putative.SHR" runAQI_out/strER_out/$name"_putative.LHR" 50    >runAQI_out/strER_out/$name"_pLHR_overlap_pSHR.out"

#Filtering LER using srdepth
perl $src/LRcoverRate_srdep_filter.pl $SR_normdep $LR_coverRate > runAQI_out/strER_out/$name"_pLER_pLHR_overlap_srdep0.out"

perl -alne ' $ratio=($F[3]/$F[4]); print if( $ratio > '$lrbk_cutoff'  )' runAQI_out/strER_out/$name"_pLER_pLHR_overlap_srdep0.out"  >  runAQI_out/strER_out/$name"_pLER_overlap_srdep0.out"
perl -alne ' $ratio=($F[3]/$F[4]); print if( $ratio <= '$lhe_cutoff_right' && $ratio >= '$lhe_cutoff_left' )' runAQI_out/strER_out/$name"_pLER_pLHR_overlap_srdep0.out"  >  runAQI_out/strER_out/$name"_pLHR_overlap_srdep0.out"

cat runAQI_out/strER_out/$name"_pLER_overlap_pSER.out" runAQI_out/strER_out/$name"_pLER_overlap_srdep0.out" |sort -k 1,1 -k 2,2n |uniq >runAQI_out/strER_out/$name"_srfilter_CSE.out"
cat runAQI_out/strER_out/$name"_pLHR_overlap_pSHR.out" runAQI_out/strER_out/$name"_pLHR_overlap_srdep0.out" |sort -k 1,1 -k 2,2n |uniq >runAQI_out/strER_out/$name"_srfilter_CSH.out"
rm runAQI_out/strER_out/*overlap* runAQI_out/strER_out/*_putative*

###Merge LER
perl $src/merge_misjunction_gap.pl runAQI_out/strER_out/$name"_srfilter_CSE.out"  runAQI_out/Gap_out/$name"_gap.out" >runAQI_out/strER_out/$name"_havegap_srfilter_ER.tmp"
perl $src/merge_misjunction_gap.pl runAQI_out/strER_out/$name"_srfilter_CSH.out"  runAQI_out/Gap_out/$name"_gap.out" >runAQI_out/strER_out/$name"_havegap_srfilter_HR.tmp"
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
cp runAQI_out/locER_out/$name"_final.SHR.out.tmp" runAQI_out/locER_out/$name"_final.SHR.out"

#Quality Benchmarking
########################################################################
cat runAQI_out/locER_out/$name"_final.SER.out"  runAQI_out/strER_out/$name"_final.LER.out"  >runAQI_out/tmp_merged.loc.str.ER
cat runAQI_out/locER_out/$name"_final.SHR.out"  runAQI_out/strER_out/$name"_final.LHR.out"  >runAQI_out/tmp_merged.loc.str.HR

if [ "$search_cluster" == "T" ] ; then
echo -e "[M::worker_pipeline:: Search noisy error region]"
perl $src/get_nonmap_region.pl SRout/Nonmap.loc SRout/Nonmap.loc > runAQI_out/SRNonmap.loc.bed
#perl $src/search_ER_region.pl runAQI_out/SRNonmap.loc.bed runAQI_out/tmp_merged.loc.str.ER >runAQI_out/tmp.ER.region
#grep 'SER' runAQI_out/tmp.ER.region | perl -alne  'print "$F[0]\t$F[1]\t$F[2]\t$F[3]\tCRE"' - >runAQI_out/locER_out/out_final.CRE.bed
perl $src/search_ER_region.pl runAQI_out/SRNonmap.loc.bed runAQI_out/strER_out/$name"_final.LER.out" >runAQI_out/tmp.LER.region

grep 'LER' runAQI_out/tmp.LER.region | perl -alne  'print "$F[0]\t$F[1]\t$F[2]\t$F[3]\tCSE"' - >runAQI_out/strER_out/out_final.CSE.bed
perl $src/get_DI_region.pl  LRout/LR_DI.covRate.filter.R runAQI_out/tmp_sequence.gapN runAQI_out/locER_out/out_final.SER.out |perl -alne 'print "$_\tCRE"' - >runAQI_out/locER_out/out_final.CRE.bed

rm runAQI_out/tmp.LER.region runAQI_out/SRNonmap.loc.bed
fi

if [ "$search_cluster" != "T" ] ; then
#perl -alne '$a=$F[1]+1;print "$F[0]\t$F[1]\t$a\t$F[0]:$F[1]\tCRE"'  runAQI_out/locER_out/$name"_final.SER.out" >runAQI_out/locER_out/out_final.CRE.bed
perl -alne '$a=$F[1]+1;print "$F[0]\t$F[1]\t$a\t$F[0]:$F[1]\tCSE"'  runAQI_out/strER_out/$name"_final.LER.out" >runAQI_out/strER_out/out_final.CSE.bed
perl $src/get_DI_region.pl  LRout/LR_DI.covRate.filter.R runAQI_out/tmp_sequence.gapN runAQI_out/locER_out/out_final.SER.out.tmp |perl -alne 'print "$_\tCRE"' - >runAQI_out/locER_out/out_final.CRE.bed

fi

#perl -alne '$a=$F[1]+1;print "$F[0]\t$F[1]\t$a\t$F[0]:$F[1]\tCRH"'  runAQI_out/locER_out/$name"_final.SHR.out" >runAQI_out/locER_out/out_final.CRH.bed
perl $src/get_DI_region.pl  LRout/LR_DI.covRate.filter.R runAQI_out/tmp_sequence.gapN runAQI_out/locER_out/out_final.SHR.out.tmp |perl -alne 'print "$_\tCRH"' - >runAQI_out/locER_out/out_final.CRH.bed
perl -alne '$a=$F[1]+1;print "$F[0]\t$F[1]\t$a\t$F[0]:$F[1]\tCSH"'  runAQI_out/strER_out/$name"_final.LHR.out" >runAQI_out/strER_out/out_final.CSH.bed

echo -e "[M::worker_pipeline:: Quality benchmarking]"
ERname="ER"
HRname="HR"
perl $src/get_ER_junctionstat_window.pl $ref_fa_size  runAQI_out/tmp_merged.loc.str.ER $norm_window $norm_window $Eff_size $ERname  >runAQI_out/seq.E.stat
perl $src/get_ER_junctionstat_window.pl $ref_fa_size  runAQI_out/tmp_merged.loc.str.HR $norm_window $norm_window $Eff_size $HRname  >runAQI_out/seq.H.stat


echo -e "[M::worker_pipeline:: Create regional metrics]"
perl $src/regional_AQI.pl $ref_fa_size $regional_window $regional_window runAQI_out/tmp_merged.loc.str.ER >runAQI_out/out_regional.Report
perl -alne  'print "$F[0]\t$F[1]\t$F[2]\t$F[-1]"' runAQI_out/out_regional.Report |grep -v 'AQI'  >runAQI_out/out_regional.AQI.bdg

if [ "$plot" == "T" ] ; then
echo -e "[M::worker_pipeline:: Plot CRAQ metrics]"
python $src/CRAQcircos.py --genome_size $ref_fa_size --genome_error_loc runAQI_out/tmp_merged.loc.str.ER --genome_score runAQI_out/out_regional.AQI.bdg --scaffolds_ids $your_chrid --output runAQI_out/out_circos.pdf
fi

echo -e "[M::worker_pipeline:: Create final report]"
perl $src/final_short_report_minlen.pl runAQI_out/seq.E.stat  0.85 $report_minctgsize  >runAQI_out/$name"_final.ER.Report.tmp"
perl $src/final_short_report_minlen.pl runAQI_out/seq.H.stat  0.85 $report_minctgsize  >runAQI_out/$name"_final.HR.Report.tmp"
perl $src/merge_final_short_report.pl runAQI_out/$name"_final.HR.Report.tmp" runAQI_out/$name"_final.ER.Report.tmp" >runAQI_out/$name"_final.Report.tmp"

cat $SR_coverRate $LR_coverRate runAQI_out/Gap_out/$name"_gap.out" > runAQI_out/all_putative_and_gapN.tmp
perl $src/get_nonmap_region.pl SRout/Nonmap.loc LRout/Nonmap.loc |  perl $src/search_uncertain_region.pl - runAQI_out/all_putative_and_gapN.tmp  >runAQI_out/low_confidence.bed
perl $src/intergrate_uncertain.pl $ref_fa_size runAQI_out/low_confidence.bed runAQI_out/$name"_final.Report.tmp" | perl $src/format_results_addAQI.pl - >runAQI_out/$name"_final.Report"

perl -alne  'print if( $F[3]>2 && ($F[3]/$F[4])> '$lhe_cutoff_right' && ($F[3]/$F[4])< '$lrbk_cutoff')' LRout/LR_clip.coverRate.filter >runAQI_out/strER_out/ambiguous.SE.SH
#perl -alne  'print if( $F[3]>2 && ($F[3]/$F[4])> '$she_cutoff_right' && ($F[3]/$F[4])< '$srbk_cutoff' )' SRout/SR_clip.coverRate >runAQI_out/locER_out/ambiguous.RE.RH
perl -alne  'print if( $F[3]>2 && ($F[3]/$F[4])> '$she_cutoff_right' && ($F[3]/$F[4])< '$srbk_cutoff'  )' LRout/LR_DI.covRate.filter.R |cut -f -5 >runAQI_out/locER_out/ambiguous.RE.RH

if [ "$report_SNV" == "T" ] ; then
mv LRout/out_final_indel.err runAQI_out/locER_out/
mv LRout/out_final_indel.het runAQI_out/locER_out/
fi
mv runAQI_out/low_confidence.bed  runAQI_out/strER_out/out_low_coverage.bed
rm -rf  ER.tmp_N.stat HR.tmp_N.stat  runAQI_out/*Report.tmp  runAQI_out/Gap_out/ runAQI_out/tmp_seq* runAQI_out/locER_out/out_final.S*R.out runAQI_out/strER_out/out_final.L*R.out runAQI_out/strER_out/*tmp runAQI_out/locER_out/*tmp* runAQI_out/locER_out/out_lrfilter.out runAQI_out/*gapN.tmp runAQI_out/tmp_merged* LRout/*tmp*
rm   runAQI_out/*stat  

echo -e "CRAQ analysis is finished. Check current directory runAQI_out for final results!\n"
