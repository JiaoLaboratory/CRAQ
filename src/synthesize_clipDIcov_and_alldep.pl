#!/usr/bin/perl
if (@ARGV != 2){print "\nUSE: this script is to combian breakpoint depth and total_depth \n \nperl $0  break.cov depth - > my.cover_rate\n\n";
exit 1;
}else
{
my($bk_depth_file,$depth_file)=($ARGV[0],$ARGV[1]);
open IN0,$bk_depth_file;
my %bk;
while (my $line=<IN0>){chomp $line;
my ($chr,$DIpos,$stran,$DInum,$DIlen,$class,$DIsame_num)=(split/\s+/,$line)[0,1,2,3,4,5,6];
next if($DInum<3 or $DIsame_num<0.6);
$bk{"$chr\t$DIpos\t$stran"}=$DInum;
$bk_tmp{"$chr\t$DIpos\t$stran"}="$DIlen\t$class\t$DIsame_num";}
close IN0;

#for  my $key(keys %bk){
#print "$key\t$bk{$key}\n";
#}

open IN1,$depth_file;
while(my $line2=<IN1>){
chomp $line2;
if($line2=~/(\S+)\t(\d+)\t(\d+)/){my $key1="$1\t$2\t\+"; my $key2="$1\t$2\t\-";  my $depth=$3;
next if ($depth ==0) ;
if(defined $bk{$key1}   ) {
next if($bk{$key1}/$depth <0.2);
print "$key1\t$bk{$key1}\t$depth\t$bk_tmp{$key1}\n";}
 #if(defined $bk{$key2}   ) {print "$key2\t$bk{$key2}\t$depth\n";}

}}
close IN1;
}
