#!/usr/bin/perl
#use Data::Dumper;
if (@ARGV != 3){print "USE: $0 LR_break.depth LR_sort.depth map\n";
exit 1;
}else{
my $map=$ARGV[2];
my ($LR_breakdepth,$pb_ont_depfile)=($ARGV[0],$ARGV[1]);

open LR_break,$LR_breakdepth;
while (<LR_break>){chomp;
my @arr=split/\t/;
my $line=join("===",@arr);
my ($chr,$pos,$stran)=($arr[0],$arr[1],$arr[2]);
push @{$breakdep{$chr}},$line;
}
#print Dumper\%breakdep;

open DEP,$pb_ont_depfile;
my %dep;
while (<DEP>){
chomp;
 my ($chr_now,$pos_now,$depth_now)=(split/\t/,)[0,1,2];
if($chr_now eq $chr_former) {$dep{$chr_now}{$pos_now}=$depth_now; }
if($chr_now ne $chr_former ) {
 for my $key(keys %breakdep){
  next if( not defined $dep{$key}) ;
   my @arr=@{$breakdep{$key}};
   for my $line(@arr){
   my ($chr,$pos,$stran,$bkdep)=(split/===/,$line)[0,1,2,3];
     my @left;
     my @right;
     for my $i(1..10){ 
      my $bkleft=$pos-$i;
      next if(not defined  $dep{$chr}{$bkleft} );
      my $bkright=$pos+$i; 
      next if(not defined $dep{$chr}{$bkright});
      push @left,$dep{$chr}{$bkleft};
      push @right,$dep{$chr}{$bkright}; }
     my $leftavg= avg  (@left) ; 
     my $leftavg=int($leftavg)+0.1;
     my $rightavg=avg (@right) ;
    my $rightavg= int($rightavg)+0.1;
#  print "$chr\t$pos\t@left===============@right\n";
#  print "left:$leftavg\tright:$rightavg\n";
     if($stran eq "-" && $map ne "map-ont" ) {  print "$chr\t$pos\t$stran\t$bkdep\t$rightavg\n"}
     if($stran eq "+" && $map ne "map-ont" ) {  print "$chr\t$pos\t$stran\t$bkdep\t$leftavg\n"}
     if($stran eq "-" && $map eq "map-ont" ) {  print "$chr\t$pos\t$stran\t$bkdep\t$leftavg\n"}
     if($stran eq "+" && $map eq "map-ont" ) {  print "$chr\t$pos\t$stran\t$bkdep\t$rightavg\n"}

                      }
  }
 %dep=();
}
 $chr_former =$chr_now;
}



 for my $key(keys %breakdep){
  next if( not defined $dep{$key}) ;
   my @arr=@{$breakdep{$key}};
   for my $line(@arr){
   my ($chr,$pos,$stran,$bkdep)=(split/===/,$line)[0,1,2,3];
     my @left;
     my @right;
     for my $i(1..10){
      my $bkleft=$pos-$i;
      next if(not defined  $dep{$chr}{$bkleft} );
      my $bkright=$pos+$i;
      next if(not defined $dep{$chr}{$bkright});
      push @left,$dep{$chr}{$bkleft};
      push @right,$dep{$chr}{$bkright}; }
     my $leftavg= avg  (@left) ;
     my $leftavg=int($leftavg)+0.1;
     my $rightavg=avg (@right) ;
     my $rightavg= int($rightavg)+0.1; 
     
     if($stran eq "-" && $map ne "map-ont" ) {  print "$chr\t$pos\t$stran\t$bkdep\t$rightavg\n"}
     if($stran eq "+" && $map ne "map-ont" ) {  print "$chr\t$pos\t$stran\t$bkdep\t$leftavg\n"}
     if($stran eq "-" && $map eq "map-ont" ) {  print "$chr\t$pos\t$stran\t$bkdep\t$leftavg\n"}
     if($stran eq "+" && $map eq "map-ont" ) {  print "$chr\t$pos\t$stran\t$bkdep\t$rightavg\n"}

                    
                      }
  }



sub avg{
 my @list =  @_;
 my $sum;
 my $count = @list;
 if( $count == 0 ){next;}
  for (@list){
  $sum=$sum+$_;}
  my $avg=$sum/$count;
  return $avg; }

}


