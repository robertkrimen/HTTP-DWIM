package HTTP::DWIM::Response;

use strict;
use warnings;

use Any::Moose;

use HTTP::Response;
use JSON::XS; my $JSON = JSON::XS->new;

has http_response => qw/ is rw required 1 isa HTTP::Response /;

sub content {
    my $self = shift;
    return $self->http_response->decoded_content;
}

sub undecoded_content {
    my $self = shift;
    return $self->http_response->content;
}

1;
