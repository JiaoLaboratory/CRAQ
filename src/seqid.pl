open IN1,$ARGV[0];
while (<IN1>){
chomp;

my ($id)=(split/\s+/)[0];
$hash{$id}=1;
}

for (keys %hash ){
print "$_\n";
}
