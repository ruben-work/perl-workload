# Author: Ruben
use v5.18;

my $max_depth = 8;
my $num_rows = shift || 500000;
my $num_cols = shift || 10;

my @rand_X = map { [ map { rand(10); } (1 .. $num_cols) ] } (1 .. $num_rows);
my @rand_y = map { rand() > 0.5 ? 1 : 0 } (1 .. $num_rows); 

my $dt1 = DecisionTree->new(max_depth => $max_depth);
$dt1->train(\@rand_X,\@rand_y);


package DecisionTree;
use v5.20;

sub new {
  my %T = @_;
  $T{max_depth} //= 4;
  $T{max_class_pct} //= 0.75;
  $T{min_samples_split} //= 1;
  $T{split_strategy} //= 'random';

  die 'split strategy has to be one of: (greedy, random, greedy_random)'
    unless ($T{split_strategy} eq 'greedy' || $T{split_strategy} eq 'random' || $T{split_strategy} eq 'greedy_random');

  return bless \%T, __PACKAGE__;
}


sub train {
  my($self,$x,$y) = @_;
  my @feature_names = (0 .. scalar @$x);
  my $meta = {};
  my $tree = $self->_make_tree($x,$y,0,$meta);
  $tree->{num_leaf_nodes} = $meta->{num_leaf_nodes};
  $self->{_tree} = $tree;

  return;
}

# not needed for this benchmark:
# sub predict { .. }

sub get_num_leaf_nodes {
  my $self = shift;
  return $self->{_tree}->{num_leaf_nodes};
}

sub _make_tree {
  my($self,$x,$y,$level,$meta) = @_;

  my %tree = $level == 0 ? (
    num_leaf_nodes => undef 
  ) : ();

  $tree{level} = $level;

  my %y_vals;
  $y_vals{$y->[$_]}++ for (0 .. $#$y);

  $tree{class} = [sort { $y_vals{$a} <=> $y_vals{$b} } keys %y_vals]->[-1];
  $tree{class_pct} = $y_vals{$tree{class}} / sum(values %y_vals);

  my $min_samples_split_ok = @$x > $self->{min_samples_split};
  my $max_depth_reached = !($level < $self->{max_depth});
  my $max_class_pct_reached = ($tree{class_pct} >= $self->{max_class_pct});

  my $keep_splitting = $min_samples_split_ok
    && !$max_depth_reached
    && !$max_class_pct_reached;

  my $greedy;

  if($keep_splitting) {
    my $feature = $tree{feature} = int(rand(scalar @{$x->[0]}));
    my $num_rows = scalar @$x;

    my $best_thresh_score = -1;
    my $best_thresh;
    my @temp;

    $greedy = $self->{split_strategy} eq 'greedy'
      ? 1
      : $self->{split_strategy} eq 'random'
      ? 0
      : int(rand() + 0.5);

    for my $i (0 .. $num_rows -1) {
      my $threshold = $tree{threshold} = $greedy ? 
        $x->[$i]->[$feature]
        : $x->[rand(@$x)]->[$feature];

      my($left_x,$left_y,$right_x,$right_y) = _split_on_thresh(
        $feature, $threshold, $x, $y);

      if(@$right_y && @$left_y) {
        my $score = $greedy ?
          _calculate_split_score($left_y,$right_y)
          : 1; 

        if($score > $best_thresh_score) {
          $best_thresh_score = $score;
          $best_thresh = $threshold;
          @temp = ($left_x,$left_y,$right_x,$right_y);
        }
      }

      # if the strategy is greedy we dont want to
      # loop all rows
      last unless $greedy;
    }

    if(@temp) {
      $tree{left} = $self->_make_tree(
        $temp[0],$temp[1],$level + 1,$meta);
      $tree{right} = $self->_make_tree(
        $temp[2],$temp[3],$level + 1,$meta);
    }
  }
  unless($tree{left}) {
    $meta->{num_leaf_nodes}++;
    $meta->{strategy} = $greedy ? 'greedy' : 'random';
    $tree{count} = scalar @$y;
  }
  
  return \%tree;
}

sub _split_on_thresh {
  my($feature,$threshold,$x,$y) = @_;

  my(@left_x,@left_y,@right_x,@right_y);
  
  for my $i (0 .. $#$x) {
    if( $x->[$i]->[$feature] <= $threshold ) {
      push @left_x, $x->[$i];
      push @left_y, $y->[$i];
    } else {
      push @right_x, $x->[$i];
      push @right_y, $y->[$i];
    }
  }
  return(\@left_x,\@left_y,\@right_x,\@right_y);
}

# not needed for this benchmark:
# sub _walk_tree { .. }

sub value_counts {
  my %C;
  $C{$_}++ for @_;
  my @sorted = sort { $C{$a} <=> $C{$b} } keys %C;
  my $max = $sorted[-1];
  my $min = $sorted[0];
  my $sum; 
  $sum += $_ for values %C;

  return {
    counts => \%C,
    max => $max,
    min => $min,
    total => $sum,
  };

}

sub _calculate_split_score {
  my ($y_left, $y_right) = @_;
  my($lc,$rc) =
    (value_counts(@$y_left), value_counts(@$y_right));

  my $total_count = $lc->{total} + $rc->{total};

  my $v1 = $lc->{counts}{$lc->{max}}/$lc->{total};
  my $v2 = $rc->{counts}{$rc->{max}}/$rc->{total};

  my $out = ($v1 * ($lc->{total} / $total_count))
    + ($v2 * ($rc->{total} / $total_count));

  return $out;
}

sub sum {my $out = 0; $out += $_ for @_; return $out;}


1;
