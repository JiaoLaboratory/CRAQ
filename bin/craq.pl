#!/usr/bin/env perl
use Getopt::Long;
use Pod::Usage;
#use Cwd qw/ abs_path /;
use FindBin qw/ $Bin /;
#use File::Basename qw/basename/;
my @argv           = @ARGV;
my $bin_path   = $Bin;

my $help           = 0;
my $min_ngs_clip_num =2;
my $ngs_clip_coverRate=0.75;

my $skewned_rate=0.1;
my $min_sms_clip_num =2; 
my $sms_clip_coverRate =0.65; 

my $he_cutoff_left=0.4;
my $he_cutoff_right=0.6;

my $gapmodel="F";
my $mincontigsize=1000000; 
my $break="F";
my $norm_window=50000;
my $regional_window=1000000; 
my $model;
my $min_gap_size=10;
my $sms_coverage=100;
my $ngs_coverage=100;
my $map="map-hifi";
my $thread=5;

my $msg            = "\nCRAQ Version: 1.0.8-alpha \n\nPlease provide appropriate parameters!\n\nUsage:\t $0  -g  genome_seq -z genome_seq.size -lr lr_sort.bam -sr  sr_sort.bam\n or\t $0  -g  genome_seq -z genome_seq.size -lr lr.fq.gz -sr  sr_pair1_fq.gz,sr_pair2_fq.gz \n";
my $usage="\nUsage:  perl $0 -g  genome_seq -z genome_seq.size -lr lr_sort.bam -sr  sr_sort.bam\nor\tperl $0 -g  genome_seq -z genome_seq.size -lr lr.fq.gz -sr sr_pair1_fq.gz,sr_pair2_fq.gz\n\n";

GetOptions(             'h|help'                      => \$help,
                        'g|genome=s'                  => \$genome_seq,
                        'z|genome_size=s'             => \$genome_size,
                        'lr|sms_input=s'              => \$long_input,
                        'sr|ngs_input=s'             => \$short_input,
			'sn|min_ngs_clip_num=i'           => \$min_ngs_clip_num,
			'ln|min_sms_clip_num=i'           => \$min_sms_clip_num,
                        'sf|ngs_clip_coverRate=f'             => \$ngs_clip_coverRate,
			'lf|sms_clip_coverRate=f'             => \$sms_clip_coverRate,
                        
			'hmin|he_min=f'             => \$he_cutoff_left,
			'hmax|he_max=f'             => \$he_cutoff_right,
			
			'd|skewned_rate=f'             => \$skewned_rate,
                        'rw|regional_window=i'           => \$regional_window,
			'avgl|sms_coverage:i'             => \$sms_coverage,
                        'avgs|ngs_coverage:i'             => \$ngs_coverage,
			'mgs|min_gap_size=i'		=>\$min_gap_size,
			'gm|gapmodel=i'		=>\$gapmodel,
			'b|break=s'		=>\$break,
			'x|map=s'             =>\$map,
                        't|thread:i'                      => \$thread,
                ) or pod2usage(2);
pod2usage(-msg=>$msg,-exitval=>1,-verbose=>99, -sections=>'NAME|SYNOPSIS|AUTHOR|CONTACT') if ($help);

if (-d "LRout")
{
   die "Error::cannot create directory, 'LRout' already exists, Exit !";}
if (-d "SRout")
{
   die "Error::cannot create directory, 'SRout' already exists, Exit !";}

