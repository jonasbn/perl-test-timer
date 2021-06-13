#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use Test::Timer;    # time_nok

if ( scalar @ARGV < 2 ) {
    die "./time_nok.pl <execution time in seconds> <threshold in seconds>\n";
}

my ( $sleep, $threshold ) = @ARGV;

time_nok(
    sub { sleep($sleep); },
    $threshold,
    "time_nok: execution time parameter: $sleep maximum threshold parameter: $threshold"
);

exit 0;
