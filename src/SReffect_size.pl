#!/usr/bin/perl
my $srdep=($ARGV[0]);
open IN,$srdep;
while (<IN>){
chomp;
my ($chr,$dep)=(split/\s+/,)[0,2];
 if ($dep >= 2){$depmin{$chr}++;}
}


for ( sort keys %depmin ){

print "$_\t$depmin{$_}\n";
}

