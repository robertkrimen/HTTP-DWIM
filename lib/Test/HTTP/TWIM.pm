package Test::HTTP::TWIM;

use strict;
use warnings;

use Any::Moose;

use HTTP::DWIM;

has dwim => qw/ is rw required 1 /, trigger => sub {
    my $self = shift;
    my $dwim = shift;
    $dwim->request_class( 'Test::HTTP::TWIM::Request' );
    $dwim->response_class( 'Test::HTTP::TWIM::Response' );
    $dwim->_twim_new_request_arguments( sub {
        return ( @_, twim => $self );
    } );
}, handles => [qw/
    OPTIONS HEAD GET DELETE
    POST PUT
    options head get delete
    post put
/];

has response => qw/ is rw clearer clear_response /, handles =>[qw/
    status_code_is
/];

sub ran {
    my $self = shift;
    my $response = shift;
    $self->response( $response );
}

sub twim {
    my $class = shift;
    my $dwim = HTTP::DWIM->dwim( @_ );
    my $twim = $class->new( dwim => $dwim );
}

1;
