# $Id: time_atleast.t,v 1.3 2007-03-10 19:29:39 jonasbn Exp $

use strict;
use Test::More tests => 2;

BEGIN { use_ok('Test::Timer'); }

time_atleast( sub { sleep(2); }, 1, 'Failing test' );
