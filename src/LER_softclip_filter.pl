#use Data::Dumper;
my ($LR_clip_nameid,$mergeLER)=($ARGV[0],$ARGV[1]);
open IN1,$LR_clip_nameid;

while (<IN1>){chomp;
my ($chr,$loc,$stran,$readid)=(split/\t/)[0,1,2,4];
if($stran eq "+"){$postive{$chr}{$loc}=$readid;}
if($stran eq "-"){$reverse{$chr}{$loc}=$readid;}}
#print Dumper\%postive ;
#print Dumper\%reverse ;
open IN2,$mergeLER;
while (<IN2>){chomp;
my ($chr,$loc,$stran)=(split/\t/)[0,1,2];
if($stran eq "*"){print "$_\t0\n"};
#############
my $dis=50000;
my $rate=1;
if($stran eq "+"){
my @LER_readlist=split/\s+/,$postive{$chr}{$loc};
my %hash;
my $i=0;
my $right_flink_line;
#print "$chr\t$loc\t@LER_readlist\n";
my $right_flinkloc=$loc+$dis;
	for my $rev_chr(keys %reverse){next if($rev_chr ne $chr);
          for my $rev_loc(keys %{$reverse{$rev_chr}}){
	     if($rev_loc >=$loc && $rev_loc<=$right_flinkloc){$right_flink_line="$right_flink_line $reverse{$rev_chr}{$rev_loc}"; }}
             my @right_flink_arr=(split/\s+/,$right_flink_line);
# print "$_=>right\t@right_flink_arr\n";
               for my $right_flink_perid( @right_flink_arr){$hash{$right_flink_perid}=1};
	       for my $LER_loc_perid (@LER_readlist){
		    if (defined $hash{$LER_loc_perid}){$i++; #print "ppp$LER_loc_perid\t";
								}}
		      my $num=@LER_readlist;my $rate1=$i/$num;
                      print "$_\t$rate1\n";
				}	}
############
if($stran eq "-"){
my @LER_readlist=split/\s+/,$reverse{$chr}{$loc};
my %hash;
my $i=0;
my $left_flink_line;
#print "$chr\t$loc\t@LER_readlist\n";
my $left_flinkloc=$loc-$dis;
        for my $pos_chr(keys %postive){next if($pos_chr ne $chr);
          for my $pos_loc(keys %{$postive{$pos_chr}}){
             if($pos_loc <= $loc && $pos_loc >= $left_flinkloc){$left_flink_line="$left_flink_line $postive{$pos_chr}{$pos_loc}"; }}
             my @left_flink_arr=(split/\s+/,$left_flink_line);
# print "$_=>left\t@left_flink_arr\n";
               for my $left_flink_perid( @left_flink_arr){$hash{$left_flink_perid}=1};
               for my $LER_loc_perid (@LER_readlist){
                    if (defined $hash{$LER_loc_perid}){$i++;# print "ppp$LER_loc_perid\t";
                                                                }}
                     my $num=@LER_readlist;my $rate1=$i/$num;
                     print "$_\t$rate1\n";
                                }       }
}


