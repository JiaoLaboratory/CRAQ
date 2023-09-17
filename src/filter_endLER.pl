my ($chrsize,$out_merge_strER,$win)=($ARGV[0],$ARGV[1],$ARGV[2]);
open IN,$chrsize;
while (<IN>){
chomp;
my ($chr,$size)=(split/\s+/)[0,1];
$len{$chr}=$size;
}

open IN1,$out_merge_strER;
while (<IN1>){
chomp;
my ($chr,$loc)=(split/\s+/)[0,1];
next if($loc < $win);
next if(abs($loc-$len{$chr}) <$win);
print "$_\n";

}

