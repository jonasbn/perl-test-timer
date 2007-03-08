package Test::Timer;

# $Id: Timer.pm,v 1.10 2007-03-08 21:40:40 jonasbn Exp $

use warnings;
use strict;

use vars qw($VERSION @ISA @EXPORT);
use Benchmark;
use Carp qw(croak);
use Error qw(:try);

use Test::Builder;
require Exporter;

use Test::Timer::TimeoutException;

@ISA    = qw(Exporter);
@EXPORT = qw(time_ok time_nok time_atleast time_atmost time_between);

$VERSION = '0.02';

my $test  = Test::Builder->new;
our $alarm = 2; #default alarm

sub time_ok {
    my ( $code, $upperthreshold, $name ) = @_;

    my $ok = 0;

    try {
        my $timestring = _benchmark( $code, $upperthreshold );
        my $time = _timestring2time($timestring);

        my ($lowerthreshold);

        if ( ref $upperthreshold eq 'ARRAY' ) {
            if ( scalar @{$upperthreshold} == 2 ) {
                $lowerthreshold = $upperthreshold->[0];
                $upperthreshold = $upperthreshold->[1];
            } elsif ( scalar @{$upperthreshold} == 1 ) {
                $upperthreshold = $upperthreshold->[0];
            } else {
                croak('Unsupported number of thresholds');
            }
        }

        if ( $lowerthreshold && $upperthreshold ) {

            if ( $time > $lowerthreshold && $time < $upperthreshold ) {
                $ok = 1;
                $test->ok( $ok, $name );
            } else {
                $test->ok( $ok, $name );
                $test->diag(
                    "$name not witin specified thresholds $timestring");
            }

        } elsif ( $upperthreshold && $time < $upperthreshold ) {
            $ok = 1;
            $test->ok( $ok, $name );
        } else {
            $test->ok( $ok, $name );
            $test->diag("$name exceeded threshold $timestring");
        }
    }
    catch Test::Timer::TimeoutException with {
        my $E = shift;

        $ok = 0;
        $test->ok( $ok, $name );
        $test->diag( $E->{-text} );
    }
    otherwise {
        my $E = shift;
        croak( $E->{-text} );
    };

    return $ok;
}

sub time_nok {
    my ( $code, $upperthreshold, $name ) = @_;

    my $ok;

    try {
        my $timestring = _benchmark( $code, $upperthreshold );
        my $time = _timestring2time($timestring);

        my ($lowerthreshold);

        if ( ref $upperthreshold eq 'ARRAY' ) {
            if ( scalar @{$upperthreshold} == 2 ) {
                $lowerthreshold = $upperthreshold->[0];
                $upperthreshold = $upperthreshold->[1];
            } elsif ( scalar @{$upperthreshold} == 1 ) {
                $upperthreshold = $upperthreshold->[0];
            } else {
                croak('Unsupported number of thresholds');
            }
        }

        if ( $lowerthreshold && $upperthreshold ) {

            if ( $time < $lowerthreshold && $time > $lowerthreshold ) {
                $ok = 1;
                $test->ok( $ok, $name );
            } else {
                $test->ok( $ok, $name );
                $test->diag(
                    "$name does not exceed specified thresholds $timestring");
            }

        } elsif ( $upperthreshold && $time > $upperthreshold ) {
            $ok = 1;
            $test->ok( $ok, $name );
        } else {
            $test->ok( $ok, $name );
            $test->diag("$name did not exceed threshold $timestring");
        }
    }
    catch Test::Timer::TimeoutException with {
        my $E = shift;

        $ok = 0;
        $test->ok( $ok, $name );
        $test->diag( $E->{-text} );
    }
    otherwise {
        my $E = shift;
        croak( $E->{-text} );
    };

    return $ok;
}

sub time_atmost {
    return time_ok(@_);
}

sub time_atleast {
    return time_nok(@_);
}

sub time_between {
    my ( $code, $lowerthreshold, $upperthreshold, $name ) = @_;
    return time_ok( $code, [ $lowerthreshold, $upperthreshold ], $name );
}

