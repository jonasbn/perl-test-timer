#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use Test::Timer;    # time_atmost

if ( scalar @ARGV < 2 ) {
    die
        "./time_atmost.pl <execution time in seconds> <threshold in seconds>\n";
}

my ( $sleep, $upperthreshold ) = @ARGV;

time_atmost(
    sub { sleep($sleep); },
    $upperthreshold,
    "time_atmost: execution time parameter: $sleep maximum threshold parameter: $upperthreshold"
);

exit 0;
