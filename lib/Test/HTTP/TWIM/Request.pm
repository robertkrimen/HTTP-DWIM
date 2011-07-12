package Test::HTTP::TWIM::Request;

use strict;
use warnings;

use Any::Moose;

extends qw/ HTTP::DWIM::Request /;

has twim => qw/ is ro required 1 /;

around run => sub {
    my $inner = shift;
    my $self = shift;
    $self->twim->clear_response;
    my $response = $self->$inner( @_ );
    $self->ran( $response );
    return $response;
};

sub ran {
    my $self = shift;
    my $response = shift;
    $self->twim->ran( $response );
}

1;
