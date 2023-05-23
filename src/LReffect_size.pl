#!/usr/bin/perl
my $srdep=($ARGV[0]);
open IN,$srdep;
my $tmp_out="LRout/Nonmap.loc";
open OUT,">$tmp_out";

while (<IN>){
chomp;
my ($chr,$dep)=(split/\s+/,)[0,2];
 if($dep == 0){print OUT "$_\n";}

 if ($dep >= 2){$depmin{$chr}++;}
}


for ( sort keys %depmin ){

print "$_\t$depmin{$_}\n";
}
close OUT;
