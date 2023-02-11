#!/usr/bin/perl
#use Data::Dumper;
if (@ARGV != 6){print "USE: this scrupt is to  caculate the Average  breakpoint_number  on the  chromosome \n $0 chrsize_file final_SL_bk.txt blocksize step effectsize_file\n";
exit 1;
}else{

my ($chrsize_file,$final_SL_bk_file,$blocksize,$step,$effectsize_file,$out_name)=($ARGV[0],$ARGV[1],$ARGV[2],$ARGV[3],$ARGV[4],$ARGV[5]);
open IN0,$effectsize_file;
while(<IN0>){
chomp;
my ($chr,$depmin2size)=(split/\s+/)[0,1];
$effectsize{$chr}=$depmin2size;
}


open IN1,$chrsize_file;
while(<IN1>){
chomp;
my ($chr,$chrsize)=(split/\s+/)[0,1];

$eff_PCT{$chr}=$chrsize/($effectsize{$chr}+1);

my $blocknum=$chrsize/$step;
for($i=0;$i<= int($blocknum);$i++){
my $start=$i*$step;
my $end=$start+$blocksize;
if ($end >$chrsize){$end=$chrsize+1;}
my $block_s_e=join("\t",$chr,$start,$end);
$hash{$block_s_e} ={
	"mjnum"=>0,
        "mj_value"=>0,
	"mj_normvalue"=>0,

	"gap_num"=>0,
        "gap_value"=>0,
	"gap_normvalue"=>0,
        
	"localerr_num"=>0,
	"localerr_value"=>0,
        "localerr_normvalue"=>0 
              };
#print "$block_s_e\n";
}}
#print Dumper \%hash;
open IN2,$final_SL_bk_file;
my %hashbk;

while(<IN2>){chomp;
my ($bkchr,$bkpos,$type)=(split/\s+/,)[0,1,-1];
   
  push @{$hashbk{$bkchr}},"$bkpos--$type";
}
#print Dumper \%hashbk;
 for my $block_s_e(keys %hash){#print "$block_s_e\n";
	my ($block_chr,$block_s,$block_e)=(split/\t/,$block_s_e)[0,1,2];
              for  my $bkchr(sort  keys %hashbk){  
		 if ($bkchr eq $block_chr){
		   for my $bkpos_type( @{$hashbk{$bkchr}}){  
                        my ($bkpos,$type)=(split/--/,$bkpos_type)[0,1];
			if( $type =~/L/ &&  $bkpos>= $block_s && $bkpos<$block_e ){
 			   $hash{$block_s_e}{mjnum}++; my $num=$hash{$block_s_e}{mjnum};
                            $hash{$block_s_e}{mj_value}=$hash{$block_s_e}{mj_value}+1;
                           $hash{$block_s_e}{mj_normvalue}=$hash{$block_s_e}{mj_normvalue}+(1/$num);}
                         
                         if( $type eq "Gap" &&  $bkpos>= $block_s && $bkpos<$block_e ){
                           $hash{$block_s_e}{gap_num}++; my $num=$hash{$block_s_e}{gap_num};
			   $hash{$block_s_e}{gap_value}=$hash{$block_s_e}{gap_value}+1;
                           $hash{$block_s_e}{gap_normvalue}=$hash{$block_s_e}{gap_normvalue}+(1/$num);}

                         if(  $type !~ /L/ &&  $bkpos>= $block_s && $bkpos<$block_e ){
                           $hash{$block_s_e}{localerr_num}++; my $num=$hash{$block_s_e}{localerr_num};
			   $hash{$block_s_e}{localerr_value}=$hash{$block_s_e}{localerr_value}+1;
                           $hash{$block_s_e}{localerr_normvalue}=$hash{$block_s_e}{localerr_normvalue}+(1/$num);}

	
			}			
                    } 
          }
}

#open IN3, $chr_or_supscaffold_name_file;
#my %sup_chr;
#while (<IN3>){
 #  my $sup_chr_name=(split/\s+/)[0];
  # chomp;
  #  $sup_chr{$sup_chr_name}=1;
#}


my $tmp_out=$out_name.".tmp_N.stat";
open OUT,">$tmp_out";
  #print OUT  "Chr\tblock_start\tblock_end\tNO.misjoin\tNO.Gap\tNO.Local_err\tNO.misjoin_Norm\tNO.Gap_Norm\tNO.Local_err_Norm\n";
  print OUT  "Chr\tBlocks\tBlocke\tNO.LER\tNO.SER\tNO.norm.LER\tNO.norm.SER\n";
for (sort keys %hash){
   my $chr=(split/\t/,)[0];
 #next if(not defined $sup_chr{$chr});
 # print OUT  "$_\t$hash{$_}{mjnum}\t$hash{$_}{gap_num}\t$hash{$_}{localerr_num}\t$hash{$_}{mj_normvalue}\t$hash{$_}{gap_normvalue}\t$hash{$_}{localerr_normvalue}\n";
  print OUT  "$_\t$hash{$_}{mjnum}\t$hash{$_}{localerr_num}\t$hash{$_}{mj_normvalue}\t$hash{$_}{localerr_normvalue}\n";
}
close OUT;
#print Dumper\%hash;

my %value;
for my $block_s_e(sort keys %hash){
   my ($chr,$s,$e)=(split/\t/,$block_s_e)[0,1,2];
   my $block=$e-$s;
   my $value1_0=$hash{$block_s_e}{mj_value};
   my $value1=$hash{$block_s_e}{mj_normvalue};
   
   my $value2_0=$hash{$block_s_e}{gap_value};
   my $value2=$hash{$block_s_e}{gap_normvalue};

   my $value3_0=$hash{$block_s_e}{localerr_value};
   my $value3=$hash{$block_s_e}{localerr_normvalue};
 #  print "$chr\t$block\t$value\n";
   push @{$value{$chr}{block_size}},$block;
   push @{$value{$chr}{mj_value}},$value1_0;
   push @{$value{$chr}{mj_normvalue}},$value1;
   push @{$value{$chr}{gap_value}},$value2_0;
   push @{$value{$chr}{gap_normvalue}},$value2;
   push @{$value{$chr}{localerr_value}},$value3_0;
   push @{$value{$chr}{localerr_normvalue}},$value3;
     }
#print Dumper \%value;

my %chr_bk_value;
#print "#Chr\tBlocksum\tEffsize\tNo.LER\tNo.Gap\tNo.SER\tLER.avg\tGap.avg\tSER.avg\tNo.norm.LER\tNo.norm.Gap\tNo.norm.SER\tNorm.LER.avg\tNorm.Gap.avg\tNorm.SER.avg\n" ;
print "#Chr\tBlocksum\tEffsize\tNo.LER\tNo.SER\tAvg.LER\tAvg.SER\tNo.norm.LER\tNo.norm.SER\tAvg.Norm.LER\tAvg.Norm.SER\n" ;

my $total_avg;
for my $chr(sort keys %value)  { 
# next if (not defined $sup_chr{$chr});
 my $block_size_sum =sum( @{$value{$chr}{block_size}} );

 my $value1_0_sum= sum(@{$value{$chr}{mj_value}} ); #print "$value1_0_sum\n";
 my $value1_sum= sum(@{$value{$chr}{mj_normvalue}} );
 
 my $value2_0_sum= sum(@{$value{$chr}{gap_value}} );
 my $value2_sum= sum(@{$value{$chr}{gap_normvalue}} );

 my $value3_0_sum= sum(@{$value{$chr}{localerr_value}} );
 my $value3_sum= sum(@{$value{$chr}{localerr_normvalue}} );
 
my $avg_value1_0 = ($value1_0_sum/$block_size_sum)*1e+6*$eff_PCT{$chr};
 my $avg_value1 = ($value1_sum/$block_size_sum)*1e+6*$eff_PCT{$chr};
 
 my $avg_value2_0 = ($value2_0_sum/$block_size_sum)*1e+6;
 my $avg_value2 = ($value2_sum/$block_size_sum)*1e+6;

 my $avg_value3_0 = ($value3_0_sum/$block_size_sum)*1e+6*$eff_PCT{$chr};
 my $avg_value3 = ($value3_sum/$block_size_sum)*1e+6*$eff_PCT{$chr};

 #my $per_nonContiguity=$avg_value1*0.8+$avg_value2*0.2;
 my $per_nonContiguity=$avg_value2;
 my $per_nonCorrect   =$avg_value3;

my $block_size_sum=$block_size_sum*$step/$blocksize;

my $value1_0_sum =$value1_0_sum*$step/$blocksize;
my  $value1_sum=$value1_sum*$step/$blocksize;

my $value2_0_sum =$value2_0_sum*$step/$blocksize;
my  $value2_sum=$value2_sum*$step/$blocksize;

my $value3_0_sum=$value3_0_sum*$step/$blocksize;
my $value3_sum=$value3_sum*$step/$blocksize;
my $effectsize=$effectsize{$chr}+1;

print "$chr\t$block_size_sum\t$effectsize\t$value1_0_sum\t$value3_0_sum\t$avg_value1_0\t$avg_value3_0\t$value1_sum\t$value3_sum\t$avg_value1\t$avg_value3\n";
#print "$chr\t$block_size_sum\t$effectsize\t$value2_0_sum\t$value3_0_sum\t$avg_value2_0\t$avg_value3_0\t$value2_sum\t$value3_sum\t$avg_value2\t$avg_value3\n";

   }
#print "Whole\t$all_nonContiguity\t$all_nonCorrect\n";


  sub sum{
       my $sum;
      for (@_){
       $sum=$sum+$_;} 
    return $sum;
}

 }

