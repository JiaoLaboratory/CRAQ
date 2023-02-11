#!/usr/bin/perl
if (@ARGV != 2){print "perl $0  SR_dep_file LR_cover_file \n";
exit 1;
}else{

my ($sr_dep,$lrcover_rate)=($ARGV[0],$ARGV[1]);
#my ($sr_dep,$sr_cover_filterfile,$persu_misjoin_file)=($ARGV[0],$ARGV[1],$ARGV[2]);
open SRDEP,$sr_dep;

while(<SRDEP>){
chomp;
my ($chr,$pos,$dep)=(split/\s+/,)[0,1,2];
if($dep ==0){$dep0{"$chr--$pos"}=0;}
}

#open IN2,$sr_cover_filterfile;
#while(<IN2>){
#chomp;
#my ($chr,$pos)=(split/\s+/,)[0,1];
#$cover{"$chr--$pos"}=0;
#}
open COVRATE,$lrcover_rate;
while(<COVRATE>){
chomp;
my ($chr,$pos,$stran,$bkdep,$all_dep)=(split/\s+/,)[0,1,2,3,4];
#next if($bkdep *10 <$all_dep);
my $leftnum0;
my $rightnum0;
     for my $i(1..1500){
     my $left=$pos-$i;
     my $right=$pos+$i;
    #if(defined  $cover{"$chr--$left"} or defined  $cover{"$chr--$right"}) {print "$_\tpersudo_misjoin\n"; last}
    if( defined $dep0{"$chr--$left"} ){
      $leftnum0++;  if( $leftnum0 >=10 && $leftnum0*10 > $i){ print "$_\n"; last}
    }
   if( defined $dep0{"$chr--$right"} ){
      $rightnum0++;  if( $rightnum0 >=10 && $rightnum0*10 > $i){ print "$_\n"; last}
    }

}

}}
