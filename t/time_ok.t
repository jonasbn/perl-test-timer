# $Id: time_ok.t,v 1.3 2007-03-08 19:40:24 jonasbn Exp $

use strict;
use Test::More tests => 3;

BEGIN { use_ok('Test::Timer'); }

time_ok( sub { sleep(1); }, 2, 'Passing test' );

time_ok( sub { sleep(1); }, [ 0, 2 ], 'Passing test' );
