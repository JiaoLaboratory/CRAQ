my ($sr_putative_er,$dep0_file)=($ARGV[0],$ARGV[1]);
open IN1,$sr_putative_er;
while (<IN1>){
chomp;
print "$_\n";
my ($srchr,$srloc)=(split/\s+/)[0,1];
$srhash{$srchr}{$srloc}=1;
}


open IN2,$dep0_file;
while (<IN2>){
chomp;
$dep0hash{$_}=1;
 my ($dep0chr,$dep0loc)=(split/\s+/)[0,1];
  for  my $srchr(keys %srhash){
        next if($dep0chr ne $srchr);
           for my $srloc( keys %{$srhash{$srchr}} ){
	              
	       if( abs($srloc-$dep0loc)<=10  ){
		$dep0hash{$_}=0;
		
	}
	}}}
close IN1;
close IN2;




   for (keys  %dep0hash){
next  if ($dep0hash{$_} ==0);
print "$_\t0\n";}

