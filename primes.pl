#!/usr/bin/perl

# Name: primes
# Description: generate primes
# Author: Jonathan Feinberg, jdf@pobox.com
# Author: Benjamin Tilly, ben.tilly@alumni.dartmouth.org
# License: perl

# primes - generate primes
# Written for the PPT initiative by Jonathan Feinberg.
# The algorithm was substantially modified by Benjamin Tilly.
# See docs for license.

# Ruben: This script has been modified to be used in benchmarks 
# the original one prints primes from $start to $end
# this version only prints the last prime

use v5.18;
#use integer; # faster, but cuts the maxint down
$|++;
my @primes = (2, 3, 5, 7, 11);          # None have been tested
my @next_primes = ();                   # Avoid redoing work


my $start = 1; 
my $end = $ARGV[0] || 10000000;

primes ($start, $end);
exit 0;

sub primes {
  my ($start, $end) = @_;
  return if $end <= $start;
  $end--;                               # Reindex
                                        # Initialize the list of primes
  &more_primes($primes[-1]+1, int(sqrt($end)));
  while (scalar @next_primes) {
    push @primes, @next_primes;
                                        # Careful, we need to ensure that
					# we get a prime past sqrt($end)...
    &more_primes($primes[-1]+1, int(2*sqrt($end)));
  }
  my $from = $start-1;
  my $to = $from;
  until ($to == $end) {
    $from = $to + 1;
    $to = $from + 99999;                # By default do 100,000
    $to = $end if $end < $to;           # Unless I can finish in one pass
    &more_primes($from, $to);
  }

  print $next_primes[-1];
}
sub more_primes {
  # This adds to the list of primes until it reaches $max
  #      or the square of the largest current prime (assumed odd)
  my $base = shift;
  my $max = shift;
  my $square = $primes[-1] * $primes[-1];
  $max = $square if $square < $max;     # Determine what to find primes to
  $base++ unless $base % 2;             # Make the base odd
  $max-- if $max %2;                    # Make the max odd
  $max = ($max - $base)/2;              # Make $max into a count of odds
  return @next_primes = () if $max < 0; # Sanity check
  my @more = map {0} 0..$max;           # Initialize array of 0's for the
                                        # odd numbers in our range
  shift @primes;                        # Remove 2
  foreach my $p (@primes) {
    my $start;
    if ($base < $p * $p) {
      $start = ($p * $p - $base)/2;     # Start at the square
      if ($max < $start) {              # Rest of primes don't matter!
          last;
      }
    }
    else {                              # Start at first odd it divides
      $start = $base % $p;              # Find remainder
      $start = $p - $start if $start;   # Distance to first thing it divides
      $start += $p if $start %2;        # Distance to first odd it divides
      $start = $start/2;                # Reindex for counting over odd!
    }
    for (my $i = $start; $i <= $max; $i += $p) {
      $more[$i] = 1;
    }
  }
  unshift @primes, 2;                   # Replace 2
  # Read off list of primes
  @next_primes = map {$_ + $_ + $base} grep {$more[$_] == 0} 0..$max;
}