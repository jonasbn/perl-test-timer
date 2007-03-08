# $Id: time_nok.t,v 1.3 2007-03-08 21:40:40 jonasbn Exp $

use strict;
use Test::More tests => 5;

use Test::Exception;

BEGIN { use_ok('Test::Timer'); }

time_nok( sub { sleep(2); }, 1, 'Failing test' );

$Test::Timer::alert = 6;

time_nok( sub { sleep(4); }, [ 0, 2 ], 'Failing test' );

time_nok( sub { sleep(4); }, [ 2 ], 'Failing test' );

dies_ok { time_nok(sub { sleep(1); }, [], ); } 'Dying test';
