#!/usr/bin/perl
if (@ARGV != 1){print "USE: get the gap position(Start and end position defaults to gap!)\n  perl $0  fasta_file \n";
exit 1;
}else
{

my ($fasta_file)=$ARGV[0];
open IN,"$fasta_file";
while (<IN>){
chomp;
if (/\>(\S+)/){$key= $1;}
else {$hash{$key}.=uc $_;}
}

my $bin=2;
my $step=1;
for $contig(sort keys %hash){
 my $conlen=length $hash{$contig};
 if($hash{$contig}=~/^N/){print "$contig\t1\t";}
 if($hash{$contig}=~/^[ATCG]/){print "$contig\t1\t1\tGap\n";}
  for ($start=0;$start<($conlen-$step);$start=$start+$step){
   my $subread= substr($hash{$contig},$start,$bin );
   my ($posstart,$posend)=($start+1,$start+$bin);
   if ($posend >= $conlen){$posend=$conlen;}
      
      if ($subread=~/[ATCG]N/){print "$contig\t$posend\t";}
      if ($subread=~/N[ATCG]/){print "$posstart\tGap\n";}
   }
if($hash{$contig}=~/N$/){print "$conlen\tGap\n";}
if($hash{$contig}=~/[ATCG]$/){print "$contig\t$conlen\t$conlen\tGap\n";}
 
}
}
