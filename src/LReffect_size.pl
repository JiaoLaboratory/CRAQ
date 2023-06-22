#!/usr/bin/perl
my ($lrdep_file,$avgdep,$depratio)=($ARGV[0],$ARGV[1],$ARGV[2]);
open IN,$lrdep_file;
my $tmp_out="LRout/Nonmap.loc";
open OUT,">$tmp_out";

while (<IN>){
chomp;
my ($chr,$dep)=(split/\s+/,)[0,2];
if($dep < (int($avgdep*$depratio)+1)){
  print OUT "$_\n";}

 if ($dep >= 2){$depmin{$chr}++;}
}


for ( sort keys %depmin ){

print "$_\t$depmin{$_}\n";
}
close OUT;
