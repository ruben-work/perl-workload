# Author's github: attractivechaos
# source:  https://github.com/attractivechaos/plb2/blob/master/src/perl/nqueen.pl

use v5.18;

sub nq_solve() {
	my $n = shift;
	my @a = (-1) x $n;
	my @l = (0) x $n;
	my @c = (0) x $n;
	my @r = (0) x $n;
	for my $i (0 .. $n - 1) {
		$a[$i] = -1;
		$l[$i] = $c[$i] = $r[$i] = 0;
	}
	my $y0 = (1<<$n) - 1;
	my $m = 0;
	my $k = 0;
	while ($k >= 0) {
		my $y = ($l[$k] | $c[$k] | $r[$k]) & $y0;
		if (($y ^ $y0) >> ($a[$k] + 1)) {
			my $i = $a[$k] + 1;
			while ($i < $n && ($y & 1<<$i)) {
				++$i;
			}
			if ($k < $n - 1) {
				my $z = 1<<$i;
				$a[$k++] = $i;
				$l[$k] = ($l[$k-1] | $z) << 1;
				$c[$k] =  $c[$k-1] | $z;
				$r[$k] = ($r[$k-1] | $z) >> 1;
			} else {
				++$m;
				--$k;
			}
		} else {
			$a[$k--] = -1;
		}
	}
	return $m;
}

# my $n = 15;
my $n = 12;
$n = int($ARGV[0]) if @ARGV > 0;
print(&nq_solve($n), "\n");
