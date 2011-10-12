package HTTP::DWIM::Response;

use strict;
use warnings;

use Any::Moose;

use HTTP::Response;
use JSON::XS; my $JSON = JSON::XS->new;

has http_response => qw/ is rw required 1 isa HTTP::Response /, handles => [qw/
    code
    header
    status_line
    as_string
    is_success
    is_redirect
    is_error
/];

sub is_failure {
    my $self = shift;
    return $self->is_error( @_ );
}

sub content {
    my $self = shift;
    return $self->http_response->decoded_content;
}

*decoded_content = \&content;

sub undecoded_content {
    my $self = shift;
    return $self->http_response->content;
}

1;
