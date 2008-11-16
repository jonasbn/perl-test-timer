package Test::Timer;

# $Id: Timer.pm,v 1.15 2008-09-09 19:19:03 jonasbn Exp $

use warnings;
use strict;

use vars qw($VERSION @ISA @EXPORT);
use Benchmark;
use Carp qw(croak);
use Error qw(:try);
use Test::Builder;
use base 'Test::Builder::Module';

#own
use Test::Timer::TimeoutException;

@EXPORT = qw(time_ok time_nok time_atleast time_atmost time_between);

$VERSION = '0.05';

my $test  = Test::Builder->new;
our $alarm = 2; #default alarm

sub time_ok {
    return time_atmost(@_);
}

sub time_nok {
    my ( $code, $upperthreshold, $name ) = @_;

    my $ok = _runtest( $code, 0, $upperthreshold, $name );

    if ($ok == 1) {
        $ok = 0;
        $test->ok( $ok, $name );
        $test->diag( 'Test did not exceed specified threshold' );        
    } else {
        $ok = 1;
        $test->ok( $ok, $name );
    }
    
    return $ok;
}

sub time_atmost {
    my ( $code, $upperthreshold, $name ) = @_;

    my $ok = _runtest( $code, 0, $upperthreshold, $name );
    
    if ($ok == 1) {
        $test->ok( $ok, $name );
    } else {
        $test->ok( $ok, $name );
        $test->diag( 'Test exceeded specified threshold' );        
    }
    
    return $ok;
}

sub time_atleast {
    my ( $code, $lowerthreshold, $name ) = @_;

    my $ok = _runtest_atleast( $code, $lowerthreshold, undef, $name );
        
    if ($ok == 0) {
        $test->ok( $ok, $name );
        $test->diag( 'Test did not exceed specified threshold' );        
    } else {
        $test->ok( $ok, $name );
    }
    
    return $ok;
}

sub time_between {
    my ( $code, $lowerthreshold, $upperthreshold, $name ) = @_;

    my $ok = _runtest( $code, $lowerthreshold, $upperthreshold, $name );

    if ($ok == 1) {
        $test->ok( $ok, $name );
    } else {
        $ok = 0;
        $test->ok( $ok, $name );
        $test->diag( 'Test did not execute within specified interval' );        
    }
    
    return $ok;
}

sub _runtest {
    my ( $code, $lowerthreshold, $upperthreshold, $name ) = @_;

    my $within = 0;
    
    try {

        my $timestring = _benchmark( $code, $upperthreshold );
        my $time = _timestring2time($timestring);

        if ( defined $lowerthreshold && defined $upperthreshold ) {

            if ( $time >= $lowerthreshold && $time <= $upperthreshold ) {
                $within = 1;
            } else {
                $within = 0;
            }

        } else {
            croak 'Insufficient number of parameters';
        }
    }
    catch Test::Timer::TimeoutException with {
        my $E = shift;

        $test->ok( 0, $name );
        $test->diag( $E->{-text} );
    }
    otherwise {
        my $E = shift;
        croak( $E->{-text} );
    };

    return $within; 
}

sub _runtest_atleast {
    my ( $code, $lowerthreshold, $upperthreshold, $name ) = @_;

    my $exceed = 0;
    
    try {
        
        if ( defined $lowerthreshold ) {

            my $timestring = _benchmark( $code, $lowerthreshold );
            my $time = _timestring2time($timestring);

            if ( $time > $lowerthreshold ) {
                $exceed = 1;
            } else {
                $exceed = 0;
            }

        } else {
            croak 'Insufficient number of parameters';
        }
    }
    catch Test::Timer::TimeoutException with {
        my $E = shift;

        $test->ok( 0, $name );
        $test->diag( $E->{-text} );
    }
    otherwise {
        my $E = shift;
        croak( $E->{-text} );
    };

    return $exceed; 
}

sub _benchmark {
    my ( $code, $threshold ) = @_;

    my $timestring;
    my $alarm = $alarm + $threshold;
    
    try {
        local $SIG{ALRM} = sub {
            throw Test::Timer::TimeoutException(
                'Execution exceeded threshold and timed out');
        };

        alarm( $alarm );

        my $t0 = new Benchmark;
        &{$code};
        my $t1 = new Benchmark;

        $timestring = timestr( timediff( $t1, $t0 ) );
    }
    otherwise {
        my $E = shift;
        croak( $E->{-text} );
    };

    return $timestring;
}

