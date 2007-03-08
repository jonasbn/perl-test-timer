# $Id: time_ok.t,v 1.4 2007-03-08 21:40:40 jonasbn Exp $

use strict;
use Test::More tests => 5;

use Test::Exception;

BEGIN { use_ok('Test::Timer'); }

time_ok( sub { sleep(1); }, 2, 'Passing test' );

time_ok( sub { sleep(1); }, [ 0, 2 ], 'Passing test' );

time_ok( sub { sleep(1); }, [ 2 ], 'Passing test' );

dies_ok { time_ok(sub { sleep(1); }, [], ); } 'Dying test';
