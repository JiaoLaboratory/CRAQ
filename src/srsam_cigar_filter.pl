my ($minq,$sam)=($ARGV[0],$ARGV[1]);
open IN,$sam;
my $seqlen=150;
#my $minq=20;
while (<IN>){
chomp;
if(/^\@/){print "$_\n"};
my ($mapq,$cigar)=(split/\t/,)[4,5];
#print "$cigar\n";
next if($cigar=~/^\d+[HS]/ && $cigar=~/[HS]$/);
if($cigar=~/^(\d+)M$/){my $matchlen=$1;
	
     if ($matchlen >= ($seqlen/2)  ) {print "$_\n"}
     if ($matchlen < ($seqlen/2) && $mapq > $minq ) {print "$_\n"}
} 
else {
    if($mapq  >= $minq) { print "$_\n";}
  }

}
