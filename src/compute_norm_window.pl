my ($sizefile)=($ARGV[0]);
open IN,$ARGV[0];
while (<IN>){
my $num=(split/\s+/,)[$col-1];
 $sum=$sum+$num;
 }

my $norm_window=int($sum*0.0001);
 print "$norm_window";
 
