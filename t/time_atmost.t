# $Id: time_atmost.t,v 1.3 2007-03-10 19:29:39 jonasbn Exp $

use strict;
use Test::More tests => 2;

BEGIN { use_ok('Test::Timer'); }

time_atmost( sub { sleep(1); }, 2, 'Passing test' );
