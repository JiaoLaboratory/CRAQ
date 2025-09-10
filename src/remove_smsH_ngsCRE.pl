#use Data::Dumper;
my ($smsH,$lrfilter_cre)=($ARGV[0],$ARGV[1]);
open IN1,$smsH;
while (<IN1>){chomp;
my ($chr,$pos,$stran,$dinum,$dep,$dilen,$diclass,$disame)=(split/\s+/)[0,1,2,3,4,5,6,7];
next if($dep<1);
my $ratio=$dinum/$dep;
if($dinum>=3 && $ratio >0.25 && $ratio <=0.8 && $dilen >=3 && $disame >0.6  ){
    if($diclass eq "D"){
    my $pos1=$pos-10;
    my $pos2=$pos+$dilen+10;
    for my $i($pos1..$pos2){$hashH{"$chr\t$i"}=1;}
   }
   if($diclass eq "I"){
    my $pos1=$pos-10;
    my $pos2=$pos+10;
    for my $i($pos1..$pos2){$hashH{"$chr\t$i"}=1;}
   }
}
}
open IN2,$lrfilter_cre;
while (<IN2>){chomp;
my ($chr,$pos,$stran,$clipnum,$dep)=(split/\s+/)[0,1,2,3,4];
 for my $i($pos1..$pos2){
    if (not defined $hashH{"$chr\t$pos"}) {
   print "$_\n";  
	}
}
}
