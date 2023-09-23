#use Data::Dumper;
my ($DIcovRate,$gapfile,$out)=($ARGV[0],$ARGV[1],$ARGV[2]);

open IN1,$DIcovRate;
while (<IN1>){
chomp;
my ($chr,$pos,$class,$len)=(split/\s+/)[0,1,6,5];
if($class eq "D"){
my $end=$len+$pos;
$hash{"$chr\t$pos"}="$chr\t$pos\t$end\t$len";
}
if($class eq "I"){
my $end=$pos;
$hash{"$chr\t$pos"}="$chr\t$pos\t$end\t$len";}}

open IN2,$gapfile;
while (<IN2>){
chomp;
my ($chr,$pos,$end)=(split/\s+/)[0,1,2];
my $len=$end-$pos+1;
$hash{"$chr\t$pos"}="$chr\t$pos\t$end\t$len";
}

open IN3,$out;
while (<IN3>){
chomp;
my ($chr,$pos)=(split/\s+/)[0,1];
my $value=$hash{"$chr\t$pos"};
my ($chr1,$pos1,$end1,$len)=(split/\s+/,$value)[0,1,2,3];
if(defined $hash{"$chr\t$pos"})    {print "$chr\t$pos\t$end1\t$chr:$pos\n";}
if(not defined $hash{"$chr\t$pos"}){print "$chr\t$pos\t$pos\t$chr:$pos\n";}
}

#print Dumper\%hash;

