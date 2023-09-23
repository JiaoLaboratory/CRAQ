#use Data::Dumper;
my ($clipcov_file,$all_dep)=($ARGV[0],$ARGV[1]);

open IN,$clipcov_file;
while (<IN>){
chomp;
my ($chr,$cliploc)=(split/\s+/)[0,1];
	for my $i(-300..300 ){
	my $flank_loc=$cliploc+$i;  
	$hash{$chr}{$flank_loc}=1;
}
}

open IN1,$all_dep;
while (<IN1>){
chomp;
my ($chr,$loc)=(split/\s+/)[0,1];
	if(defined $hash{$chr}{$loc}){print "$_\n";}
	
	}

