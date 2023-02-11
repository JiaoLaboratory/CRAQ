
my ($gap_file,$size_file,$min_gap_len)=($ARGV[0],$ARGV[1],$ARGV[2]);

open IN0,$size_file;
while (<IN0>){
chomp;
my ($chr,$size)=(split/\s+/,)[0,1];

$hash_size{"$chr--1"}=1;
$hash_size{"$chr--$size"}=1;}

open IN1,$gap_file;
	while (<IN1>){
	chomp;
	my ($chr,$gap_s,$gap_e)=(split/\s+/,)[0,1,2];
		if(defined $hash_size{"$chr--$gap_s"} or defined $hash_size{"$chr--$gap_e"} ){print "$_\n";}
		else {
		  my $gap_len=abs($gap_e-$gap_s);
		 if($gap_len >$min_gap_len){print "$_\n";}
		}
			}


close IN0;
close IN1;
