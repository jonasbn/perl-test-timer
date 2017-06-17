#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use Test::Timer; # time_between

if (scalar @ARGV < 3) {
    die "./time_between.pl <execution time in seconds> <lower threshold in seconds> <upper threshold in seconds\n";
}

my ($sleep, $lowerthreshold, $upperthreshold) = @ARGV;

time_between( sub { sleep($sleep); }, $lowerthreshold, $upperthreshold, "time_between: execution time parameter: $sleep lower threshold parameter: $lowerthreshold upper threshold parameter: $upperthreshold" );

exit 0;
