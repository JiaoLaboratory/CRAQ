#!/usr/bin/perl

#use Data::Dumper;
if (@ARGV != 2){print "USE: Break the rawcontig.fa at the potential chimera location \n   $0  raw_contig.fa  chimera_position.out \n";
exit 1;
}else
{
my ($infa_file,$chimera_pos_file)=($ARGV[0],$ARGV[1]);
open (IN1,$infa_file)or die("Can not open the fasta file!$!");
my %fasta;
while (<IN1>){
chomp;
if(/>(\S*).*/){$chr=$1;}
else{$fasta{$chr}.=$_;}
}
my %bkpos;
foreach $key ( sort keys  %fasta){
my $len=length $fasta{$key};
$chrlen{$key}=$len;
push @{$bkpos{$key}},1,$len;

}
#Extract eligible breakpoints
open (IN2,$chimera_pos_file)or die("$!");
while ($line=<IN2>){
chomp $line;
my ($chr,$pos)=(split/\s+/,$line)[0,1];
next if($pos == $chrlen{$chr});
next if($pos ==1);
push @{$bkpos{$chr}},$pos;
}
#print Dumper\%bkpos;
for my $chr(sort keys %bkpos ) {
 my @arr=sort{$a<=>$b}  @{$bkpos{$chr}};
 my $num=@arr;
  for my $i(0..$num-2) {
  my ($start,$end )=($arr[$i],$arr[$i+1]);
   if ($start ==1){$start=1;}
   if($start != 1){ $start++;}
  #print "$chr\t$start\t$end\n";
  my $extract_fa=substr($fasta{$chr},$start-1,$end-$start+1);
  print ">$chr\_$start\_$end\n$extract_fa\n";
  }
}
}
