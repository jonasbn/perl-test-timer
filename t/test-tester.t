# $Id: test-tester.t,v 1.1 2007-03-01 21:22:20 jonasbn Exp $

use strict;
use Test::Tester;
use Test::More qw(no_plan);

use Test::Timer;

Test::Timer::builder(Test::Tester::capture());

check_test(sub { 
	time_ok( sub { sleep(1); }, 2, 'Passing test' ); 
}, 
{ ok => 1, name => 'Passing test'});

check_test(sub { 
	time_ok( sub { sleep(2); }, 1, 'Failing test' );
},
{ ok => 0, name => 'Failing test'});

