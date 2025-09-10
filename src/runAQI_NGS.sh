src=`cd $(dirname $0); pwd -P`
pipline=$(basename $0)
Usage="\nUsage:\n\t#Genome assessing using AQI:\n\t$pipline -g  Genome.fa -z  Genome.fa.size -e SRout/SR_eff.size  -c SRout/SR_putative.RE.RH -d SRout/SR_sort.depth [default: -r 0.75 -p 0.4 -q 0.6 -w 1000000 -n 10 -j 1 -m 1000000]"

name="out"
min_gap_len=10
gapmodel=1
report_minctgsize=1000000

mincontigsize=50000
srbk_cutoff=0.75
she_cutoff_left=0.4
she_cutoff_right=0.6
regional_window=1000000
plot=F
search_cluster=T
report_SNV=T
minlen=40

while getopts "s:g:z:e:c:d:e:n:w:m:j:r:p:q:y:x:u:v:o" opt
do
    case $opt in
        g)      ref_fa=$OPTARG ;;
        z)      ref_fa_size=$OPTARG;;
        e)      Eff_size=$OPTARG;;
        c)      SR_coverRate=$OPTARG;;
	d)      SR_normdep=$OPTARG;;
	n)	min_gap_len=$OPTARG;;
	s)	norm_window=$OPTARG;;
	w)	regional_window=$OPTARG;;
	m)	report_minctgsize=$OPTARG;;
	j)	gapmodel=$OPTARG;;
	r)	srbk_cutoff=$OPTARG;;	
	p)	she_cutoff_left=$OPTARG;;
	q)	she_cutoff_right=$OPTARG;;
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


if [ ! -e "$SR_coverRate" ]
then
       echo -e "\n\tSR_putative.ER not found,  please check the README.md for the requirements of input files!\n\t$Usage \n"
       exit 1
fi

if [ ! -n "$norm_window" ]
then
        norm_window=$(perl $src/compute_norm_window.pl  $ref_fa_size)
fi

mkdir -p runAQI_out/Gap_out  runAQI_out/locER_out 

echo -e "[M::worker_pipeline:: Collect potential CRE|H]"

if [ "$report_SNV" != "T" ] ; then
        samtools view  SRout/SR_sort.bam  -@ 5 | perl $src/caculate_clipDI_cov.pl  - $minlen >SRout/SR_DI.cov
        perl $src/synthesize_clipDIcov_and_alldep.pl SRout/SR_DI.cov SRout/SR_sort.depth     >SRout/SR_DI.covRate.filter.R
fi

if [ "$report_SNV" == "T" ] ; then
        samtools view  SRout/SR_sort.bam  -@ 5 | perl $src/caculate_clipDI_cov.pl  - 1 > SRout/SR_DI.cov
        perl $src/synthesize_clipDIcov_and_alldep.pl SRout/SR_DI.cov SRout/SR_sort.depth >SRout/SR_DI.covRate.filter.all
        perl -alne 'print if($F[5]>= '$minlen')' SRout/SR_DI.covRate.filter.all >SRout/SR_DI.covRate.filter.R

        perl -alne 'print if($F[5] < '$minlen')' SRout/SR_DI.covRate.filter.all >SRout/SR_DI.covRate.filter.SNV
        perl -alne  '$a=$F[3]/$F[4]; print if($a >=0.9 && $F[7]>0.8  )' SRout/SR_DI.covRate.filter.SNV |perl -alne 'print "$F[0]\t$F[1]\t$F[3]\t$F[4]\t$F[5]$F[6]"' >runAQI_out/locER_out/out_final_indel.err
        perl -alne  '$a=$F[3]/$F[4]; print if($a >='$she_cutoff_left' && $a <='$she_cutoff_right' &&  $F[7]>0.8  )' SRout/SR_DI.covRate.filter.SNV |perl -alne 'print "$F[0]\t$F[1]\t$F[3]\t$F[4]\t$F[5]$F[6]"' >runAQI_out/locER_out/out_final_indel.het
        rm SRout/SR_DI.covRate.filter.all
fi



###echo -e "[M::worker_pipeline:: Get Genomic Gap]"
perl $src/getGap.pl  $ref_fa | perl $src/gap_filter.pl - $ref_fa_size $min_gap_len  >runAQI_out/Gap_out/$name"_gap.out"
cp runAQI_out/Gap_out/$name"_gap.out" runAQI_out/tmp_sequence.gapN
echo -e "[M::worker_pipeline:: Get putative CRE]"

perl -alne '$ratio=($F[3]/$F[4]);print if($ratio > '$srbk_cutoff' && $F[3]>=2  )' $SR_coverRate  >runAQI_out/locER_out/$name"_lrfilter_CRE.out.1.tmp"
perl -alne ' $ratio=($F[3]/$F[4]); print if( $ratio <= '$she_cutoff_right' && $ratio >= '$she_cutoff_left'  )' $SR_coverRate  >runAQI_out/locER_out/$name"_lrfilter_CRH.out.1.tmp"

