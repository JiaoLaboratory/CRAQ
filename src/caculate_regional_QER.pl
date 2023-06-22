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
$hash{$block_s_e}=0;
#print "$block_s_e\n";
}}
#print Dumper \%hash;

open IN,$feature_loc_file;
while($feature_loc=<IN>){
chomp $feature_loc;
#my @feature_loc=split/\s+/,$feature_loc;
my ($feature_chr,$feature_s,$value)=(split/\s+/,$feature_loc)[0,1,-1];
 #print "$feature_chr\t$feature_s\t$feature_e"."\n";
	foreach $block(keys %hash){
	my ($block_chr,$block_s,$block_e)=(split/\s+/,$block)[0,1,2];
#print "$block_chr\t$block_s\t$block_e"."\n";
      next if($feature_chr ne  $block_chr );
    if($feature_s >= $block_s && $feature_s<$block_e ){$hash{$block}=$hash{$block}+$value;  }
    }
		}
print "CHR\tBlocks\tBlocke\tER#\tQER\n";
for (sort keys %hash){

my $value=$hash{$_};

my $qcr= exp(-$value/20) *100;

print "$_\t$value\t$qcr\n";
}
 
 }



