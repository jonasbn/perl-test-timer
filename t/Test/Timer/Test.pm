package Test::Timer::Test;

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);

our @EXPORT_OK = qw(_sleep);

sub _sleep {
    my $interval = shift;

    sleep($interval);

    return $interval;
}

1;