perl $src/add_DI.pl SRout/SR_DI.covRate.filter.R runAQI_out/locER_out/$name"_lrfilter_CRE.out.1.tmp" RE $srbk_cutoff 1  >runAQI_out/locER_out/$name"_lrfilter_CRE.out"
perl $src/add_DI.pl SRout/SR_DI.covRate.filter.R runAQI_out/locER_out/$name"_lrfilter_CRH.out.1.tmp" RH $she_cutoff_left $she_cutoff_right  >runAQI_out/locER_out/$name"_lrfilter_CRH.out"


perl -alne  '{print "$F[0]\t1\t1\tGap\n$F[0]\t$F[1]\t$F[1]\tGap"}' $ref_fa_size > runAQI_out/locER_out/tmp.size
if [[ $gapmodel == 2 ]];then
perl $src/merge_gap_ER.pl   runAQI_out/locER_out/tmp.size  runAQI_out/locER_out/$name"_lrfilter_CRE.out" >runAQI_out/locER_out/$name"_SER.merge.tmp"

else
perl $src/merge_gap_ER.pl   runAQI_out/Gap_out/$name"_gap.out"  runAQI_out/locER_out/$name"_lrfilter_CRE.out" >runAQI_out/locER_out/$name"_SER.merge.tmp"
fi

perl $src/merge_gap_ER.pl   runAQI_out/locER_out/tmp.size  runAQI_out/locER_out/$name"_lrfilter_CRH.out" |grep -v 'Gap'  > runAQI_out/locER_out/$name"_SHR.merge.tmp"

perl -alne 'print "$F[0]\t$F[1]\tSER"' runAQI_out/locER_out/$name"_SER.merge.tmp" >runAQI_out/locER_out/$name"_final.SER.out.tmp"
perl -alne 'print "$F[0]\t$F[1]\tSHR"' runAQI_out/locER_out/$name"_SHR.merge.tmp" >runAQI_out/locER_out/$name"_final.SHR.out.tmp"

cp runAQI_out/locER_out/$name"_final.SER.out.tmp" runAQI_out/locER_out/$name"_final.SER.out"
cp runAQI_out/locER_out/$name"_final.SHR.out.tmp" runAQI_out/locER_out/$name"_final.SHR.out"

#Quality Benchmarking
########################################################################

cat runAQI_out/locER_out/$name"_final.SER.out"   >runAQI_out/tmp_merged.loc.str.ER
cat runAQI_out/locER_out/$name"_final.SHR.out"   >runAQI_out/tmp_merged.loc.str.HR

perl $src/get_nonmap_region.pl SRout/Nonmap.loc SRout/Nonmap.loc >runAQI_out/SRNonmap.loc.bed

if [ "$search_cluster" == "T" ] ; then
echo -e "[M::worker_pipeline:: Search noisy region]"
perl $src/search_ER_region.pl runAQI_out/SRNonmap.loc.bed runAQI_out/tmp_merged.loc.str.ER | perl -alne  'print "$F[0]\t$F[1]\t$F[2]\t$F[3]\tCRE"' - >runAQI_out/locER_out/out_final.CRE.bed
fi
if [ "$search_cluster" != "T" ] ; then
perl -alne '$a=$F[1]+1;print "$F[0]\t$F[1]\t$a\t$F[0]:$F[1]\tCRE"'  runAQI_out/locER_out/out_final.SER.out >runAQI_out/locER_out/out_final.CRE.bed
fi
perl -alne '$a=$F[1]+1;print "$F[0]\t$F[1]\t$a\t$F[0]:$F[1]\tCRH"'  runAQI_out/locER_out/out_final.SHR.out >runAQI_out/locER_out/out_final.CRH.bed

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

cat  $SR_coverRate runAQI_out/Gap_out/$name"_gap.out" > runAQI_out/all_putative_and_gapN.tmp
perl $src/search_uncertain_region.pl runAQI_out/SRNonmap.loc.bed runAQI_out/all_putative_and_gapN.tmp  >runAQI_out/low_confidence.bed
perl $src/intergrate_uncertain.pl $ref_fa_size runAQI_out/low_confidence.bed runAQI_out/$name"_final.Report.tmp" |perl $src/format_results_addAQI.pl - >runAQI_out/$name"_final.Report"

mv runAQI_out/Gap_out/*  runAQI_out/tmp_sequence.gapN 
perl -alne  'print if( $F[3]>2 && ($F[3]/$F[4])> '$she_cutoff_right' && ($F[3]/$F[4])< '$srbk_cutoff')' SRout/SR_clip.coverRate >runAQI_out/locER_out/ambiguous.RE.RH
mv runAQI_out/low_confidence.bed runAQI_out/locER_out/out_low_coverage.bed
rm -rf  ER.tmp_N.stat HR.tmp_N.stat  runAQI_out/locER_out/tmp* runAQI_out/*Report.tmp  runAQI_out/Gap_out/ runAQI_out/tmp_seq* runAQI_out/locER_out/out_final.S*R.out runAQI_out/strER_out/out_final.L*R.out runAQI_out/strER_out/*tmp runAQI_out/locER_out/*tmp*  runAQI_out/strER_out/*_putative*  runAQI_out/*tmp
rm  runAQI_out/tmp_merged* runAQI_out/SRNonmap.loc.bed runAQI_out/*stat
echo -e "CRAQ analysis is finished. Check current directory runAQI_out for final results!\n"
