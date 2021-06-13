#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;

my $rv = returner();

print STDERR "\$rv = $rv\n";

my @rv = returner();

print STDERR '@list ', Dumper @rv;

sub returner {

    return ( 1, 'abc' );
}
