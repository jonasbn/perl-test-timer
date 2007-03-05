# $Id: time_atleast.t,v 1.1 2007-03-05 09:36:41 jonasbn Exp $

use strict;
use Test::More tests => 3;

BEGIN { use_ok('Test::Timer'); };

time_atleast( sub { sleep(2); }, 1, 'Failing test' );

time_atleast( sub { sleep(4); }, [0, 2], 'Failing test' ); 
