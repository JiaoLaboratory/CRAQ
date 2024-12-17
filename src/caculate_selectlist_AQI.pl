#!/usr/bin/perl
#use Data::Dumper;
my ($eff_size,$report,$yourlist)=($ARGV[0],$ARGV[1],$ARGV[2]);

open IN1,$eff_size;
while (<IN1>){
    chomp;
    my ($chr,$size)=(split/\s+/)[0,1];
    $hash{$chr}=$size/1000000;}

open IN3,$yourlist;
while (<IN3>){
    chomp;
    my ($chr)=(split/\s+/)[0];
    $hash1{$chr}=$hash{$chr};
    $sum=$sum+$hash{$chr};}

#print Dumper\%hash1;
open IN2,$report;
while (<IN2>){
   chomp;
    next if(/^Short Report:/) ;   next if(/^#Chr/) ;   next if(/^Genome/) ;
    my $avgcre; my $avgcse;
    my ($chr,$covrate,$lowrate,$avgcrh,$avgcsh, $list6,$list7)=(split/\s+/);   
     next if($hash1{$chr}<1); 
     if ( defined $hash1{$chr}){# print "$hash1{$chr}\n";
    	if($list6=~/(\S+)\((\S+)\)/){  $avgcre=$1;  $raqi=$2 ;   }
    	if($list7=~/(\S+)\((\S+)\)/){  $avgcse=$1;  $saqi=$2 ;   }
       $total_cre=$total_cre+$avgcre*$hash1{$chr};
       $total_cse=$total_cse+$avgcse*$hash1{$chr};
       $total_cov=$total_cov+$covrate*$hash1{$chr};
       $total_lowrate=$total_lowrate+$lowrate*$hash1{$chr};
       $total_crh=$total_crh+$avgcrh*$hash1{$chr};
       $total_csh=$total_csh+$avgcsh*$hash1{$chr};
  }
}

       my $Avg_cov=$total_cov/$sum;
       my $Avg_lowrate=$total_lowrate/$sum;
       my $Avg_crh=$total_crh/$sum;
       my $Avg_csh=$total_csh/$sum;
       my $Avg_cre=$total_cre/$sum;
       my $Avg_cse=$total_cse/$sum;
       
       my $Avg_raqi=exp(-$Avg_cre/10)*100;
       my $Avg_raqi=sprintf "%.2f",$Avg_raqi;
       my $Avg_saqi=exp(-10*$Avg_cse/10)*100;
       my $Avg_saqi=sprintf "%.2f",$Avg_saqi;



print "Short Report:\n";
print "#Chr\tCovered.Rate\tLow-confident.Rate\tAvg.CRH\tAvg.CSH\tAvg.CRE(R-AQI)\tAvg.CSE(S-AQI)\n";
print "Genome\t$Avg_cov\t$Avg_lowrate\t$Avg_crh\t$Avg_csh\t$Avg_cre($Avg_raqi)\t$Avg_cse($Avg_saqi)\n";



open IN2,$report;
while (<IN2>){
   chomp;
   next if(/^Short Report:/) ;   next if(/^#Chr/) ;   next if(/^Genome/) ;
    my ($chr,$covrate,$lowrate,$avgcrh,$avgcsh, $list6,$list7)=(split/\s+/);
    if ( defined $hash1{$chr}){ print "$_\n";
}}




