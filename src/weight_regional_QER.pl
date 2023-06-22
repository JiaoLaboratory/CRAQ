#!/usr/bin/perl
#use Data::Dumper;

if (@ARGV != 4){print "USE: this is a script to Calculate regional_QCR in a specific block !\n$0 chrsize_file  block_size step  tmp_NER.stat \n";exit 1;}
else{

my ($chrsize_file,$blocksize,$step,$feature_loc_file)=($ARGV[0],$ARGV[1],$ARGV[2],$ARGV[3]);
open IN1,$chrsize_file;
while(<IN1>){
chomp;
my ($chr,$chrsize)=(split/\s+/)[0,1];
my $blocknum=$chrsize/$step;
for($i=0;$i<= int($blocknum);$i++){
my $start=$i*$step;
my $end=$start+$blocksize;
if ($end >$chrsize ){$end=$chrsize+1;}
my $block_s_e=join("\t",$chr,$start,$end);
$hash{$chr}{$block_s_e}={
	"ER"=>0,
	"norm_ER"=>0,
	"Misjuc"=>0,
	"norm_Misjuc"=>0,
	"weight_ER_Misjuc"=>0,
	}
}}
#print Dumper \%hash;

open IN,$feature_loc_file;
while($feature_loc=<IN>){
chomp $feature_loc;

my ($feature_chr,$feature_s,$ER_num,$norm_ER_num,$misj_num,$norm_misj_num)=(split/\s+/,$feature_loc)[0,1,4,6,3,5];

	foreach my $chr(keys %hash){
	 next if($feature_chr ne  $chr);
	   my %chrhash=%{$hash{$chr}};
		foreach  my $block(keys %chrhash){
	my ($block_chr,$block_s,$block_e)=(split/\s+/,$block)[0,1,2];
     # next if($feature_chr ne  $block_chr );
    if($feature_s >= $block_s && $feature_s<$block_e ){
	$hash{$chr}{$block}{"weight_ER_Misjuc"}=$hash{$chr}{$block}{"weight_ER_Misjuc"}+$norm_ER_num+5*$norm_misj_num; 
	$hash{$chr}{$block}{"ER"}=$hash{$chr}{$block}{"ER"}+$ER_num;
	$hash{$chr}{$block}{"Misjuc"}=$hash{$chr}{$block}{"Misjuc"}+$misj_num;
	$hash{$chr}{$block}{"norm_ER"}=$hash{$chr}{$block}{"norm_ER"}+$norm_ER_num;
	$hash{$chr}{$block}{"norm_Misjuc"}=$hash{$chr}{$block}{"norm_Misjuc"}+$norm_misj_num;
		
 }
    }
		}}
#print "CHR\tBlocks\tBlocke\tER#\tQER\n";
print "CHR\tBlocks\tBlocke\tNO.SER\tNO.LER\tNO.norm.SER\tNO.norm.LER\tWeight\tAQI\n";
for my $chr(sort keys %hash){
   for my $block( sort keys %{$hash{$chr}}){
my $value=$hash{$chr}{$block}{"weight_ER_Misjuc"};
my $local_er_num=$hash{$chr}{$block}{"ER"};
my $norm_local_er_num=$hash{$chr}{$block}{"norm_ER"};
my $struc_er_num=$hash{$chr}{$block}{"Misjuc"};
my $norm_struc_er_num=$hash{$chr}{$block}{"norm_Misjuc"};

my $qer= exp(-$value/10) *100;

print "$block\t$local_er_num\t$struc_er_num\t$norm_local_er_num\t$norm_struc_er_num\t$value\t$qer\n";
}
 
 }

}

