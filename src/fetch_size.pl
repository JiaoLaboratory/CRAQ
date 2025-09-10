#!/usr/bin/perl
if (@ARGV != 1){print "USE: perl $0 genome.fa  \n";
exit 1;
}else{

my ($infile)=$ARGV[0];
	open IN,$infile;
	while (<IN>) {chomp;
		if (/>(\S+)/){
			$name=$1;}
		else {  $hash{$name}.= $_;}  
}


foreach $key ( sort keys  %hash)
	{
	 $len=length $hash{$key};
         print $key."\t";print $len,"\n";
	}

close IN;

}


