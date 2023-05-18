open IN1,$ARGV[0];
while (<IN1>){
chomp;
my ($chr,$error_loc)=(split/\s+/)[0,1];
$hash{$chr}{$error_loc}=1;}

open IN2,$ARGV[1];
my $dis=0;
while (<IN2>){
chomp;
my ($chr,$s,$e)=(split/\s+/)[0,1,2];
	for my $error_chr(keys %hash){
        next if($chr ne $error_chr );
         for my $error_loc (keys $hash{$error_chr}){
        if($error_loc <= ($e+$dis) && $error_loc >=($s-$dis) ){
       $common{$_}=1;
       }
       }

}
}

open IN2,$ARGV[1];
while (<IN2>){
chomp;
if(not defined $common{$_}){
print "$_\n";


}
}





