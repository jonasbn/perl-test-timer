#!/usr/bin/env perl

use strict;
use warnings;

use Benchmark;

my $t0 = Benchmark->new;

sleep(1);

my $t1 = Benchmark->new;

print timediff( $t1, $t0 )->real;

print "\n";

exit 0;
