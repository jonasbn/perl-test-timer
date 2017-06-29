
use strict;
use Test::Fatal; # like
use Test::More;

use Test::Timer;

$Test::Timer::alarm = 1;

like(
    exception { Test::Timer::_benchmark( sub { sleep(20); }, 1 ); },
    qr/Execution ran 2 seconds and exceeded threshold of 1 seconds and timed out/,
    'Caught timeout exception'
);

$Test::Timer::alarm = 2;

like(
    exception { Test::Timer::_benchmark( sub { sleep(20); }, 1 ); },
    qr/Execution ran 3 seconds and exceeded threshold of 1 seconds and timed out/,
    'Caught timeout exception'
);

done_testing();
