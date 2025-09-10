my ($sr_putative_er,$lr_putative_er,$dis)=($ARGV[0],$ARGV[1],$ARGV[2]);
open IN1,$sr_putative_er;
while (<IN1>){
chomp;
my ($srchr,$srloc)=(split/\s+/)[0,1];
$srhash{$srchr}{$srloc}=1;
}

open IN2,$lr_putative_er;
while (<IN2>){
chomp;
my ($lrchr,$lrloc)=(split/\s+/)[0,1];
  for  my $srchr(keys %srhash){
        next if($lrchr ne $srchr);
           for my $srloc( keys %{$srhash{$srchr}} ){
	              
	       if( abs($srloc-$lrloc)<=$dis  ){
		$lrhash{$_}=1;
		
	}
	}}}
		

close IN1;
close IN2;
for (keys  %lrhash){
print "$_\n";
}
