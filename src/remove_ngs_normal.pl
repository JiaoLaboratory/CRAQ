#use Data::Dumper;
my ($covrate,$ngsdep0,$cre_file)=($ARGV[0],$ARGV[1],$ARGV[2]);

open IN1,$covrate;
while (<IN1>){chomp;
my ($chr,$pos,$cov,$depth)=(split/\s+/)[0,1,3,4];
next if($depth ==0);
my $rate=$cov/$depth;
if($rate >=0.1){
$hash{$chr}{$pos}=1;
}}

open IN2,$ngsdep0;
while (<IN2>){chomp;
my ($chr,$pos,$depth)=(split/\s+/)[0,1,2];
$hash{$chr}{$pos}=1;
}

open IN3,$cre_file;
while (<IN3>){chomp;
my ($chr,$pos)=(split/\s+/)[0,1,2];
my $poss=$pos-10;
my $pose=$pos+10;
for my $posi($poss..$pose){
     if(defined $hash{$chr}{$posi}){
     	 print "$_\n";
	last;
}

}}

