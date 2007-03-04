# $Id: time_ok.t,v 1.2 2007-03-04 21:54:12 jonasbn Exp $

use strict;
use Test::More tests => 3;

BEGIN { use_ok('Test::Timer'); };

time_ok( sub { sleep(1); }, 2, 'Passing test' ); 

time_ok( sub { sleep(1); }, [0, 2], 'Passing test' ); 
