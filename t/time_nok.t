# $Id: time_nok.t,v 1.1 2007-03-04 21:54:12 jonasbn Exp $

use strict;
use Test::More tests => 3;

BEGIN { use_ok('Test::Timer'); };

time_nok( sub { sleep(2); }, 1, 'Failing test' );

$Test::Timer::alert = 6;

time_nok( sub { sleep(4); }, [0, 2], 'Failing test' ); 
