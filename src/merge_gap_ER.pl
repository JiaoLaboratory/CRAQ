#!/usr/bin/perl
#use Data::Dumper;
if (@ARGV != 2){print "USE:  merge gap localerr 
      perl $0    gap_file  local_err_file \n";
exit 1;
}else{

my ($gap_file,$err_file)=($ARGV[0],$ARGV[1],$ARGV[2]);

open IN1,$gap_file;
while (<IN1>){
chomp;
my ($chr,$pos1,$pos2,$type)=(split/\s+/)[0,1,2,3];
$gap_s{"$chr--$pos1"}=$type;
$gap_e{"$chr--$pos2"}=$type;
$gap_s_e{"$chr--$pos1--$pos2"}=$pos1;
#$final{"$chr--$pos1"}=$type;
}


open IN2,$err_file;
while (<IN2>){
chomp;
my ($chr,$pos)=(split/\s+/)[0,1];
$err{"$chr--$pos"}="ER";
}

for my $key( sort keys %err){
 my ($chr,$pos)=(split/--/,$key)[0,1];
 for ($i=0;$i<=1000;$i++){
  my $left=$pos-$i;
  my $right=$pos+$i; #print "$right\n";
  if ( defined $gap_s{"$chr--$left"}  ){delete $err{$key};}
  if ( defined $gap_s{"$chr--$right"}  ){delete $err{$key};}
  if ( defined $gap_e{"$chr--$left"}  ){delete $err{$key};}
  if ( defined $gap_e{"$chr--$right"}  ){delete $err{$key};}
                       }}
#print Dumper\%err;
#######err_uniq
for my $key( sort keys %err){
 my ($chr,$pos)=(split/--/,$key)[0,1];
 next if(not defined $err{"$chr--$pos"});
# print "$chr\t$pos\t".$err{"$chr--$pos"}."\n";
 $final{"$chr--$pos"}=$err{"$chr--$pos"};
  for ($i=1;$i<=1000;$i++){
    my $right=$pos+$i; #print "$right\n";
      if ( defined $err{"$chr--$right"} ){delete $err{"$chr--$right"};}
        }
        }
######gap_uniq

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
$final{"$chr--$pos1"}="Gap";
}
}


for my $key(sort  keys %final){
 my ($chr,$pos)=(split/--/,$key)[0,1];
 print "$chr\t$pos\t$final{$key}\n";
 }

}

