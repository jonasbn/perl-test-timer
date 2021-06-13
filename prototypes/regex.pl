#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;

f( { diag => qr/\w+/ } );

sub f {
    my $struct = shift;

    print STDERR Dumper $struct;

    if ( ref $struct->{diag} eq 'Regexp' ) {
        print STDERR "We got a regex\n";
    }
    else {
        print STDERR "We dit NOT get a regex\n";
        print STDERR ref $struct->{diag};
        print STDERR "\n";
    }
}
