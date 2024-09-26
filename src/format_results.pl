#!/usr/bin/perl
my ($file)=$ARGV[0];
open IN1,$file;
 while (<IN1>){
	chomp;
       if($_=~/^[Short|#]/){print "$_\n"}else {
 

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
         my $raqi_new = sprintf("%.2f", $raqi_1);
         my $cse_new  = sprintf("%.3f", $cse_1);
         my $saqi_new = sprintf("%.2f", $saqi_1);
print "$chr\t$cov_new\t$lowf_new\t$crh_new\t$csh_new\t$cre_new\($raqi_new\)\t$cse_new\($saqi_new\)\n";
 
}
}
