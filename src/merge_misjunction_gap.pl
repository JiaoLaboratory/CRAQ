#!/usr/bin/perl
#use Data::Dumper;
if (@ARGV != 2){print "USE:  merge misjoin gap  
      perl $0  misjoin_file  gap_file \n";
exit 1;
}else{

my ($mis_file,$gap_file)=($ARGV[0],$ARGV[1]);
open IN1,$mis_file;
while (<IN1>){
chomp;
my ($chr,$pos,$stran,$clipdep,$neighbordep)=(split/\s+/)[0,1,2,3,4];
my $value="$stran\t$clipdep\t$neighbordep";
$mis{"$chr--$pos"}=$value;
}
#print Dumper \%mis;
#######uniq
#for my $key( sort keys %mis){
# my ($chr,$pos)=(split/--/,$key)[0,1];
# next if(not defined $mis{"$chr--$pos"});
 #print "$chr\t$pos\t".$mis{"$chr--$pos"}."\n";
 #$final{"$chr--$pos"}=$mis{"$chr--$pos"};
 #for ($i=1;$i<=1000;$i++){
 # my $right=$pos+$i; #print "$right\n";
 # if ( defined $mis{"$chr--$right"} ){delete $mis{"$chr--$right"};}
 # }
#}

#print Dumper\%mis;
#print Dumper\%final;

open IN2,$gap_file;
while (<IN2>){
chomp;
my ($chr,$pos1,$pos2,$type)=(split/\s+/)[0,1,2,3];
$gap_s{"$chr--$pos1"}=$type;
$gap_e{"$chr--$pos2"}=$type;
$gap_s_e{"$chr--$pos1--$pos2"}=$pos1;
#$final{"$chr--$pos1"}=$type;
}

#trim Gap
for my $key( sort keys %mis){
 my ($chr,$pos)=(split/--/,$key)[0,1];
 for ($i=0;$i<=1000;$i++){
  my $left=$pos-$i;
  my $right=$pos+$i; #print "$right\n";
  if ( defined $gap_s{"$chr--$left"}  ){delete $mis{$key};}
  if ( defined $gap_s{"$chr--$right"}  ){delete $mis{$key};}
  if ( defined $gap_e{"$chr--$left"}  ){delete $mis{$key};}
  if ( defined $gap_e{"$chr--$right"}  ){delete $mis{$key};}
                       }}

for my $key( sort keys %mis){
 my ($chr,$pos)=(split/--/,$key)[0,1];
 next if(not defined $mis{"$chr--$pos"});
 my $value=$mis{"$chr--$pos"};
  $final{"$chr--$pos"}="$value\tClip";
}

for my $key( sort {$gap_s_e{$b}<=> $gap_s_e{$a} } keys %gap_s_e ){
 my ($chr,$pos1,$pos2)=(split/--/,$key)[0,1,2];
 for ($i=1;$i<=1000;$i++){
 my $tail=$pos1-$i;
 if(defined $gap_e{"$chr--$tail"}){delete $gap_s_e{$key};}
 }
}

for my $key( sort  keys %gap_s_e ){
if (defined  $gap_s_e{$key}){
my ($chr,$pos1)=(split/--/,$key)[0,1];
$final{"$chr--$pos1"}="*\t*\t*\tGap";
}
}


for my $key(sort  keys %final){
 my ($chr,$pos)=(split/--/,$key)[0,1];
#next if($size{$chr} < 500000); #filter the short contigs !
 print "$chr\t$pos\t$final{$key}\n";
 }

}


