

my %fh_cache;  # 缓存每个chr对应的文件句柄

while (my $line = <>) {
    chomp $line;
    next if $line =~ /^\s*$/;  # 跳过空行
    my @fields = split(/\s+/, $line);
    my ($f1, $f2, $f3, $f4, $f5, $f6) = @fields[0..5];
    my $line1 = join("\t", $f1, $f2, $f3, $f4, $f5, $f6);    
my $chrid = $f3;

 
    if (!exists $fh_cache{$chrid}) {
        open(my $out, '>', "LRout/$chrid.sam") or die "Cannot open $chrid.sam: $!";
        $fh_cache{$chrid} = $out;
    }

    my $out_fh = $fh_cache{$chrid};
    print $out_fh "$line1\n";
}


foreach my $fh (values %fh_cache) {
    close($fh);
}

