#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Test::Timer' );
}

diag( "Testing Test::Timer $Test::Timer::VERSION, Perl $], $^X" );