my @num=(split/,/,$short_input);
my ($short_input1,$short_input2)=(split/,/,$short_input)[0,1];
         if ( ! -e $genome_seq ){print $usage;
                die "\nError: -g  genome_seq.fa file :$genome_seq doesn't exist, please check!\n\n" ;   }
         if ($genome_seq =~/\.tar$|\.gz$|\.zip$|\.bz2$|\.xz$/  ){
		die "\nError: -g  genome_seq.fa file :$genome_seq file require uncompressed, please check!\n\n" ; }
	 
         if ( ! -e $genome_size or -z $genome_size ){print $usage;
                die "\nError: -z  genome.size file :$genome_size doesn't exist, please check!\n\n";       }
         
	if ($long_input =~/fa$|fq$|fasta$|fastq$|bam$/i or $long_input =~/fa\.gz$|fq\.gz$|fasta\.gz$|fastq\.gz$/i ){
	 	if ($long_input =~/fa$|fq$|fasta$|fastq$/i or $long_input =~/fa\.gz$|fq\.gz$|fasta\.gz$|fastq\.gz$/i ){
		my @string=(split/,/,$long_input);
			for my $query(@string){if ( ! -e $query ){die "\nError: -lr SMS Reads(.fq) file  $query doesn't exist, please check !\n\n"}}
		                              	}

		if ( $long_input =~ /bam$/i){ my $long_input_index=$long_input.".bai";
			if(! -e $long_input_index){print $usage; die "\nError: $long_input_index is not found, cannot read index for $long_input,please check !\n\n";} }
		}else {die "\nError: -lr SMS Alignment(.bam) or Reads(.fq) suffix file are required, please check !\n\n";}


	if ( $short_input =~/fa$|fq$|fasta$|fastq$|bam$/i or $short_input =~/fa\.gz$|fq\.gz$|fasta\.gz$|fastq\.gz$/i ){
		if ( $short_input =~ /bam$/i   ){ my $short_input_index=$short_input.".bai";
                	if(! -e $short_input_index){print $usage; die "\nError: $short_input_index is not found, cannot read index for $short_input,please check !\n\n";}
                	}
	
		if ($short_input =~/fa$|fq$|fasta$|fastq$/i or $short_input =~/fa\.gz$|fq\.gz$|fasta\.gz$|fastq\.gz$/i ){ 
			my @num=(split/,/,$short_input);
			if (@num==0){die "\nError: -sr  NGS alignment(.bam) or reads(.fq):file doesn't exist, please check !\n\n"; }
			if(@num>=3){die "Error: pair1.fq,pair2.fq are supported; shortfq input can not be\t".@num."\n";}
	       		if(@num==2){ ($short_input1,$short_input2)=(split/,/,$short_input)[0,1];
				if(! -e $short_input1 or ! -e $short_input2){print $usage;die"\nError: -sr NGS Reads(.fq):$short_input file doesn't exist, please check !\n\n";   }}	
		
			if(@num==1){ $short_input1=$short_input;
                		if(! -e $short_input){print $usage;die"\nError: -sr NGS Reads(.fq):$short_input file doesn't exist, please check !\n\n";   }}

													}
	} else {die "\nError: -sr NGS Alignment(.bam) or Reads(.fq) suffix file are required, please check !\n\n";}

	if($min_ngs_clip_num <0  ){die "\nError: -sn  $ngs_clip_coverRate \n";}
	if($ngs_clip_coverRate <=0 or $ngs_clip_coverRate >1){die "\nError: -sf  $ngs_clip_coverRate not in (0,1)\n";}
	if($skewned_rate <0 or $skewned_rate >=1  ) {die "\nError: -d  $skewned_rate not in (0,1)\n";}
	if($min_sms_clip_num <0  ){die "\nError: -ln  $min_sms_clip_num \n";}	
        if($sms_clip_coverRate <=0  ) {die "\nError: -lf $sms_clip_coverRate not in (0,~)\n";}
  	#unless($map eq "map-pb" or $map eq "map-hifi" or $map eq "map-ont"){die "\nError: unknown preset -x $map\n";}
	if($min_gap_size < 0){die "\nError: -mgl $min_gap_size Minimum gapsize is wrong, please check\n";}

	#unless($gapmodel =~/[TF]/){die "\nError: $gapmodel -gm T or F\n";}
        if($gapmodel == 2){$model ="LER" } else {$gapmodel=1;$model ="SER";}
	unless($break =~/[TF]/){die "\nError: $break -bk T or F\n";}

	if($mincontigsize < 0){die "\nError: -ctgs $mincontigsize Minimum fragment size is wrong, please check\n";}
	if($regional_window < 10000){die "\nError: -rw $regional_window  Regional window (minimum 10000) is wrong, please check\n";}
	if($sms_coverage<=0){die "\nError: -avgl $sms_coverage SMS coverage is wrong, please check\n";}
        if($ngs_coverage<=0){die "\nError: -avgs $ngs_coverage NGS coverage is wrong, please check\n";}
	if($thread < 1  ){die "\nError: -t $thread \n";}
#if ( -d $tmp ){system ("rm -r tmp ")};

print "Running CRAQ analysis .........\nPARAMETERS:\n";
print "Genome sequence(-g): $genome_seq\n";
print "Genome sequence size(-z): $genome_size\n";
print "SMS input(-lr): $long_input\n";
print "NGS input(-sr): $short_input1  $short_input2\n";
print "Minimum NGS clipped-reads (-sn): $min_ngs_clip_num\n";
print "Minimum SMS clipped-reads (-ln): $min_sms_clip_num\n";
print "NGS clipping coverRate(-sf): $ngs_clip_coverRate\n";
print "SMS clipping coverRate(-lf): $sms_clip_coverRate\n";
print "Lower clipping rate for heterozygous allele(-hmin): $he_cutoff_left\n";
print "Upper clipping rate for heterozygous allele(-hmax): $he_cutoff_right\n";
print "Window benchmarking (-rw): $regional_window\n";
print "Gap[N] is treated with (-gm): $gapmodel:$model\n";
print "Minimum gapsize(-mgs): $min_gap_size\n";
print "Break chimera fragments (-b): $break\n";
print "Mapping SMS reads use (-x): $map\n";
print "Alignment thread(-t): $thread\n";

print "-------------------------Start Running------------------------\n";


