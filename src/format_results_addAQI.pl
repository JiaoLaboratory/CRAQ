#!/usr/bin/perl
my ($file)=$ARGV[0];
open IN1,$file;
  

 print "Short Report:\n" ;
 print "#Chr\tCovered.Rate\tLow-conf.Rate\tAvg.CRH\tAvg.CSH\tAvg.CRE(R-AQI)\tAvg.CSE(S-AQI)\tAQI\n";

 while (<IN1>){
	chomp;
        next if/^[Short|#]/; 
 

 my ($chr,$cov,$lowf,$crh,$csh,$cre_raqi,$cse_saqi)=(split/\s+/);
 my $cre_1;
 my $raqi_1;
 my $cse_1;
 my $saqi_1;
	if ($cre_raqi=~/(\S+)\((\S+)\)/){ ($cre_1,$raqi_1)= ($1,$2) ;}
	if ($cse_saqi=~/(\S+)\((\S+)\)/){ ($cse_1,$saqi_1)= ($1,$2) ;}
	 my $cov_new  = sprintf("%.3f", $cov);
	 my $lowf_new = sprintf("%.3f", $lowf);
 	 my $crh_new  = sprintf("%.3f", $crh);
	 my $csh_new  = sprintf("%.3f", $csh);
         my $cre_new  = sprintf("%.3f", $cre_1);
         my $raqi_new = sprintf("%.3f", $raqi_1);
         my $cse_new  = sprintf("%.3f", $cse_1);
         my $saqi_new = sprintf("%.3f", $saqi_1);
my $aqi=  sprintf("%.3f",2*$saqi_new*$raqi_new/($saqi_new+$raqi_new));

print "$chr\t$cov_new\t$lowf_new\t$crh_new\t$csh_new\t$cre_new\($raqi_new\)\t$cse_new\($saqi_new\)\t$aqi\n";
 
}
