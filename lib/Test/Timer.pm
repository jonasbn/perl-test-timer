package Test::Timer;

use warnings;
use strict;

use vars qw($VERSION @ISA @EXPORT);
use Benchmark;

use Test::Builder;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(time_ok);

my $Test = Test::Builder->new;

=head1 NAME

Test::Timer - a module to test assertions in reponse times

=head1 VERSION

The documentation in this module describes version 0.01

=cut

$VERSION = '0.01';

=head1 SYNOPSIS

=head1 EXPORT

time_ok

=head1 FUNCTIONS

=head2 time_ok

Takes the following parameters:

some Perl code, a threshold and a name for the test

=cut

sub time_ok {
    my ($code, $threshold, $name) = @_;
	
	my $t0 = new Benchmark;

	{ &$code; };
	
	my $t1 = new Benchmark;

	my $timestring = timestr(timediff($t1, $t0));
	my ($time) = $timestring =~ m/(\d+) /;

	my $ok = 0;	
	if ($time < $threshold) {
		$ok = 1;
		$Test->ok($ok, $name);
	} else {
		$Test->ok($ok, $name);
		$Test->diag("$name exceeded threshold $timestring");
	}
	
	return $ok;
}

sub import {
	my($self) = shift;
	my $pack = caller;
	
	$Test->exported_to($pack);
	$Test->plan(@_);
	
	$self->export_to_level(1, $self, 'time_ok');
	
	return;
}

=head2 builder

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

=head1 COPYRIGHT & LICENSE

Copyright 2007 jonasbn, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Test::Timer
