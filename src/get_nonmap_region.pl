open IN1,$ARGV[0];
my $dis=3;
while (<IN1>){
chomp;
my ($chr,$loc,$depth)=(split/\s+/)[0,1,2];
#next if($depth >0);
for my$i(0..$dis){
my $loc_new=$loc+$i;
$hash{$chr}{$loc_new}=0;

}
}

for my $chr(sort keys %hash){
   for my $loc(sort {$a<=>$b} keys %{$hash{$chr}}){
  my $left=$loc-1;
  my $right=$loc+1;
  if( defined $hash{$chr}{$right}  && not defined $hash{$chr}{$left}   ){
  print "$chr\t$loc\t";}
  if( defined $hash{$chr}{$left}  && not defined $hash{$chr}{$right}   ){
  print "$loc\t0\n";}

}

}
close IN1;