print "\nRunning SMS long-reads CRAQ analysis ......\n";
print "CMD: $bin_path/../src/runLR.sh -g $genome_seq -x $map  -z $genome_size -1 $long_input  -m $min_sms_clip_num -f $he_cutoff_left -a $sms_coverage -t $thread \n";
system("bash $bin_path/../src/runLR.sh -g $genome_seq -x $map -z $genome_size  -1 $long_input -m $min_sms_clip_num -f $he_cutoff_left -a $sms_coverage -t $thread " );

print "Running NGS short-reads CRAQ analysis ......\n";

if(@num==2){
#print "$ngs_clip_coverRate\n";
print "CMD: $bin_path/../src/runSR.sh -g $genome_seq  -z $genome_size -1  $short_input1 -2 $short_input2 -m $min_ngs_clip_num -f $he_cutoff_left -a $ngs_coverage -t $thread \n";

system("bash $bin_path/../src/runSR.sh -g $genome_seq -z $genome_size  -1 $short_input1 -2 $short_input2 -m $min_ngs_clip_num -f $he_cutoff_left -a $ngs_coverage -t $thread ");}


if(@num==1){
#print "$ngs_clip_coverRate\n";
print "CMD: $bin_path/../src/runSR.sh -g $genome_seq  -z $genome_size -1  $short_input1 -m $min_ngs_clip_num -f $he_cutoff_left -a $ngs_coverage -t $thread\n";

system("bash $bin_path/../src/runSR.sh -g  $genome_seq  -z $genome_size  -1  $short_input1 -m $min_ngs_clip_num -f $he_cutoff_left -a $ngs_coverage -t $thread ");}


print "\nRunning CRAQ benchmark analysis ......\n";

print "CMD: $bin_path/../src/runAQI.sh -g  $genome_seq  -z $genome_size   -e SRout/SR_eff.size  -c SRout/SR_putative.ER.HR -C LRout/LR_putative.ER.HR -d SRout/SR_sort.depth -D LRout/LR_sort.depth -r $ngs_clip_coverRate -p $he_cutoff_left -q $he_cutoff_right -R $sms_clip_coverRate -P $he_cutoff_left -Q $he_cutoff_right -f $skewned_rate -n $min_gap_size -s $norm_window -w $regional_window  -m $mincontigsize  -j $gapmodel -b $break  \n";

system("bash $bin_path/../src/runAQI.sh -g $genome_seq  -z $genome_size   -e SRout/SR_eff.size  -c SRout/SR_putative.ER.HR -C LRout/LR_putative.ER.HR -d SRout/SR_sort.depth -D LRout/LR_sort.depth -r $ngs_clip_coverRate -p $he_cutoff_left -q $he_cutoff_right -R $sms_clip_coverRate -P $he_cutoff_left -Q $he_cutoff_right -f $skewned_rate -n $min_gap_size -s $norm_window -w $regional_window  -m $mincontigsize -j $gapmodel -b $break ");



__END__

=head1 NAME

	Genome benchmarking using CRAQ

=head1 SYNOPSIS

  craq [options] -g genome.fa -z genome.fa.size  -lr SMS_sort.bam -sr NGS_sort.bam

 Options:

  ***Help
        --help|-h             		Print the help message and exit.

  ***Required parameters
        --genome|-g           		Assembly sequence file (.fa)
        --genome_size|-z      		Size file of the assembly sequence (.size)
	--sms_input|-lr      		SMS long-read alignment(.bam) or sequences(.fq.gz)
        --ngs_input|-sr      		NGS short-read alignment(.bam) or sequences(.fq.gz), separated with comma if paired
  ***Filter parameters
	--min_ngs_clip_num|-sn		Minimum number of NGS clipped-reads. Default: 2
        --ngs_clip_coverRate|-sf	Minimum proportion of NGS clipped-reads. Default: 0.75
	--min_sms_clip_num|-ln		Minimum number of SMS clipped-reads. Default: 2
	--sms_clip_coverRate|-lf	Minimum proportion of SMS clipped-reads. Default: 0.65
	--he_min|-hmin			Lower clipping rate for heterozygous allele. Default: 0.4
	--he_max|-hmax			Upper clipping rate for heterozygous allele. Default: 0.6
	--min_gap_size|-mgs		Gap[N] length greater than the threshold will be treated as breakage. Default: 10
	--sms_coverage|-avgl		Average SMS coverage. Default: 100
	--ngs_coverage|-avgs		Average NGS coverage. Default: 100
  ***Other parameters
	--gapmodel|-gm			Gap[N] is treated as 1:SER 2:LER. Default: 1
	--regional_window|-rw		Regional quality score. Default: 1000000
	--break|-b			Break chimera fragment. Default: F
	--map|-x			Mapping use map-pb/map-hifi/map-ont for PacBio CLR/HiFi or Nanopore vs reference [ignored if .bam provided]. Default: map-hifi
        --thread|-t			The number of thread used in alignment. Default: 5
