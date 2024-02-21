use v5.18;

sub is_even { $_[0] == 0 || is_odd($_[0] - 1) }
sub is_odd { $_[0] != 0 && is_even($_[0] - 1) }

die 'not ok'
    unless is_even(1000000)
    && !is_even(1000001)
    && is_even(1000002)
    && !is_even(1000003);

say 'ok!'
