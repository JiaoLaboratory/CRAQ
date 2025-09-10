my ($clip_cov_file)=($ARGV[0]);

my $prev_chr = '';
my $prev_pos = 0;
my $prev_strand = '';
my @prev_ids = ();
my $prev_count = 0;
my @group_records = ();

open IN1,$clip_cov_file;
while (<IN1>) {
    chomp;
    my ($chr,$pos,$strand,$count,$id) = (split/\t/,$_)[0,1,2,3,4];

    if ($prev_chr && ($chr ne $prev_chr || $strand ne $prev_strand || $pos - $prev_pos > 50)) {
     
        foreach my $rec (@group_records) {
            my ($c, $p, $s) = @$rec;
            print join("\t", $c, $p, $s, $prev_count, join(" ", @prev_ids)), "\n";
        }

        @group_records = ();
        @prev_ids = ();
        $prev_count = 0;
    }
    

    push @group_records, [$chr, $pos, $strand];
    push @prev_ids, $id;
    $prev_count += $count;
    
 
    $prev_chr = $chr;
    $prev_pos = $pos;
    $prev_strand = $strand;
}


if (@group_records) {
    foreach my $rec (@group_records) {
        my ($c, $p, $s) = @$rec;
        print join("\t", $c, $p, $s, $prev_count, join(" ", @prev_ids)), "\n";
    }
}
