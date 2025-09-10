#use Data::Dumper;
my ($DI_covRate_f,$lrfilter_CRE_out,$stype,$cutoff_left,$cutoff_right)=($ARGV[0],$ARGV[1],$ARGV[2],$ARGV[3],$ARGV[4]);
open IN1,$DI_covRate_f;
while (<IN1>){chomp;
my ($chr,$pos,$stran,$dinum,$dep,$len,$class,$same)=(split/\s+/)[0,1,2,3,4,5,6,7];
my $new_cutoff_left=$cutoff_left;
my $rate=$dinum/$dep;
  if($stype eq "RE" && $dep <15) { my $new_cutoff_left=$cutoff_left;  if($rate > $new_cutoff_left && $rate <= $cutoff_right  ){print "$chr\t$pos\t$stran\t$dinum\t$dep\n";}    }

  if($stype eq "RE" && $dep >=15 && $dep <=40) { my $new_cutoff_left=$cutoff_left*1.15; if($new_cutoff_left >1){$new_cutoff_left=1;} if($rate >= $new_cutoff_left && $rate <= $cutoff_right  ){print "$chr\t$pos\t$stran\t$dinum\t$dep\n";}   }
   
  if($stype eq "RE" && $dep >40) { my $new_cutoff_left=$cutoff_left*1.2; if($new_cutoff_left >1){$new_cutoff_left=1;}
        if($rate >= $new_cutoff_left && $rate <= $cutoff_right  ){print "$chr\t$pos\t$stran\t$dinum\t$dep\n";}   }


 if($stype eq "RH" ){
  if($rate >= $cutoff_left && $rate <= $cutoff_right  ){print "$chr\t$pos\t$stran\t$dinum\t$dep\n";}}

}

open IN1,$DI_covRate_f;
while (<IN1>){
chomp;
my ($chr,$pos,$stran,$dinum,$dep,$len,$class,$same)=(split/\s+/)[0,1,2,3,4,5,6,7];
my $rate=$dinum/$dep;
next if ($rate <0.2 or $len<=5  );
if($class eq "D"){
my $pos1=$pos-10;
my $end1=$len+$pos+10;
	for my $i($pos1..$end1){$hash{$chr}{$i}=1;};
}
if($class eq "I"){
my $pos1=$pos-10;
my $end1=$pos+10;
   for my $i($pos1..$end1){$hash{$chr}{$i}=1;}
}
}
#print Dumper\%hash; 
open IN2,$lrfilter_CRE_out;
 while (<IN2>){chomp;
     my ($chr,$pos,$stran,$clipnum,$dep)=(split/\s+/)[0,1,2,3,4];
       if ( not defined $hash{$chr}{$pos}){print "$_\n";}	
 }


#print Dumper\%hash;





