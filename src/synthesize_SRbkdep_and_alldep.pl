#!/usr/bin/perl
if (@ARGV != 2){print "\nUSE: this script is to combian breakpoint depth and total_depth \n \nperl $0  SR_break.depth SR_sort.depth - > my.cover_rate\n\n";
exit 1;
}else
{
my($bk_depth_file,$depth_file)=($ARGV[0],$ARGV[1]);
open IN0,$bk_depth_file;
my %bk;
while (my $line=<IN0>){
chomp $line;
if($line=~/(\S+)\t(\d+)\t(\S+)\t(\d+)/){
$bk{"$1\t$2\t$3"}=$4;}
      }
close IN0;
#for  my $key(keys %bk){
#print "$key\t$bk{$key}\n";
#}
open IN1,$depth_file;
while(my $line2=<IN1>){
chomp $line2;
if($line2=~/(\S+)\t(\d+)\t(\d+)/){my $key1="$1\t$2\t\+"; my $key2="$1\t$2\t\-";  my $depth=$3;
 if(defined $bk{$key1}   ) {print "$key1\t$bk{$key1}\t$depth\n";}
 if(defined $bk{$key2}   ) {print "$key2\t$bk{$key2}\t$depth\n";}

}}
close IN1;
}
