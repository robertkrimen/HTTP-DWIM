package HTTP::DWIM;

use strict;
use warnings;

use Any::Moose;

use LWP::UserAgent;

use HTTP::DWIM::URL;
use HTTP::DWIM::Request;

has base => qw/ is rw /;

has request_agent => qw/ is ro lazy_build 1 /;
sub _build_request_agent {
    return LWP::UserAgent->new
}

sub request {
    my $self = shift;
    my %options = @_;

    my ( $url ) = @options{qw/ url /};
    $url = HTTP::DWIM::URL->resolve( $self->base, $url );
    
    my ( $type ) = @options{qw/ type /};
    $type = 'GET' unless defined $type;
    $type = uc $type;

    my $http_request = HTTP::Request->new( $type => $url );
    my $request = HTTP::DWIM::Request->new( request_agent => $self->request_agent, http_request => $http_request );

    $request->data( $options{ data } ) if exists $options{ data };

    return $request;
}

sub get {
    my $self = shift;
    my $url = shift;

    my $request = $self->request( type => 'GET', url => $url, @_ );
    return $request->run;
}

sub dwim {
    my $class = shift;
    my $base = shift;
    return $class->new( base => $base, @_ );
}

1;
