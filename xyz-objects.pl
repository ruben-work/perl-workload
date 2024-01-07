# Author: Ruben

use v5.18;

my $n = $ARGV[0] || 1000000;
my $out;

for(1 .. $n) {
    my $xyz = XYZ->new(int(rand(10)+1), int(rand(10)+1), int(rand(10)+1));
    my $r = $xyz->x * $xyz->y * $xyz->z;

    if($r < 50) {
        $out =- $r;
    } else {
        $out += $r;
    }
}

say $out;

package XYZ {
    sub new {
        my $class = shift;
        return bless {x => shift, y => shift, z => shift}, $class;
    }
    sub x { shift->{x} }
    sub y { shift->{y} }
    sub z { shift->{z} }
    1;
}