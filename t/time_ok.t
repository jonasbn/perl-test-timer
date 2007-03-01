# $Id: time_ok.t,v 1.1 2007-03-01 21:22:20 jonasbn Exp $

use strict;
use Test::More qw(no_plan);

BEGIN { use_ok('Test::Timer'); };

time_ok( sub { sleep(1); }, 2, 'Passing test' ); 

#time_ok( sub { sleep(2); }, 1, 'Failing test' );
