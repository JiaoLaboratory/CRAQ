open    IN,$ARGV[0];
while (my $line=<IN>){
chomp $line;
 if ($line=~/^@/){print "$line\n"}
 else{
my @arr=split/\t/,$line;
$a=@arr;
my($cigar)=$arr[5];
 $cigar =~s/([2-9]|[1-9][0-9]+)M(\d+)I/($1-1).M1D.($2+1).I/eg;
print "$arr[0]\t$arr[1]\t$arr[2]\t$arr[3]\t$arr[4]\t$cigar\t";
for (6..$a-2){print "$arr[$_]\t";}
print "$arr[-1]\n";
}
}

