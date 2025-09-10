my ($out_dir,$seqsize,$depth)=($ARGV[0],$ARGV[1],$ARGV[2]);
open IN1,$seqsize;
while (<IN1>){
chomp;
my ($size)=(split/\s+/)[-1];
$chrsize=$chrsize+$size+1;
}

open IN2,$depth;
while (<IN2>){
chomp;
my ($depth)=(split/\s+/)[-1];
 $total_dep=$total_dep+$depth;
print "$_\n";
}



my $dir = $out_dir;       # 目录名
my $filename = "Avgcov"; # 文件名
my $filepath = "$dir/$filename"; # 完整路径

open(my $fh, '>', $filepath);

#open OUT,">$tmp_out";
my $avgcov=int($total_dep/$chrsize+1);
print $fh "$avgcov\n";
close $fh;



