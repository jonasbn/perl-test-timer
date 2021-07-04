# Test::Timer

[![CPAN version](https://badge.fury.io/pl/Test-Timer.svg)](http://badge.fury.io/pl/Test-Timer)
![stability-stable](https://img.shields.io/badge/stability-stable-green.svg)
[![Build Status](https://travis-ci.org/jonasbn/perl-test-timer.svg?branch=master)](https://travis-ci.org/jonasbn/perl-test-timer)
[![Coverage Status](https://coveralls.io/repos/github/jonasbn/perl-test-timer/badge.svg?branch=master)](https://coveralls.io/github/jonasbn/perl-test-timer?branch=master)
[![License: Artistic-2.0](https://img.shields.io/badge/License-Artistic%202.0-0298c3.svg)](https://opensource.org/licenses/Artistic-2.0)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/1391/badge)](https://bestpractices.coreinfrastructure.org/projects/1391)

<!-- MarkdownTOC bracket=round levels="1,2,3,4,5" indent="  " -->

- [NAME](#name)
- [VERSION](#version)
- [FEATURES](#features)
- [SYNOPSIS](#synopsis)
- [DESCRIPTION](#description)
- [EXPORT](#export)
- [SUBROUTINES/METHODS](#subroutinesmethods)
  - [time\_ok](#time_ok)
  - [time\_nok](#time_nok)
  - [time\_atmost](#time_atmost)
  - [time\_atleast](#time_atleast)
  - [time\_between](#time_between)
- [PRIVATE FUNCTIONS](#private-functions)
  - [\_runtest](#_runtest)
  - [\_benchmark](#_benchmark)
  - [import](#import)
- [DIAGNOSTICS](#diagnostics)
- [CONFIGURATION AND ENVIRONMENT](#configuration-and-environment)
- [DEPENDENCIES](#dependencies)
- [INCOMPATIBILITIES](#incompatibilities)
- [BUGS AND LIMITATIONS](#bugs-and-limitations)
- [TEST AND QUALITY](#test-and-quality)
  - [CONTINUOUS INTEGRATION](#continuous-integration)
- [SEE ALSO](#see-also)
- [ISSUE REPORTING](#issue-reporting)
- [SUPPORT](#support)
- [DEVELOPMENT](#development)
- [AUTHOR](#author)
- [ACKNOWLEDGEMENTS](#acknowledgements)
- [LICENSE AND COPYRIGHT](#license-and-copyright)

<!-- /MarkdownTOC -->

# NAME

Test::Timer - test module to test/assert response times

# VERSION

The documentation describes version 2.10 of Test::Timer

# FEATURES

- Test subroutines to implement unit-tests to time that your code executes before a specified threshold
- Test subroutines to implement unit-tests to time that your code execution exceeds a specified threshold
- Test subroutine to implement unit-tests to time that your code executes within a specified time frame
- Supports measurements in seconds
- Implements configurable alarm signal handler to make sure that your tests do not execute forever

# SYNOPSIS

    use Test::Timer;

    time_ok( sub { doYourStuffButBeQuickAboutIt(); }, 1, 'threshold of one second');

    time_atmost( sub { doYourStuffYouHave10Seconds(); }, 10, 'threshold of 10 seconds');

    time_between( sub { doYourStuffYouHave5-10Seconds(); }, 5, 10,
        'lower threshold of 5 seconds and upper threshold of 10 seconds');

    # Will succeed
    time_nok( sub { sleep(2); }, 1, 'threshold of one second');

    time_atleast( sub { sleep(2); }, 2, 'threshold of one second');

    # Will fail after 5 (threshold) + 2 seconds (default alarm)
    time_ok( sub { while(1) { sleep(1); } }, 5, 'threshold of one second');

    $test::Timer::alarm = 6 #default 2 seconds

    # Will fail after 5 (threshold) + 6 seconds (specified alarm)
    time_ok( sub { while(1) { sleep(1); } }, 5, 'threshold of one second');

# DESCRIPTION

Test::Timer implements a set of test primitives to test and assert test times
from bodies of code.

The key features are subroutines to assert or test the following:

- that a given piece of code does not exceed a specified time limit
- that a given piece of code takes longer than a specified time limit and does not exceed another

# EXPORT

Test::Timer exports:

- [time\_ok](#time_ok)
- [time\_nok](#time_nok)
- [time\_atleast](#time_atleast)
- [time\_atmost](#time_atmost)
- [time\_between](#time_between)

# SUBROUTINES/METHODS

## time\_ok

Takes the following parameters:

- a reference to a block of code (anonymous sub)
- a threshold specified as a integer indicating a number of seconds
- a string specifying a test name

    time_nok( sub { sleep(2); }, 1, 'threshold of one second');

If the execution of the code exceeds the threshold specified the test fail with the following diagnostic message

    Test ran 2 seconds and exceeded specified threshold of 1 seconds

## time\_nok

The is the inverted variant of [time\_ok](#time_ok), it passes if the threshold is
exceeded and fails if the benchmark of the code is within the specified
timing threshold.

The API is the same as for [time\_ok](#time_ok).

    time_nok( sub { sleep(1); }, 2, 'threshold of two seconds');

If the execution of the code executes below the threshold specified the test fail with the following diagnostic message

    Test ran 1 seconds and did not exceed specified threshold of 2 seconds

## time\_atmost

This is _syntactic sugar_ for [time\_ok](#time_ok)

    time_atmost( sub { doYourStuffButBeQuickAboutIt(); }, 1, 'threshold of one second');

If the execution of the code exceeds the threshold specified the test fail with the following diagnostic message

    Test ran N seconds and exceeded specified threshold of 1 seconds

N will be the actual measured execution time of the specified code

![time_atmost visualization](https://jonasbn.github.io/perl-test-timer/assets/images/time_atmost.png)

## time\_atleast

    time_atleast( sub { doYourStuffAndTakeYourTimeAboutIt(); }, 1, 'threshold of 1 second');

The test succeeds if the code takes at least the number of seconds specified by
the timing threshold.

If the code executes faster, the test fails with the following diagnostic message

    Test ran 1 seconds and did not exceed specified threshold of 2 seconds

Please be aware that Test::Timer, breaks the execution with an alarm specified
to trigger after the specified threshold + 2 seconds (default), so if you expect your
execution to run longer, set the alarm accordingly.

    $Test::Timer::alarm = $my_alarm_in_seconds;

See also [diagnostics](#diagnostics).

![time_atleast visualization](https://jonasbn.github.io/perl-test-timer/assets/images/time_atleast.png)

## time\_between

This method is a more extensive variant of [time\_atmost](#time_atmost) and [time\_ok](#time_ok), you
can specify a lower and upper threshold, the code has to execute within this
interval in order for the test to succeed

    time_between( sub { sleep(2); }, 5, 10,
        'lower threshold of 5 seconds and upper threshold of 10 seconds');

If the code executes faster than the lower threshold or exceeds the upper threshold, the test fails with the following diagnostic message

    Test ran 2 seconds and did not execute within specified interval 5 - 10 seconds

Or

    Test ran 12 seconds and did not execute within specified interval 5 - 10 seconds

![time_between visualization](https://jonasbn.github.io/perl-test-timer/assets/images/time_between.png)

# PRIVATE FUNCTIONS

## \_runtest

This is a method to handle the result from [\_benchmark](#_benchmark) is initiates the
benchmark calling benchmark and based on whether it is within the provided
interval true (1) is returned and if not false (0).

## \_benchmark

This is the method doing the actual benchmark, if a better method is located
this is the place to do the handy work.

Currently [Benchmark](https://metacpan.org/pod/Benchmark) is used. An alternative could be [Devel::Timer](https://metacpan.org/pod/Devel%3A%3ATimer), but I
do not know this module very well and [Benchmark](https://metacpan.org/pod/Benchmark) is core, so this is used for
now.

The method takes two parameters:

- a code block via a code reference
- a threshold (the upper threshold, since this is added to the default alarm

## import

Test::Builder required import to do some import _hokus-pokus_ for the test methods
exported from Test::Timer. Please refer to the documentation in [Test::Builder](https://metacpan.org/pod/Test%3A%3ABuilder)

# DIAGNOSTICS

All tests either fail or succeed, but a few exceptions are implemented, these
are listed below.

- Test did not exceed specified threshold, this message is diagnosis for [time\_atleast](#time_atleast) and [time\_nok](#time_nok) tests, which do not exceed their specified threshold
- Test exceeded specified threshold, this message is a diagnostic for [time\_atmost](#time_atmost) and [time\_ok](#time_ok), if the specified threshold is surpassed.

    This is the key point of the module, either your code is too slow and you should
    address this or your threshold is too low, in which case you can set it a bit
    higher and run the test again.

- Test did not execute within specified interval, this is the diagnostic from [time\_between](#time_between), it is the diagnosis if the execution of the code is not between the specified lower and upper thresholds
- Insufficient parameters, this is the message if a specified test is not provided with the sufficient number of parameters, consult this documentation and correct accordingly
- Execution exceeded threshold and timed out, the exception is thrown if the execution of tested code exceeds even the alarm, which is default 2 seconds, but can be set by the user or is equal to the upper threshold + 2 seconds

    The exception results in a diagnostic for the failing test. This is a fail-safe
    to avoid that code runs forever. If you get this diagnose either your code is
    too slow and you should address this or it might be error prone. If this is not
    the case adjust the alarm setting to suit your situation.

# CONFIGURATION AND ENVIRONMENT

This module requires no special configuration or environment.

Tests are sensitive and be configured using environment and configuration files, please
see the section on [test and quality](#test-and-quality).

# DEPENDENCIES

- [Carp](https://metacpan.org/pod/Carp)
- [Benchmark](https://metacpan.org/pod/Benchmark)
- [Error](https://metacpan.org/pod/Error)
- [Test::Builder](https://metacpan.org/pod/Test%3A%3ABuilder)
- [Test::Builder::Module](https://metacpan.org/pod/Test%3A%3ABuilder%3A%3AModule)

# INCOMPATIBILITIES

This module holds no known incompatibilities.

# BUGS AND LIMITATIONS

This module holds no known bugs.

The current implementations only use seconds and resolutions should be higher,
so the current implementation is limited to seconds as the highest resolution.

On occasion failing tests with CPAN-testers have been observed. This seem to be related to the test-suite
being not taking into account that some smoke-testers do not prioritize resources for the test run and that
additional processes/jobs are running. The test-suite have been adjusted to accommodate this but these issues
might reoccur.

# TEST AND QUALITY

[![Coverage Status](https://coveralls.io/repos/github/jonasbn/perl-test-timer/badge.svg?branch=master)](https://coveralls.io/github/jonasbn/perl-test-timer?branch=master)

Coverage report for the release described in this documentation (see [VERSION](#version)).

    ---------------------------- ------ ------ ------ ------ ------ ------ ------
    File                           stmt   bran   cond    sub    pod   time  total
    ---------------------------- ------ ------ ------ ------ ------ ------ ------
    blib/lib/Test/Timer.pm        100.0   95.0   66.6  100.0  100.0   99.9   98.0
    ...Timer/TimeoutException.pm  100.0    n/a    n/a  100.0  100.0    0.0  100.0
    Total                         100.0   95.0   66.6  100.0  100.0  100.0   98.4
    ---------------------------- ------ ------ ------ ------ ------ ------ ------

The [Test::Perl::Critic](https://metacpan.org/pod/Test%3A%3APerl%3A%3ACritic) test runs with severity 5 (gentle) for now, please
refer to `t/critic.t` and `t/perlcriticrc`.

Set TEST\_POD to enable [Test::Pod](https://metacpan.org/pod/Test%3A%3APod) test in `t/pod.t` and [Test::Pod::Coverage](https://metacpan.org/pod/Test%3A%3APod%3A%3ACoverage)
test in `t/pod-coverage.t`.

Set TEST\_CRITIC to enable [Test::Perl::Critic](https://metacpan.org/pod/Test%3A%3APerl%3A%3ACritic) test in `t/critic.t`

## CONTINUOUS INTEGRATION

This distribution uses Travis for continuous integration testing, the
Travis reports are public available.

[![Build Status](https://travis-ci.org/jonasbn/perl-test-timer.svg?branch=master)](https://travis-ci.org/jonasbn/perl-test-timer)

# SEE ALSO

- [Test::Benchmark](https://metacpan.org/pod/Test%3A%3ABenchmark)

# ISSUE REPORTING

Please report any bugs or feature requests using GitHub

- [GitHub Issues](https://github.com/jonasbn/perl-test-timer/issues)

# SUPPORT

You can find (this) documentation for this module with the `perldoc` command.

    perldoc Test::Timer

You can also look for information at:

- [Homepage](https://jonasbn.github.io/perl-test-timer/)
- [MetaCPAN](https://metacpan.org/pod/Test-Timer)
- [AnnoCPAN: Annotated CPAN documentation](http://annocpan.org/dist/Test-Timer)
- [CPAN Ratings](http://cpanratings.perl.org/d/Test-Timer)

# DEVELOPMENT

- [GitHub Repository](https://github.com/jonasbn/perl-test-timer), please see [the guidelines for contributing](https://github.com/jonasbn/perl-test-timer/blob/master/CONTRIBUTING.md).

# AUTHOR

- Jonas B. Nielsen (jonasbn) `<jonasbn at cpan.org>`

# ACKNOWLEDGEMENTS

- Mohammad S Anwar, POD corrections PRs #23
- Erik Johansen, suggestion for clearing alarm
- Gregor Herrmann from the Debian Perl Group, PR #16 fixes to spelling mistakes
- Nigel Horne, issue #15 suggestion for better assertion in [time\_atleast](#time_atleast)
- Nigel Horne, issue #10/#12 suggestion for improvement to diagnostics
- p-alik, PR #4 eliminating warnings during test
- Kent Fredric, PR #7 addressing file permissions
- Nick Morrott, PR #5 corrections to POD
- Bartosz Jakubski, reporting issue #3
- Gabor Szabo (GZABO), suggestion for specification of interval thresholds even though this was obsoleted by the later introduced time\_between
- Paul Leonerd Evans (PEVANS), suggestions for time\_atleast and time\_atmost and the handling of $SIG{ALRM}. Also bug report for addressing issue with Debian packaging resulting in release 0.10
- brian d foy (BDFOY), for patch to [\_runtest](#_runtest)

# LICENSE AND COPYRIGHT

Test::Timer and related modules are (C) by Jonas B. Nielsen,
(jonasbn) 2007-2019

Test::Timer and related modules are released under the Artistic
License 2.0

Used distributions are under copyright of there respective authors and designated licenses

Image used on [website](https://jonasbn.github.io/perl-test-timer/) is under copyright by [Veri Ivanova](https://unsplash.com/photos/p3Pj7jOYvnM)
