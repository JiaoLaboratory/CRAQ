#use Data::Dumper;
#!/usr/bin/perl 
use Getopt::Long;
use Pod::Usage;
my $help;
#my $minclipdep=1;
#my $minbkrate=0.5;
my $maxdep=1000;
my $window=5e4;
my $minsize=5e4;
my $gapmodel=1;

my $msg            ="\nUSE: This is a script to select the most posssible misjoin\nperl $0 -z  chrsize_file -i mergecover_file \n";
#my $msg            ="USE: This is a script to select the most posssible misjoin\n\n";

my $usage="\nUsage: perl   $0   -z genome.size -i  merge_gap_coverRate.out\n\n";

GetOptions(             'h|help'                      => \$help,
                        'z|genome_size=s'             => \$genome_size,
                        'i|input=s'             => \$mergecover_file,
#                        'f|minbkrate=f'             	=> \$minbkrate,
#                        'k|minclipdep=i'             => \$minclipdep,
                        'm|mincontigsize=i'             => \$minsize,
                        'a|maxdepth=f'             => \$maxdep,
                        'w|window=i'             => \$window,
                        'j|gapmodel=i'                      => \$gapmodel,
                ) or pod2usage(2);
pod2usage(-msg=>$msg,-exitval=>1,-verbose=>99, -sections=>'NAME|SYNOPSIS|AUTHOR|CONTACT') if ($help);

if ( ! -e $genome_size ){print $usage;
                die "\nError: -z  contig_size.file :$genome_size doesn't exist, please check!\n\n" ;   }

if ( ! -e $mergecover_file ){print $usage;
                die "\nError: -i  input merge_gap_coverRate.out :$mergecover_file doesn't exist, please check!\n\n" ;   }

#if (  $minclipdep < 1  ){print $usage;
#                die "\nError: -md  min_clipread_depth :$mergecover_file doesn't exist, please check!\n\n" ;   }

#if (  $minbkrate < 0  ){print $usage;
#               die "\nError: -f  min_clipread_rate :$minbkrate please check!\n\n" ;   }
if (  $maxdep <= 0  ){print $usage;
                die "\nError: -maxdepth  max_sequence_depth , please check!\n\n" ;   }

if (  $window<=0 ){print $usage;
                die "\nError: -w  windowsize , please check!\n\n" ;   }
if (  $minsize <=0  ){print $usage;
                die "\nError: -m min_contigsize , please check!\n\n" ;   }
#if (  $gapmodel ne "F" and $gapmodel ne "T"){print $usage;
#                die "\nError: -j $gapmodel, -j T or F , please check!\n\n" ;   }

#if (  $gapmodel ==2 ){print "Gap is treated as LER\n"} else {print "Gap is treated as SER\n"}
open IN0,$genome_size;
while(my $line=<IN0>){
chomp $line;
my ($chr,$size)=(split/\s+/,$line)[0,1];
next if($size<$minsize);
$chrsize{$chr}=$size;}

open IN1,$mergecover_file;
while($feature_loc=<IN1>){
chomp $feature_loc;
my ($feature_chr,$feature_pos,$stran,$breakdep,$totaldep,$type)=(split/\s+/,$feature_loc)[0,1,2,3,4,5];
   next if(not defined $chrsize{$feature_chr} );
   if($gapmodel ==2){ if($type eq "Gap"){
             $final{$feature_chr}{$feature_pos}=$feature_loc;};   }
   next if($type eq "Gap");
   next if($chrsize{$feature_chr}-$feature_pos <=$window/2  or $feature_pos <=$window/2 ); 
   next if($totaldep ==0  );
#   next if($breakdep<$minclipdep);
   next if ($breakdep>=2*$maxdep);
#   next if($breakdep/$totaldep <= $minbkrate  );
   my $win_num=int($feature_pos/$window);
   $hash{$feature_chr}{$win_num}{$feature_loc}=$breakdep/$totaldep;
}

#print Dumper\%hash;
for my $chr(sort keys %hash){
    for my $win_num (sort {$a<=>$b} keys  %{$hash{$chr}}){ #print "$chr\t$win_num\n";
     my %hash2=%{$hash{$chr}{$win_num}}   ;#print Dumper\%hash2;
       for (sort { $hash2{$b}<=> $hash2{$a}} keys %hash2  )  {
         my ($feature_chr,$feature_pos)=(split/\s+/)[0,1];
             $final{$feature_chr}{$feature_pos}=$_."BK"; 
	     last }
                                                        }  
                         }
#print
for my $chr(sort keys %final){
    for my $pos( sort {$a<=>$b} keys %{$final{$chr}}){
    print "$final{$chr}{$pos}\n";}
}

__END__

=head1 NAME

        searchMj :To search most likely misjoinpoint

=head1 SYNOPSIS

  search_Misjunction.pl [options]  -z genome_size_file  -i  mergecover_file  

 Options:

  ***Help
        --help|-h             Print the help message and exit.

  ***Required parameters
        --genome_size|-z      The size file for the reference sequence
	--input|-i	      The clipread coverrage file merged

  ***Filter parameters
#	--minbkrate|-f        The min clipread coverage rate (default 0.5)
#	--minclipdep|-k      The min clipread coverrage     (default 1)
	--minsize|-m	      The min contig size ,smaller will be not calculated (default 1e5)
	--maxdepth|-a	      PacBio/ONT longreads coverage depth (default 1e3)
	--window|-w         windowsize(default 50000)

  ***Other parameters
	--gapmodel|-j	      Gap is misjunction (default: F)



