#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use Test::Timer; # time_atleast

if (scalar @ARGV < 2) {
    die "./time_atmost.pl <execution time in seconds> <threshold in seconds>\n";
}

my ($sleep, $threshold) = @ARGV;

time_atleast( sub { sleep($sleep); }, $threshold, "time_atleast: execution time parameter: $sleep minimum threshold parameter: $threshold" );

exit 0;
