package Test::Timer::TimeoutException;

# $Id: TimeoutException.pm,v 1.1 2007-03-04 21:54:12 jonasbn Exp $

use strict;
use warnings;
use vars qw($VERSION);

use base 'Error';
use overload ('""' => 'stringify');

$VERSION = '0.01';

sub new
{
    my $self = shift;
    my $text = "" . shift;
    my @args = ();

    local $Error::Depth = $Error::Depth + 1;

    $self = $self->SUPER::new(-text => $text, @args);
    
    return $self;
}

1;