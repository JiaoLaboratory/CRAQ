#!/usr/bin/perl
#use Data::Dumper;
if (@ARGV != 1){print "\nUSE: this script is to caculate  the breakpoint depth \n \n samtools view  my.bam -@ 10 | perl lkp_intergrate_breakpoint_and_min3depth.pl  - > my.breskcover\n\n";
exit 1;
}else
{
open IN,$ARGV[0];
while (my $line=<IN>){
chomp $line;
next if ($line=~/^@/);
my( $readid,$chr,$start,$cigar)=(split/\t/,$line)[0,2,3,5];
 my $raw=$cigar;

$cigar =~ s/\d+S|\d+I|\d+H//g;
my @arr=split/\M|\D/,$cigar;
#print "@arr\n\n\n";
my $sum;
my $start_order;
my $end_order;
  for  my $i(@arr){  $sum=$sum+$i;}
	my $end=$start+$sum-1;
  if($raw=~/^\d+[SH]/){
	 $start_order="-";
	my $chr_start_order=$chr."\t".$start."\t".$start_order; 
	$hash{$chr_start_order}++ ;	
	push @{$hashread{$chr_start_order}},$readid;
 }
   if($raw=~/^\d+[MD]/){ $start_order="no";}
   if($raw=~/\d+[SH]$/){
	$end_order="+";
	my $chr_end_order=$chr."\t".$end."\t".$end_order;	
	$hash{$chr_end_order}++ ;
        push @{$hashread{$chr_end_order}},$readid;
}
if($raw=~/\d+[MD]$/){ $end_order="no";}
#print "$chr\t$start\t$start_order\t$end\t$end_order\n";

}
for my $key(map { $_->[0] }
             sort { $a->[1] cmp $b->[1] || $a->[2] <=> $b->[2] }
             map { [ $_, split /\t/, $_ ] } keys %hash){
#next if($hash{$key}<=3);
print "$key\t$hash{$key}\t";
my @readarr= @{$hashread{$key}};
  # my $readlist=join (" ",@readarr);
print "@readarr\n";
}

}
