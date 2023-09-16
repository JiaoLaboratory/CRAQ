open IN,$ARGV[0];
while (<IN>){
chomp;

my $cigar=(split/\t/,)[5];
if($cigar=~/^\d+[H|S]/ && $cigar=~/[H|S]$/) {
	my $sum;
	my @n=$cigar=~/\d+/g; 
	for my $i(@n){$sum=$sum+$i};
	my $sta=$n[0]*50 ;my $end=$n[-1]*50; 
	my $map=$sum-$n[0]-$n[-1];
	next if($map*20 <$sum);
	next if($sta>$sum && $end>$sum);            };

print "$_\n";
}
