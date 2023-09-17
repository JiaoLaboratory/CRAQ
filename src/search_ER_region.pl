my ($dep0_bed,$error_loc)=($ARGV[0],$ARGV[1]);

open IN1,$dep0_bed;

while (<IN1>){
chomp;
my ($chr,$start,$end)=(split/\s+/)[0,1,2];

$hash{$chr}{"$start\t$end"}=0;
}

open IN2,$error_loc;
my $dis=10;
while (<IN2>){
chomp;
my ($chr,$loc)=(split/\s+/,)[0,1];
   for my $dep0chr(keys %hash){
   next if($dep0chr ne $chr);
    for my $line (keys %{$hash{$dep0chr}}){
   my ($dep0start,$dep0end)=(split/\t/,$line);
   if(($dep0start-$dis) < $loc && ($dep0end+$dis)>$loc ) {
   $region{$_}="$dep0start\t$dep0end";

#   print "$chr\t$loc\t$dep0start\t$dep0end\n";
    }   } }
}

open IN2,$error_loc;
while (<IN2>){
chomp;
my ($chr,$loc,$class)=(split/\s+/,)[0,1,-1];
if(defined $region{$_}){ print "$chr\t$region{$_}\t$chr:$loc\t$class\n" ; }
if(not defined $region{$_}){
my $start=$loc;
my $end=$loc+1;

 print "$chr\t$start\t$end\t$chr:$loc\t$class\n" ; }

}



