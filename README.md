# perl-workload

## Usage

`./bench /usr/bin/perl /usr/bin/a_faster_perl *.pl`

Or if you run it with sudo, the `nice` utility will be used internally to give the process higher CPU priority 

`sudo ./bench /usr/bin/perl /usr/bin/a_faster_perl *.pl`


Output:

```
Results:
______
count_rands.pl
median: 0.9 vs 0.865 | mean: 0.9 vs 0.865 | min: 0.89 vs 0.85 | max: 0.91 vs 0.88
>>> change: +4.046%
______
fannkuch-redux.pl
median: 0.33 vs 0.3 | mean: 0.333 vs 0.3 | min: 0.33 vs 0.3 | max: 0.34 vs 0.3
>>> change: +10.000%
______
fib.pl
median: 1.14 vs 1.05 | mean: 1.144 vs 1.052 | min: 1.13 vs 1.02 | max: 1.18 vs 1.08
>>> change: +8.571%
______
matmul.pl
median: 1.68 vs 1.575 | mean: 1.695 vs 1.571 | min: 1.63 vs 1.53 | max: 1.88 vs 1.59
>>> change: +6.667%
______
.
.
.
```

## Notes

* The `./bench` utility runs every script `$N_TIMES (10)` + 1 warmup run. 
* By convention the first parameter is the older perl, e.g: your system perl, and the second parameter is the new perl, e.g: a perl you just compiled.
* `./bench` relies on the `time` utility, `time`'s output can differ across systems. It has only been tested in macOs and Ubuntu. 
