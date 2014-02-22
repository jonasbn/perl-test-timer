# $Id: time_ok.t,v 1.5 2007-03-10 19:29:39 jonasbn Exp $

use strict;
use Test::More tests => 3;

use Test::Exception;

BEGIN { use_ok('Test::Timer'); }

time_ok( sub { sleep(1); }, 2, 'Passing test' );

dies_ok { time_ok(sub { sleep(1); } ); } 'Dying test, missing parameters';
