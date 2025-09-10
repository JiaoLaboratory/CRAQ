#!/usr/bin/perl
#use Data::Dumper;
if (@ARGV != 2){print "\nUSE: this script is to search minimal INDELs \n \n samtools view  my.bam -@ 10 | perl $0  - minlen > clipDI.cov\n\n";
exit 1;
}else {
my ($sam,$minlen)=($ARGV[0],$ARGV[1]);

open IN,$sam;
 while (my $line=<IN>){chomp $line;
        next if ($line=~/^@/);
 my( $readid,$chr,$start,$cigar)=(split/\s+/,$line)[0,2,3,5]; next unless ($cigar=~/[DSHI]/);
 my $cigarD=$cigar;
 my $cigarI=$cigar;
 my $charD; 
 $cigarD =~ s/\d+S|\d+I|\d+H//g;
 my @arr_num=split/\M|\D/,$cigarD;
 my @arr_word=split/\d+/,$cigarD;
	for my $i(0..$#arr_num){ my $word=$arr_word[$i+1]x$arr_num[$i]; $charD=$charD.$word;}
	  while ($charD=~/(D+)/g){  my $endD=pos($charD) ; my $lenD=length($1); my $startD=$endD-$lenD;
          my $clipD_start=$start+$startD-1;
	  $hash_Dreadnum{"$chr\t$clipD_start"}++;   
          push @{$hash_Dlen{"$chr\t$clipD_start"}},$lenD; }

$cigarI =~ s/\d+S|\d+H//g; #print "$cigarI\n";
my $I_sumlen; my $charI;
my @arr_num=split/\M|\I|\D/,$cigarI;# print "@arr_num\n";
my @arr_word=split/\d+/,$cigarI; #print "@arr_word\n";
      for my $i(0..$#arr_num){ my $word=$arr_word[$i+1]x$arr_num[$i]; $charI=$charI.$word;}#print "$charI\n";
         while ($charI=~/(I+)/g){  my $endI=pos($charI) ; my $lenI=length($1); my $startI=$endI-$lenI;
         my $clipI_start=$start+$startI-1-$I_sumlen;
         $I_sumlen=$I_sumlen+$lenI;
        $hash_Ireadnum{"$chr\t$clipI_start"}++;
        push @{$hash_Ilen{"$chr\t$clipI_start"}},$lenI;}

}
#print Dumper\%hash_Ireadnum;
#print Dumper\%hash_Ilen;

for my $pos( keys %hash_Dreadnum){
my $sumDlen;my %uniq;
	my @array_Dlen = sort {$a<=>$b} @{$hash_Dlen{$pos}};
	my $reads_support_num=$hash_Dreadnum{$pos};
	next if ($reads_support_num<3);
	for (@array_Dlen){$uniq{$_}=1}; my @array_Dlen_uniq =keys %uniq;
	my $mid_index=int(@array_Dlen/2);
	my $midDlen=$array_Dlen[$mid_index];
	next if($midDlen) < $minlen;
	my $same_rate=(@array_Dlen+1-@array_Dlen_uniq)/@array_Dlen;
	print "$pos\t+\t$reads_support_num\t$midDlen\tD\t$same_rate\n";
}
for my $pos( keys %hash_Ireadnum){
my $sumIlen; my %uniq;
        my @array_Ilen = sort{$a<=>$b}@{$hash_Ilen{$pos}};   
	my $reads_support_num=$hash_Ireadnum{$pos};
        next if ($reads_support_num<3);
	for (@array_Ilen){$uniq{$_}=1}; my @array_Ilen_uniq =keys %uniq; 
        my $mid_index=int(@array_Ilen/2);
	my $midIlen=$array_Ilen[$mid_index];
	next if($midIlen) < $minlen;
	my $same_rate=(@array_Ilen+1-@array_Ilen_uniq)/@array_Ilen; 
	print "$pos\t+\t$reads_support_num\t$midIlen\tI\t$same_rate\n";
}
#

}
