package Test::Timer;

# $Id: Timer.pm,v 1.5 2007-03-05 21:17:44 jonasbn Exp $

use warnings;
use strict;

use vars qw($VERSION @ISA @EXPORT);
use Benchmark;
use Carp qw(croak);
use Error qw(:try);

use Test::Builder;
require Exporter;

use lib qw(../../lib);
use Test::Timer::TimeoutException;

@ISA = qw(Exporter);
@EXPORT = qw(time_ok time_nok time_atleast time_atmost time_between);

$VERSION = '0.01';

my $test = Test::Builder->new;
my $alarm = 2; #default alarm

sub time_ok {
    my ($code, $upperthreshold, $name) = @_;
    
    my $ok = 0;
    
    try {
        my $timestring = _benchmark($code, $upperthreshold);
        my $time = _timestring2time($timestring);
        
        my ($lowerthreshold);
        
        if (ref $upperthreshold eq 'ARRAY') {
            if (scalar @{$upperthreshold} == 2) {
                $lowerthreshold = $upperthreshold->[0];
                $upperthreshold = $upperthreshold->[1];
            } elsif (scalar@{$upperthreshold} == 1) {
                $upperthreshold = $upperthreshold->[0];
            } else {
                croak ('Unsupported number of thresholds');
            }
        }

        if ($lowerthreshold && $upperthreshold) {
    
            if ($time > $lowerthreshold && $time < $upperthreshold) {
                $ok = 1;
                $test->ok($ok, $name);
            } else {
                $test->ok($ok, $name);
                $test->diag("$name not witin specified thresholds $timestring");
            }
            
        } elsif ($upperthreshold && $time < $upperthreshold) {
            $ok = 1;
            $test->ok($ok, $name);
        } else {
            $test->ok($ok, $name);
            $test->diag("$name exceeded threshold $timestring");
        }
    }
    catch Test::Timer::TimeoutException with {
        my $E = shift;
        
        $ok = 0;
		$test->ok($ok, $name);
		$test->diag($E->{-text});
    }
    otherwise {
        my $E = shift;
        croak($E->{-text});
    };
    	
	return $ok;
}

sub time_nok {
    my ($code, $upperthreshold, $name) = @_;

    my $ok;
    
    try {
        my $timestring = _benchmark($code, $upperthreshold);
        my $time = _timestring2time($timestring);

        my ($lowerthreshold);
    
        if (ref $upperthreshold eq 'ARRAY') {
            if (scalar @{$upperthreshold} == 2) {
                $lowerthreshold = $upperthreshold->[0];
                $upperthreshold = $upperthreshold->[1];
            } elsif (scalar@{$upperthreshold} == 1) {
                $upperthreshold = $upperthreshold->[0];
            } else {
                croak ('Unsupported number of thresholds');
            }
        }
    
        if ($lowerthreshold && $upperthreshold) {
    
            if ($time < $lowerthreshold && $time > $lowerthreshold) {
                $ok = 1;
                $test->ok($ok, $name);
            } else {
                $test->ok($ok, $name);
                $test->diag("$name does not exceed specified thresholds $timestring");
            }
            
        } elsif ($upperthreshold && $time > $upperthreshold) {
            $ok = 1;
            $test->ok($ok, $name);
        } else {
            $test->ok($ok, $name);
            $test->diag("$name did not exceed threshold $timestring");
        }
    }
    catch Test::Timer::TimeoutException with {
        my $E = shift;
        
        $ok = 0;
		$test->ok($ok, $name);
		$test->diag($E->{-text});
    }
    otherwise {
        my $E = shift;
        croak($E->{-text});
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
    my ($code, $lowerthreshold, $upperthreshold, $name) = @_;
    return time_ok($code, [$lowerthreshold, $upperthreshold], $name);
}

sub _benchmark {
    my ($code, $threshold, $name) = @_;
	
	my $timestring;
    
    try {
        
        local $SIG{ALRM} = sub {
            throw Test::Timer::TimeoutException('Execution exceeded threshold and timed out');
        };
        
        if ($alarm) {
            alarm($threshold + $alarm);
        }
        
        my $t0 = new Benchmark;
        &{$code};
        my $t1 = new Benchmark;
        
        $timestring = timestr(timediff($t1, $t0));
    }
    otherwise {
        my $E = shift;
        croak($E->{-text});
    };
	    
	return $timestring;
}

sub _timestring2time {
    my $timestring = shift;
    
    my ($time) = $timestring =~ m/(\d+) /;

    return $time;  
}

sub import {
	my($self) = shift;
	my $pack = caller;
	
	$test->exported_to($pack);
	$test->plan(@_);
	
	$self->export_to_level(1, $self, @EXPORT);
	
	return;
}

sub builder {
    
    if (@_)
	{
		$test = shift;
	}
	
	return $test;
}

1;

__END__

=head1 NAME

Test::Timer - a module to test/assert reponse times

=head1 VERSION

The documentation in this module describes version 0.01 of Test::Timer

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

=head1 EXPORT

Test::Timer exports:

L<time_ok>, L<time_nok>, L<time_atleast>, L<time_atmost> and L<time_between>

=head1 SUBROUTINES/METHODS

=head2 time_ok

Takes the following parameters:

some Perl code, a threshold and a name for the test

=head2 time_nok

The is the inverted variant of timeok, it passes if the
threshold is exceeded and fails if the benchmark of the
body of code is within the specified threshold.

The API is the same as for L</time_ok>.

=head2 time_atmost

=head2 time_atleast

=head2 time_between

=head1 PRIVATE FUNCTIONS

=head2 _benchmark

=head2 _timestring2time

=head2 import

Test::Builder required import to do some import hokus-pokus for the test methods
exported from Test::Timer.

=head2 builder

Test::Builder required B<builder> to do some other hokus-pokus to get the
L<Test::Builder> object exposed in the specified way.

=head1 DIAGNOSTICS

=over

=item * 

=back

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item * L<Error>

=back

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 TEST AND QUALITY

=head1 TODO

=over

=item *

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
