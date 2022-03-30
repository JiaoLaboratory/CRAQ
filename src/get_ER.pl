#!/usr/bin/perl
#use Data::Dumper;
if (@ARGV != 5){print "USE: $0 pb/ont_depth_file   NGS_coverrate.file   window_size    window_extend_num   threshold     \n";
exit 1;
}else{

my ($pb_ont_depfile,$cover_rate_file,$window,$win_n,$threshold)=($ARGV[0],$ARGV[1],$ARGV[2],$ARGV[3],$ARGV[4]);
my $threshold=1-$threshold;

open CVF,$cover_rate_file;
while (<CVF>){chomp;
my @arr=split/\t/;
my $line=join("===",@arr);
my ($chr,$pos)=($arr[0],$arr[1]);
push @{$cover_rate{$chr}},$line;
}

open DEP,$pb_ont_depfile;
my %dep;
while (<DEP>){
chomp;
 my ($chr_now,$pos_now,$depth_now)=(split/\t/,)[0,1,2];
#if( $chr_former=undef){$dep{$chr_now}{$pos_now}=$depth_now;}
if($chr_now eq $chr_former) {$dep{$chr_now}{$pos_now}=$depth_now; }
 if($chr_now ne $chr_former ) {
 for my $key(keys %cover_rate){
  next if( not defined $dep{$key}) ;
   my @arr=@{$cover_rate{$key}};
   for my $line(@arr){
   my ($chr,$pos)=(split/===/,$line)[0,1];
    for my $n(1..$win_n){
     my @left;
     my @right;
     for my $i(1..($window*$n)){ 
      my $bkleft=$pos-$i;
      next if(not defined  $dep{$chr}{$bkleft} );
      my $bkright=$pos+$i; 
      next if(not defined $dep{$chr}{$bkright});
      push @left,$dep{$chr}{$bkleft};
      push @right,$dep{$chr}{$bkright}; }
#         my $lefnum=@left; my $rignum=@right;  
#         for my $j (1..int($rignum*0.2)){push @left, $right[$j];}
 #        for my $j (1..int($lefnum*0.2)){push @right, $left[$j];}
     my $leftavg= avg  (@left) ; 
     my $rightavg=avg (@right) ;
#  print "$chr\t$pos\t@left===============@right\n";
#  print "left:$leftavg\tright:$rightavg\n";
     if($leftavg <= 5 and  $rightavg<=5) {  
	if($leftavg < $threshold*$threshold*$rightavg or $rightavg <$leftavg*$threshold*$threshold){$line=~s/===/\t/g; print "$line\n";last}}
     if($leftavg >5 or $rightavg>5){
         if($leftavg < $threshold*$rightavg or $rightavg <$leftavg*$threshold){$line=~s/===/\t/g; print "$line\n";last}}
                    } 
                      }
  }
 %dep=();
}
 $chr_former =$chr_now;
}



 for my $key(keys %cover_rate){
   next if( not defined $dep{$key}) ;
   my @arr=@{$cover_rate{$key}};
    for my $line(@arr){
    my ($chr,$pos)=(split/===/,$line)[0,1];
     for my $n(1..$win_n){
      my @left;
      my @right;
       for my $i(1..($window*$n)){
        my $bkleft=$pos-$i;
        next if(not defined  $dep{$chr}{$bkleft} );
        my $bkright=$pos+$i;
          next if(not defined $dep{$chr}{$bkright});
      push @left,$dep{$chr}{$bkleft};
      push @right,$dep{$chr}{$bkright}; }
#         my $lefnum=@left; my $rignum=@right;
#         for my $j (1..int($rignum*0.2)){push @left, $right[$j];}
#         for my $j (1..int($lefnum*0.2)){push @right, $left[$j];}
    my $leftavg= avg  (@left) ;
    my $rightavg=avg (@right) ;

     if($leftavg <= 5 and  $rightavg<=5) {  
	if($leftavg < $threshold*$threshold*$rightavg or $rightavg <$leftavg*$threshold*$threshold){$line=~s/===/\t/g; print "$line\n";last}}
     if($leftavg >5 or $rightavg>5){
         if($leftavg < $threshold*$rightavg or $rightavg <$leftavg*$threshold){$line=~s/===/\t/g; print "$line\n";last}}

                    }
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

close CVF;
close DEP;

