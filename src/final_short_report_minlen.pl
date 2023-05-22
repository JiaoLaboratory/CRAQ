#!/usr/bin/perl
#use Math::Complex;
#use Data::Dumper;
if (@ARGV != 3){print "USE: the final step to get the report \nperl $0  result_file rate[0.8] minctglen\n";
exit 1;
}else{
my ($result_file,$rate,$minlen)=($ARGV[0],$ARGV[1],$ARGV[2]);
open NAME,$result_file;
while (<NAME>){chomp;
next if/^#/;
my ($chr,$ctgsize,$ctgeffsize,$ctg_nor_ler,$ctg_nor_ser)=(split/\s+/)[0,1,2,7,8];
next if($ctgsize<$minlen);
$ctg_total_size=$ctg_total_size+$ctgsize;
$ctg_total_effsize=$ctg_total_effsize+$ctgeffsize;
$ctg_total_nor_ler=$ctg_total_nor_ler+$ctg_nor_ler;
$ctg_total_nor_ser=$ctg_total_nor_ser+$ctg_nor_ser;
}
my $totalctgratio=$ctg_total_effsize/($ctg_total_size+1);
my $avg_ctg_nor_ler_perM=$ctg_total_nor_ler/($ctg_total_size+1)*1000000;
my $avg_ctg_nor_ler_score=exp(-10*$avg_ctg_nor_ler_perM/10)*100;
my $avg_ctg_nor_ser_perM=$ctg_total_nor_ser/($ctg_total_size+1)*1000000;
my $avg_ctg_nor_ser_score=exp(-$avg_ctg_nor_ser_perM/10)*100;
my $ctg_wei=($ctg_total_nor_ser+$ctg_total_nor_ler*10)/$ctg_total_effsize*1000000;
my $total_corness_score_avg= exp(-$ctg_wei/30) *100;
print "Short Report:\n#Chr\tCovered.Rate\tAvg.SER\tAvg.LER\tWeight\tAQI\n";
print "Genome\t$totalctgratio\t$avg_ctg_nor_ser_perM($avg_ctg_nor_ser_score)\t$avg_ctg_nor_ler_perM($avg_ctg_nor_ler_score)\t$ctg_wei\t$total_corness_score_avg\n";

open NAME,$result_file;
while (<NAME>){chomp;
next if/^#/;
my ($chr,$size)=(split/\s+/)[0,1];
$totalsize=$totalsize+$size;
$size{$chr}=$size;
}
my %super;
for my $chr (sort { $size{$b} <=> $size{$a} } keys %size){
  if ($size{$chr} > $totalsize*$rate){$super{$chr}=1;}
  $sumsize=$sumsize+$size{$chr};
  if(  $sumsize <= $totalsize*$rate ){$super{$chr}=1;} }

open NAME,$result_file;
while (<NAME>){chomp;
next if/^#/;
my ($chr,$size,$effsize,$num_mis_junct,$numErr)=(split/\s+/,)[0,1,2,7,8];
next if(not defined $super{$chr});
$total_junct=$total_junct+$num_mis_junct;
#$total_numGap=$total_numGap+$numGap;
$total_numErr=$total_numErr+$numErr;

$all_size=$all_size+$size;
$all_effsize=$all_effsize+$effsize;
$all_effsize_rate=$all_effsize/($all_size+1);
}
#my $total_numGap_avg=$total_numGap/$all_size*1000000;
my $total_numErr_avg=$total_numErr/$all_effsize*1000000;
my $total_junct_avg=$total_junct/$all_effsize*1000000;
my $weight_ER_junct_avg=($total_numErr+$total_junct*10)/$all_effsize*1000000;
#my $total_contigy_score_avg=exp(-$total_numGap_avg/20) *100;
my $total_corness_score_avg= exp(-$weight_ER_junct_avg/30) *100;

#print "Short Report:\n#Chr\tCovered.Rate\tAvg.SER\tAvg.LER\tWeight\tAQI\n";
#print "Genome\t$all_effsize_rate\t$total_numErr_avg\t$total_junct_avg\t$weight_ER_junct_avg\t$total_corness_score_avg\n";


open IN,$result_file;
while (<IN>){chomp;
next if/^#/;
my ($chr,$size,$effsize,$num_mis_junct,$numErr)=(split/\s+/,)[0,1,2,7,8];
#my $avgGap=$numGap/$size*1000000;
my $effsize_rate=$effsize/($size+1);
my $avgnumErr=$numErr/$effsize*1000000;
my $avgnum_mis_junct=$num_mis_junct/$effsize*1000000;
my $avgweight=($numErr+$num_mis_junct*10)/$effsize*1000000;

my $avg_ctg_nor_ser_score=exp(-$avgnumErr/10)*100;
my $avg_ctg_nor_ler_score=exp(-10*$avgnum_mis_junct/10)*100;



#my $contigy_score=  exp(-$avgGap/10) *100;
my $corness_score=  exp(-$avgweight/30) *100;
$hash{$chr}={
	#line=>"$numGap\t$numErr\t$avgGap\t$avgErr\t$contigy_score\t$corness_score",
	line=>"$effsize_rate\t$avgnumErr\($avg_ctg_nor_ser_score\)\t$avgnum_mis_junct\($avg_ctg_nor_ler_score\)\t$avgweight\t$corness_score",
	score=>$corness_score  }
}

for ( sort{ $hash{$b}{score} <=> $hash{$a}{score} }  keys  %hash){
  print "$_\t$hash{$_}{line}\n";}


close IN;
close NAME;

}
