#use Data::Dumper;
my ($seq_size,$uncertain,$final_report)=($ARGV[0],$ARGV[1],$ARGV[2]);

open IN1,$seq_size;
my $total_size=0;
while (<IN1>){
chomp;
my ($chr,$size)=(split/\s+/)[0,1];
$chr_un_ratio{$chr}=0;
$hashsize{$chr}=$size;
$total_size=$total_size+$size;}


open IN2,$uncertain;
my $total_uncertain=0;
while (<IN2>){
chomp;
my ($chr,$s,$e)=(split/\s+/)[0,1,2];
my $len=$e-$s;
push @{$hashun{$chr}},$len;
$total_uncertain=$len+$total_uncertain;
}
my $total_un_ratio=$total_uncertain/($total_size+1);

#print Dumper\%hash;

for my $chr(keys %hashun ){
my $chr_un=0;
   for my $len(@{$hashun{$chr}}){
   $chr_un=$chr_un+$len;}
   $chr_un_ratio{$chr}=$chr_un/($hashsize{$chr}+1);
}


#print Dumper\%chr_un_ratio;

open IN3,$final_report;
my $per_chr_un_ratio=0;

print "Short Report:\n";
print "#Chr\tCovered.Rate\tUncertain.Rate\tAvg.CRH\tAvg.CSH\tAvg.CRE(S-AQI)\tAvg.CSE(L-AQI)\n";
while (<IN3>){
chomp;
next if(/Short Report:/);
next if(/#Chr/);
my ($chr,$covered,$shr,$lhr,$ser,$ler,$wei,$aqi)=(split/\s+/)[0,1,2,3,4,5,6,7];
if(/^Genome/){ 
 print "Genome\t$covered\t$total_un_ratio\t$shr\t$lhr\t$ser\t$ler\n" ;}else {
  my $per_chr_un_ratio=$chr_un_ratio{$chr};
 print "$chr\t$covered\t$per_chr_un_ratio\t$shr\t$lhr\t$ser\t$ler\n";}

}

