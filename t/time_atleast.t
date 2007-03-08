# $Id: time_atleast.t,v 1.2 2007-03-08 19:40:24 jonasbn Exp $

use strict;
use Test::More tests => 3;

BEGIN { use_ok('Test::Timer'); }

time_atleast( sub { sleep(2); }, 1, 'Failing test' );

time_atleast( sub { sleep(4); }, [ 0, 2 ], 'Failing test' );
