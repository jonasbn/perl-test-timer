package Test::Timer;

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

my $Test = Test::Builder->new;

my $alarm = 2; #default alarm

=head1 NAME

Test::Timer - a module to test/assert reponse times

=head1 VERSION

The documentation in this module describes version 0.01

=cut

$VERSION = '0.01';

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

    $Test::Timer::alarm = 6

    #Will fail after 5 (threshold) + 6 seconds (specified alarm)
    time_ok( sub { while(1) { sleep(1); } }, 5, 'threshold of one second');


=head1 EXPORT

L</time_ok> andn L</time_nok>

=head1 FUNCTIONS

=head2 time_ok

Takes the following parameters:

some Perl code, a threshold and a name for the test

=cut

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
                croak ("Unsupported number of thresholds");
            }
        }

        if ($lowerthreshold && $upperthreshold) {
    
            if ($time > $lowerthreshold && $time < $upperthreshold) {
                $ok = 1;
                $Test->ok($ok, $name);
            } else {
                $Test->ok($ok, $name);
                $Test->diag("$name not witin specified thresholds $timestring");
            }
            
        } elsif ($upperthreshold && $time < $upperthreshold) {
            $ok = 1;
            $Test->ok($ok, $name);
        } else {
            $Test->ok($ok, $name);
            $Test->diag("$name exceeded threshold $timestring");
        }
    }
    catch Test::Timer::TimeoutException with {
        my $E = shift;
        
        $ok = 0;
		$Test->ok($ok, $name);
		$Test->diag($E->{-text});
    }
    otherwise {
        my $E = shift;
        croak($E->{-text});
    };
    	
	return $ok;
}

=head2 time_nok

The is the inverted variant of timeok, it passes if the
threshold is exceeded and fails if the benchmark of the
body of code is within the specified threshold.

The API is the same as for L</time_ok>.

=cut

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
                croak ("Unsupported number of thresholds");
            }
        }
    
        if ($lowerthreshold && $upperthreshold) {
    
            if ($time < $lowerthreshold && $time > $lowerthreshold) {
                $ok = 1;
                $Test->ok($ok, $name);
            } else {
                $Test->ok($ok, $name);
                $Test->diag("$name does not exceed specified thresholds $timestring");
            }
            
        } elsif ($upperthreshold && $time > $upperthreshold) {
            $ok = 1;
            $Test->ok($ok, $name);
        } else {
            $Test->ok($ok, $name);
            $Test->diag("$name did not exceed threshold $timestring");
        }
    }
    catch Test::Timer::TimeoutException with {
        my $E = shift;
        
        $ok = 0;
		$Test->ok($ok, $name);
		$Test->diag($E->{-text});
    }
    otherwise {
        my $E = shift;
        die($E->{-text});
    };
    
	return $ok;    
}

=head2 time_atmost

=cut

sub time_atmost {
    return time_ok(@_);
}

=head2 time_atleast

=cut

sub time_atleast {
    return time_nok(@_);
}

=head2 time_between

=cut

sub time_between {
    my ($code, $lowerthreshold, $upperthreshold, $name) = @_;
    return time_ok($code, [$lowerthreshold, $upperthreshold], $name);
}

=head1 PRIVATE FUNCTIONS

=head2 _benchmark

=cut

sub _benchmark {
    my ($code, $threshold, $name) = @_;
	
	my $timestring;
    
    try {
        
        local $SIG{ALRM} = sub { throw Test::Timer::TimeoutException("Execution exceeded threshold and timed out"); };
        if ($alarm) {
            alarm($threshold + $alarm);
        }
        
        my $t0 = new Benchmark;
        &$code;
        my $t1 = new Benchmark;
        
        $timestring = timestr(timediff($t1, $t0));
    }
    otherwise {
        my $E = shift;
        croak($E->{-text});
    };
	    
	return $timestring;
}

=head2 _timestring2time

=cut

sub _timestring2time {
    my $timestring = shift;
    
    my ($time) = $timestring =~ m/(\d+) /;

    return $time;  
}

=head2 import

Test::Builder required import to do some import hokus-pokus for the test methods
exported from Test::Timer.

=cut

sub import {
	my($self) = shift;
	my $pack = caller;
	
	$Test->exported_to($pack);
	$Test->plan(@_);
	
	$self->export_to_level(1, $self, @EXPORT);
	
	return;
}

=head2 builder

Test::Builder required B<builder> to do some other hokus-pokus to get the
L<Test::Builder> object exposed in the specified way.

=cut

sub builder {
    
    if (@_)
	{
		$Test = shift;
	}
	
	return $Test;
}

=head1 AUTHOR

jonasbn, C<< <jonasbn at cpan.org> >>

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

=head1 COPYRIGHT & LICENSE

Copyright 2007 jonasbn, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Test::Timer
