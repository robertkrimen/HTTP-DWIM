package Test::HTTP::TWIM::Response;

use strict;
use warnings;

use Test::Builder;
our $Builder = Test::Builder->new;

use Any::Moose;

extends qw/ HTTP::DWIM::Response /;

sub status_code_is {
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my ( $self, $expected_code, $description ) = @_;

    #defined( $expected_code ) && defined or $_ = $self->name . " status is $expected_code." for $description;
    defined( $expected_code ) && defined or $_ = "status is $expected_code." for $description;

    $Builder->is_eq( $self->http_response->code, $expected_code, $description );
}

sub content_like {
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my ( $self, $expected_content, $description ) = @_;

    defined( $expected_content ) && defined or $_ = "content mismatch" for $description;

    $Builder->like( $self->http_response->content, $expected_content, $description );
}

*body_like = \&content_like;

1;
