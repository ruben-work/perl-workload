use v5.18;

my $n = $ARGV[0] // 33;
$n = $n > 0 ? $n : 0;


# doesn't check for neg input.
sub fib {
    my $n = shift;

    if($n == 0) {
        return 0; 
    } elsif($n == 1) {
        return 1;
    } else {
        return fib($n - 1) + fib($n - 2);
    }
}

say "fib($n) = " . fib($n);
