#use Data::Dumper;
open IN0,$ARGV[0];
while (<IN0>){
chomp;
my ($chr,$s,$e)=(split/\s+/)[0,1,2];

if(($e-$s)>=500){$dep0bed{"$chr\t$s\t$e"}=0}
}

open IN1,$ARGV[1];
while (<IN1>){
chomp;
my ($chr,$error_loc)=(split/\s+/)[0,1];
$hash{$chr}{$error_loc}=1;}

for my $line(keys %dep0bed){
my $dis=50;
my ($chr,$s,$e)=(split/\s+/,$line)[0,1,2];
	for my $error_chr(keys %hash){
        next if($chr ne $error_chr );
         for my $error_loc (keys %{$hash{$error_chr}}){
        if($error_loc <= ($e+$dis) && $error_loc >=($s-$dis) ){
       $common{"$chr\t$s\t$e"}=1;
       }
       }

}
}
close IN1;
close IN2;
#print Dumper\%common;

for my $line(keys %dep0bed){
my ($chr,$s,$e)=(split/\s+/,$line)[0,1,2];
#next if(($e-$s)<10000);
if(not defined $common{"$chr\t$s\t$e"}){
print "$chr\t$s\t$e\n";

}
}
close IN3;




