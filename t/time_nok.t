# $Id: time_nok.t,v 1.4 2007-03-10 19:29:39 jonasbn Exp $

use strict;
use Test::More tests => 3;

use Test::Exception;

BEGIN { use_ok('Test::Timer'); }

time_nok( sub { sleep(2); }, 1, 'Failing test' );

$Test::Timer::alert = 6;

dies_ok { time_nok(sub { sleep(1); } ); } 'Dying test';
