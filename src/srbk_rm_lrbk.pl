my ($lrbk_file,$srbk_file,$flank_len)=($ARGV[0],$ARGV[1],$ARGV[2]);

open IN0,$lrbk_file;

while(<IN0>){
chomp;
my ($lrchr,$lrbk)=(split/\s+/)[0,1];
 $lrhash{"$lrchr\t$lrbk"}=1;


}
close IN0;

open IN1,$srbk_file;
while(<IN1>){
chomp;
my ($srchr,$srbk)=(split/\s+/)[0,1];
  for my $lr(keys %lrhash){
   my ($lrchr,$lrbk)=(split/\s+/,$lr)[0,1];
    if($srchr eq $lrchr && abs($srbk-$lrbk)<=$flank_len){
	$srhash{"$srchr\t$srbk"}=0;
       last;}
   				}
	}

open IN1,$srbk_file;
while(<IN1>){
chomp;
my ($srchr,$srbk)=(split/\s+/)[0,1];
next if(defined $srhash{"$srchr\t$srbk"} );
print "$_\n";
}

close IN1;














