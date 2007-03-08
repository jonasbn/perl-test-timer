
use Test::More tests => 2;

BEGIN {
    use_ok('Test::Timer::TimeoutException');
    use_ok('Test::Timer');
}

diag("Testing Test::Timer $Test::Timer::VERSION, Perl $], $^X");
