my ($hr_report,$er_report)=($ARGV[0],$ARGV[1]);
open IN1,$hr_report;
while (<IN1>){
chomp;
next if/NO.norm/;
my ($chr,$s,$e,$nser,$nler,$norm_ser,$norm_ler,$wei,$score)=(split/\s+/);
$hr_hash{"$chr\t$s\t$e"}="$nser\t$nler\t$norm_ser\t$norm_ler";
}
#print "CHR\tBlocks\tBlocke\tNO.SER\tNO.LER\tNO.norm.SER\tNO.norm.LER\tNO.SHR\tNO.LHR\tNO.norm.SHR\tNO.norm.LHR\tWeight\tAQI\n";
print "CHR\tBlocks\tBlocke\tNO.norm.SER\tNO.norm.LER\tNO.norm.SHR\tNO.norm.LHR\tWeight\tAQI\n";
open IN2,$er_report;
while (<IN2>){
chomp;
next if/NO.norm/;
my ($chr,$s,$e,$nser,$nler,$norm_ser,$norm_ler,$wei,$score)=(split/\s+/);
my  $hr_hash_value=$hr_hash{"$chr\t$s\t$e"};
my ($nshr,$nlhr,$norm_shr,$norm_lhr)=(split/\t/,$hr_hash_value);

#print "$chr\t$s\t$e\t$nser\t$nler\t$norm_ser\t$norm_ler\t$nshr\t$nlhr\t$norm_shr\t$norm_lhr\t$wei\t$score\n";
print "$chr\t$s\t$e\t$norm_ser\t$norm_ler\t$norm_shr\t$norm_lhr\t$wei\t$score\n";

}



