#Courtesy of chromatic
#http://search.cpan.org/~chromatic/Test-Kwalitee/lib/Test/Kwalitee.pm

# $Id$

use strict;
use warnings;
use Env qw($RELEASE_TESTING);
use Test::More;

eval {
    require Test::Kwalitee;
};

if ($@ and $RELEASE_TESTING) {
    plan skip_all => 'Test::Kwalitee not installed; skipping';
} elsif (not $RELEASE_TESTING) {
    plan skip_all => 'set RELEASE_TESTING to enable this test';
} else {
    Test::Kwalitee->import();
}