sub _timestring2time {
    my $timestring = shift;

    my ($time) = $timestring =~ m/(\d+) /;

    return $time;
}

1;

__END__

=head1 NAME

Test::Timer - a test module to test/assert response times

=head1 VERSION

The documentation in this module describes version 0.04 of Test::Timer

=head1 SYNOPSIS

    use Test::Timer;
    
    time_ok( sub { doYourStuffButBeQuickAboutIt(); }, 1, 'threshold of one second');

    time_atmost( sub { doYourStuffYouHave10Seconds(); }, 10, 'threshold of 10 seconds');

    time_between( sub { doYourStuffYouHave5-10Seconds(); }, 5, 10,
        'lower threshold of 5 seconds and upper threshold of 10 seconds');

    #Will succeed
    time_nok( sub { sleep(2); }, 1, 'threshold of one second');
    
    time_atleast( sub { sleep(2); }, 2, 'threshold of one second');
    
    #Will fail after 5 (threshold) + 2 seconds (default alarm)
    time_ok( sub { while(1) { sleep(1); } }, 5, 'threshold of one second');

    $test::Timer::alarm = 6 #default 2 seconds

    #Will fail after 5 (threshold) + 6 seconds (specified alarm)
    time_ok( sub { while(1) { sleep(1); } }, 5, 'threshold of one second');


=head1 DESCRIPTION

Test::Timer implements a set of test primitives to test and assert test times
from bodies of code. The code is currently at the alpha stage and might change
in the future.

=head1 EXPORT

Test::Timer exports:

L<time_ok>, L<time_nok>, L<time_atleast>, L<time_atmost> and L<time_between>

=head1 SUBROUTINES/METHODS

=head2 time_ok

Takes the following parameters:

=over

=item * a reference to a block of code (anonymous sub)

=item * a threshold specified as a integer indicating a number of seconds

=item * a string specifying a test name

=back

    time_ok( sub { doYourStuffButBeQuickAboutIt(); }, 1, 'threshold of one second');

If the execution of the code exceeds the threshold the test fails

=head2 time_nok

The is the inverted variant of L</time_ok>, it passes if the threshold is
exceeded and fails if the benchmark of the code is within the specified
threshold.

The API is the same as for L</time_ok>.

    time_nok( sub { sleep(2); }, 1, 'threshold of one second');

=head2 time_atmost

This is syntactic sugar for L</time_ok>

    time_atmost( sub { doYourStuffButBeQuickAboutIt(); }, 1, 'threshold of one second');

=head2 time_atleast

    time_atleast( sub { sleep(2); }, 1, 'threshold of one second');

The test succeeds if the code takes at least the number of seconds specified by
the threshold.

Please be aware that Test::Timer, breaks the execution with an alarm specified
to trigger after the specified threshold + 2 seconds, so if you expect your
execution to run longer, set the alarm accordingly.

    $Test::Timer::alarm = $my_alarm_in_seconds;

See also diagnostics.

=head2 time_between

This method is a more extensive variant of L</time_atmost> and L</time_ok>, you
can specify a lower and upper threshold, the code has to execute within this
interval in order for the test to succeed

    time_between( sub { sleep(2); }, 5, 10,
        'lower threshold of 5 seconds and upper threshold of 10 seconds');

=head1 PRIVATE FUNCTIONS

=head2 _runtest

This is a method to handle the result from L</_benchmark> is initiates the
benchmark calling benchmark and based on whether it is within the provided
interval true (1) is returned and if not false (0).

=head2 _runtest_atleast

This is a simpler variant of the method above, it is the author's hope that is
can be refactored out at some point, due to the similarity with L</_runtest>.

=head2 _benchmark

This is the method doing the actual benchmark, if a better method is located
this is the place to do the handy work.

Currently L<Benchmark> is used. An alternative could be L<Devel::Timer>, but I
do not know this module very well and L<Benchmark> is core, so this is used for
know.

The method takes two parameters:

=over

=item * a code block via a code reference