sub _benchmark {
    my ( $code, $threshold, $name ) = @_;

    my $timestring;

    try {

        local $SIG{ALRM} = sub {
            throw Test::Timer::TimeoutException(
                'Execution exceeded threshold and timed out');
        };

        alarm( $threshold + $alarm );

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

sub import {
    my ($self) = shift;
    my $pack = caller;

    $test->exported_to($pack);
    $test->plan(@_);

    $self->export_to_level( 1, $self, @EXPORT );

    return;
}

sub builder {
    $test = shift;

    return $test;
}

1;

__END__

=head1 NAME

Test::Timer - a test module to test/assert response times

=head1 VERSION

The documentation in this module describes version 0.02 of Test::Timer

=head1 SYNOPSIS

    use Test::Timer;
    
    time_ok( sub { doYourStuffButBeQuickAboutIt(); }, 1, 'threshold of one second');

    time_ok( sub { doYourStuffYouHave10Seconds(); }, 10, 'threshold of 10 seconds');

    time_ok( sub { doYourStuffYouHave5-10Seconds(); }, [5, 10],
        'lower threshold of 5 seconds and upper threshold of 10 seconds');


    time_nok( sub { sleep(2); }, 1, 'threshold of one second');

    time_nok( sub { sleep(2); }, [5, 10],
        'lower threshold of 5 seconds and upper threshold of 10 seconds');

    
    #Will fail after 5 (threshold) + 2 seconds (default alarm)
    time_ok( sub { while(1) { sleep(1); } }, 5, 'threshold of one second');

    $test::Timer::alarm = 6

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

Some Perl code, a threshold and a name for the test

    time_ok( sub { doYourStuffButBeQuickAboutIt(); }, 1, 'threshold of one second');

If the execution of the code exceeds the threshold the test fails

Alternatively you can specify an interval using a reference to an Array as the second
parameter:

    time_ok( sub { doYourStuffYouHave5-10Seconds(); }, [5, 10],
        'lower threshold of 5 seconds and upper threshold of 10 seconds');

=head2 time_nok

The is the inverted variant of B<time_ok>, it passes if the threshold is
exceeded and fails if the benchmark of the body of code is within the specified
threshold.

The API is the same as for L</time_ok>.

    time_nok( sub { sleep(2); }, 1, 'threshold of one second');

    time_nok( sub { sleep(2); }, [5, 10],
        'lower threshold of 5 seconds and upper threshold of 10 seconds');

=head2 time_atmost

This method is just syntactic sugar for the first call variant of B<time_ok>

    time_atmost( sub { doYourStuffButBeQuickAboutIt(); }, 1, 'threshold of one second');

=head2 time_atleast

This method is just syntactic sugar for the first call variant of B<time_nok>

    time_atleast( sub { sleep(2); }, 1, 'threshold of one second');

The test succeeds if the code takes at least the number of seconds specified by
the threshold.

Please be aware that Test::Timer, breaks the execution with an alarm specified
to trigger after the specified threshold + 2 seconds, so if you expect your
execution to run longer, set the alarm accordingly.

    $Test::Timer::alarm = $my_alarm_in_seconds;

=head2 time_between

This method is just syntactic sugar for the second call variant of B<time_ok>

    time_between( sub { sleep(2); }, 5, 10,
        'lower threshold of 5 seconds and upper threshold of 10 seconds');

=head1 PRIVATE FUNCTIONS

=head2 _benchmark

This is the method doing the actual benchmark, if a better method is located
this is the place to do the handy work.

Currently L<Benchmark> is used. An alternative could be L<Devel::Timer>, but I
do not know this module very well and L<Benchmark> is core.

=head2 _timestring2time

This is the method extracts the seconds from benchmarks timestring and returns
it.

=head2 import

Test::Builder required import to do some import hokus-pokus for the test methods
exported from Test::Timer.

=head2 builder

Test::Builder required B<builder> to do some other hokus-pokus to get the
L<Test::Builder> object exposed in the specified way.

=head1 DIAGNOSTICS

All tests either fail or succeed, but a few exceptions are implemented, these
are listed below.

=over

=item * 

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

The test suite currently covers 85.6% (release 0.02)

    ---------------------------- ------ ------ ------ ------ ------ ------ ------
    File                           stmt   bran   cond    sub    pod   time  total
    ---------------------------- ------ ------ ------ ------ ------ ------ ------
    blib/lib/Test/Timer.pm         87.0   83.3   44.4   92.0  100.0  100.0   83.5
    ...Timer/TimeoutException.pm  100.0    n/a    n/a  100.0  100.0    0.0  100.0
    Total                          89.0   83.3   44.4   93.5  100.0  100.0   85.6
    ---------------------------- ------ ------ ------ ------ ------ ------ ------

The L<Perl::Critic> test runs with severity 5 for now.

=head1 TODO

=over

=item * Implement higher resolution for thresholds

=item * Implement accessors to the alarm

=item * Add more tests to get a better feeling for the use and border cases
requiring alarm etc.

=back

=head1 SEE ALSO

=over

=item * L<Test::Benchmark>

=back

=head1 BUGS

Please report any bugs or feature requests to
C<bug-test-timer at rt.cpan.org>, or through the web interface at
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

=item Paul Leonerd Evans (PEVANS), suggestions for time_atleast and time_atmost
and the handling of $SIG{ALRM}.

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

Date-Holidays and related modules are (C) by Jonas B. Nielsen,
(jonasbn) 2007

Test::Timer and related modules are released under the artistic
license

The distribution is licensed under the Artistic License, as specified
by the Artistic file in the standard perl distribution
(http://www.perl.com/language/misc/Artistic.html).

=cut

1;
