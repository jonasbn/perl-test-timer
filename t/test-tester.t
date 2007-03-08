# $Id: test-tester.t,v 1.3 2007-03-08 19:40:24 jonasbn Exp $

use strict;
use Test::Tester;
use Test::More tests => 24;

use Test::Timer;

Test::Timer::builder( Test::Tester::capture() );

check_test(
    sub {
        time_ok( sub { sleep(1); }, 2, 'Passing test' );
    },
    { ok => 1, name => 'Passing test', depth => 4 }
);

check_test(
    sub {
        time_ok( sub { sleep(2); }, 1, 'Failing test' );
    },
    { ok => 0, name => 'Failing test', depth => 4 }
);

check_test(
    sub {
        time_nok( sub { sleep(1); }, 2, 'Passing test' );
    },
    { ok => 0, name => 'Passing test', depth => 4 }
);

check_test(
    sub {
        time_nok( sub { sleep(2); }, 1, 'Failing test' );
    },
    { ok => 1, name => 'Failing test', depth => 4 }
);