=item * a threshold (the upper threshold, since this is added to the default
alarm.

=back

=head2 _timestring2time

This is the method extracts the seconds from benchmarks timestring and returns
it and an integer.

It takes the timestring from L</_benchmark>/L<Benchmark> and returns the seconds
part.

=head2 import

Test::Builder required import to do some import hokus-pokus for the test methods
exported from Test::Timer. Please refer to the documentation in L<Test::Builder>

=head1 DIAGNOSTICS

All tests either fail or succeed, but a few exceptions are implemented, these
are listed below.

=over

=item * Test did not exceed specified threshold, this message is diagnosis for
L</time_atleast> and L</time_nok> tests, which do not exceed their specified
threshold.

=item * Test exceeded specified threshold, this message is a diagnostic for
L</time_atmost> and L</time_ok>, if the specified threshold is surpassed.

This is the key point of the module, either your code is too slow and you should
address this or your threshold is too low, in which case you can set it a bit
higher and run the test again.

=item * Test did not execute within specified interval, this is the diagnostic
from L</time_between>, it is the diagnosis if the execution of the code is
not between the specified lower and upper thresholds.

=item * Insufficient parameters, this is the message if a specified test is not
provided with the sufficent number of parameters, consult this documentation
and correct accordingly.

=item * Execution exceeded threshold and timed out, the exception is thrown if
the execution of tested code exceeds even the alarm, which is default 2 seconds,
but can be set by the user or is equal to the uppertreshold + 2 seconds.

The exception results in a diagnostic for the failing test. This is a failsafe
to avoid that code runs forever. If you get this diagnose either your code is
too slow and you should address this or it might be error prone. If this is not
the case adjust the alarm setting to suit your situation.

=back

=head1 CONFIGURATION AND ENVIRONMENT

This module requires no special configuration or environment.

=head1 DEPENDENCIES

=over

=item * L<Carp>

=item * L<Benchmark>

=item * L<Error>

=item * L<Exporter>

=item * L<Test::Builder>    

=back

=head1 INCOMPATIBILITIES

This class holds no known incompatibilities.

=head1 BUGS AND LIMITATIONS

This class holds no known bugs.

As listed on the TODO, the current implementations only use seconds and
resolutions should be higher.

=head1 TEST AND QUALITY

The test suite currently covers 94.5% (release 0.02)

    ---------------------------- ------ ------ ------ ------ ------ ------ ------
    File                           stmt   bran   cond    sub    pod   time  total
    ---------------------------- ------ ------ ------ ------ ------ ------ ------
    blib/lib/Test/Timer.pm         94.2  100.0   66.7   92.3  100.0  100.0   93.5
    ...Timer/TimeoutException.pm  100.0    n/a    n/a  100.0  100.0    0.0  100.0
    Total                          95.2  100.0   66.7   93.8  100.0  100.0   94.5
    ---------------------------- ------ ------ ------ ------ ------ ------ ------

The L<Test::Perl::Critic> test runs with severity 5 (gentle) for now, please
refer to t/critic.t and t/perlcriticrc

Set TEST_POD to enable L<Test::Pod> test in t/pod.t and L<Test::Pod::Coverage>
test in t/pod-coverage.t

Set TEST_AUTHOR to enable L<Test::Perl::Critic> test in t/critic.t

=head1 TODO

=over

=item * Implement higher resolution for thresholds

=item * Factor out L</_runtest_atleast>

=item * Add more tests to get a better feeling for the use and border cases
requiring alarm etc.

=item * Rewrite POD to emphasize L</time_atleast> over L</time_ok>

=back

=head1 SEE ALSO

=over

=item * L<Test::Benchmark>

=back

=head1 BUGS

Please report any bugs or feature requests to C<bug-test-timer at rt.cpan.org>,
or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Test-Timer>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Test::Timer

You can also look for information at:

=over

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Test-Timer>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Test-Timer>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Test-Timer>

=item * Search CPAN

L<http://search.cpan.org/dist/Test-Timer>

=back

=head1 ACKNOWLEDGEMENTS

=over

=item Gabor Szabo (GZABO), suggestion for specification of interval thresholds
even though this was obsoleted by the later introduced time_between

=item Paul Leonerd Evans (PEVANS), suggestions for time_atleast and time_atmost and the handling of $SIG{ALRM}.

= brian d foy (BDFOY), for patch to L</_run_test>

=back

=head1 DEVELOPMENT

This module is very much alpha stage, so pacthes and suggestions are more that
welcome, I also think there are some pitfalls and caveats I have not yet seen.

So feedback/patches is more than welcome.

=head1 AUTHOR

=over

=item * Jonas B. Nielsen (jonasbn) C<< <jonasbn@cpan.org> >>

=back

=head1 LICENSE AND COPYRIGHT

Test::Timer and related modules are (C) by Jonas B. Nielsen,
(jonasbn) 2007

Test::Timer and related modules are released under the artistic
license

The distribution is licensed under the Artistic License, as specified
by the Artistic file in the standard perl distribution
(http://www.perl.com/language/misc/Artistic.html).

=cut
