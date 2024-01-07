# Author: Ruben
use v5.18;

my $n_samples = $ARGV[0] || 15000000;
my $count;

for(1..$n_samples) {
    $count->{int(rand() * 1000)}++;
}

my $k = [ sort { $count->{$a} <=> $count->{$b} } %$count ]->[-1];
say "Most popular $k ($count->{$k} times)";
