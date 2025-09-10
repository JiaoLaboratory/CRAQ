my @regions;
my $min_space=50000;

while (<>) {
    chomp;
    my ($chr, $start, $end, $cov) = (split/\s+/);
    next if(($end-$start)<=8000);
    push @regions, [$chr, $start, $end];
}


@regions = sort {
    $a->[0] cmp $b->[0] || $a->[1] <=> $b->[1]
} @regions;


my @merged;
my ($chr, $start, $end) = @{$regions[0]};

for (my $i = 1; $i < @regions; $i++) {
    my ($c, $s, $e) = @{$regions[$i]};
    if ($c eq $chr && $s - $end < $min_space) {
        $end = $e;  
    } else {
        push @merged, [$chr, $start, $end];
        ($chr, $start, $end) = ($c, $s, $e);
    }
}
push @merged, [$chr, $start, $end]; 


foreach my $r (@merged) {
    my ($chr, $start, $end) = @$r;
    my $length = $end - $start;
    
    print join("\t", @$r), "\n" if $length >= 30000;
}

