#!/usr/bin/perl

my ($infile)=($ARGV[0]);

open IN,$infile;
while(<IN>){
chomp;
my ($chr,$pos,$dep)=(split/\s+/,$_)[0,1,2];
 if($dep==0){
$hashdep0{$chr}{$pos}=0;}
}

for my $chr(sort keys %hashdep0 ){
      my %hash;
     for my $pos( sort{$a<=>$b} keys %{$hashdep0{$chr}}){
       next if(defined $hashdep0{$chr}{$pos+1}  && defined $hashdep0{$chr}{$pos-1});
       if(not defined $hashdep0{$chr}{$pos-1}  ){ if(not defined $hashdep0{$chr}{$pos+1}){next }};
       if( defined $hashdep0{$chr}{$pos+1} && not defined $hashdep0{$chr}{$pos-1}   ){
       my $start=$pos;
       $hash{start}=$start;
     # print "$start\n";
       }   
      if (defined $hashdep0{$chr}{$pos-1} && not defined $hashdep0{$chr}{$pos+1}   ){
       my $end=$pos;
       $hash{end}=$end;

      #print "$end\n";
     
   if($hash{end}-$hash{start}>=150){
 
       print $chr."\t".$hash{start}."\t+\t0"."\n";
       print $chr."\t".$hash{end}."\t-\t0"."\n";
      }
       }


 }
}



