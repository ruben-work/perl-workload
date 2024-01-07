# Author: Ruben

use v5.18;
use Data::Dumper;

# Solve system of linear equations using Gaussian elimination
# Example matrix from wikipedia: https://en.wikipedia.org/wiki/Gaussian_elimination#Example_of_the_algorithm
# [ 2  1 -1 | 8  ]
# [-3  1  2 | -11]
# [-1  1  2 | -3 ]
# 
# say Dumper solve([[2,1,-1,8],[-3,-1,2,-11],[-2,1,2,-3]]); 
# output: [2, 3, -1]

my $problem_size = $ARGV[0] >= 3 ? $ARGV[0] : 300;

my @out = @{ solve(random_system_of_linear_eqs()) };
say "x1: $out[0], x2: $out[1], x3: $out[2], etc.";

sub solve {
  my @out;
  my ($nr, $nc) = (scalar @{$_[0]}, scalar @{$_[0]->[0]});
  die 'solve() expects matrix size (n,n+1)' unless $nc == $nr + 1;

  my $m = shift;

  for my $k (0 .. $nr - 1) {
    my $max_pos = [sort { abs($m->[$b][$k]) <=> abs($m->[$a][$k]) } ($k .. $nr - 1)]->[0];

    return undef if abs($m->[$max_pos][$k]) < 0.00000000001;

    ($m->[$k], $m->[$max_pos]) = ($m->[$max_pos], $m->[$k]) unless $max_pos == $k;

    for my $l ($k + 1 .. $nr - 1) {
      my $f = $m->[$l][$k] / $m->[$k][$k];
      $m->[$l][$k] = 0;
      ($m->[$l][$_] += $m->[$k][$_] * -$f) for ($k + 1 .. $nc - 1);
    }
  }

  # back substitution:
  for my $i (reverse(0 .. $nr - 1)) {
    for (my $j = 0; $j < $i; $j++) {
      $m->[$j][$nc - 1] -= ($m->[$j][$i] / $m->[$i][$i]) * $m->[$i][$nc - 1];
    }

    push @out, ($m->[$i][$nc - 1] / $m->[$i][$i]);
  }

  return [reverse @out];
}

sub random_system_of_linear_eqs {
  my @xs = map { Rand() } (1 .. $problem_size);
  my $A;

  for my $i(0 .. $problem_size - 1) {
    for my $j(0 .. $problem_size - 1) {
      my $v = Rand();
      $A->[$i][$j] = $v;
      $A->[$i][$problem_size] += ($xs[$j] * $v);
    }
  }

  return $A;
}

sub Rand {
  my $r = int(rand($problem_size)+1);
  return rand() < 0.5 ? (-1*$r) : $r;
}