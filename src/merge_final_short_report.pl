my ($hr_report,$er_report)=($ARGV[0],$ARGV[1]);
open IN1,$hr_report;
while (<IN1>){
chomp;
next if/Short Report:/;
next if/^#/;
my ($chr,$cov_rate,$avg_ser, $avg_ler, $wei,$score)=(split/\s+/);
my $avg_ser1=(split/\(/,$avg_ser)[0];
my $avg_ler1=(split/\(/,$avg_ler)[0];



$hr_hash{$chr}="$avg_ser1\t$avg_ler1";
}

print "Short Report:\n#Chr\tCovered.Rate\tavg.SHR\tavg.LHR\tavg.SER(S-AQI)\tavg.LER(L-AQI)\tWeight\tAQI\n";
open IN2,$er_report;
while (<IN2>){
chomp;
next if/Short Report:/;
next if/^#/;
my ($chr,$cov_rate,$avg_ser, $avg_ler, $wei,$score)=(split/\s+/);
my  $hr_hash_value=$hr_hash{"$chr"};
my ($avg_shr,$avg_lhr)=(split/\t/,$hr_hash_value);

print "$chr\t$cov_rate\t$avg_shr\t$avg_lhr\t$avg_ser\t$avg_ler\t$wei\t$score\n";

}



