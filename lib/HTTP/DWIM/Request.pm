package HTTP::DWIM::Request;

use strict;
use warnings;

use Any::Moose;

use HTTP::Request;
use JSON::XS; my $JSON = JSON::XS->new;

has request_agent => qw/ is rw required 1 /;
has http_request => qw/ is rw required 1 isa HTTP::Request /;

sub type {
    return shift->method( @_ );
}

sub method {
    my $self = shift;
    if ( @_ ) {
        my $method = shift;
        defined or $_ = 'GET' for $method; 
        $self->http_request->method( uc $method );
        return $self;
    }
    return $self->http_request->method;
}

sub header {
    my $self = shift;
    my $name = shift;
    if ( @_ ) {
        $self->http_request->header( $name => shift );
        return $self;
    }
    return $self->http_request->header( $name );
}

sub data {
    my $self = shift;
    my ( $data_type, $data );
    if ( 2 == @_ ) {
        $data_type = shift;
        $data_type = '' unless defined $data_type;
        $data = shift;
    }
    else {
        $data = shift;
    }

    my $http_request = $self->http_request;

    my $type = uc $self->method;
    if ( $type eq 'GET' ) {
        my $url = $http_request->uri;
        if ( defined $data ) {
            if ( ref $data eq 'HASH' || ref $data eq 'ARRAY' )
                    { $url->query_form( ref( $data ) eq 'HASH' ? %$data : @$data ) }
            else    { $url->query( "$data" ) }
        }
        else {
            $url->query( '' );
        }
    }
    else {
        my ( $content, $content_type );
        $content_type = $http_request->header( 'Content-Type' );
        $data_type = $content_type unless length $data_type;
        $data_type = 'form' unless length $data_type;

        if ( $data_type eq 'form' || $data_type eq 'application/x-www-form-urlencoded' ) {
            $content_type = 'application/x-www-form-urlencoded';
            # As in HTTP::Request::Common, we use a
            # temporary URI object to format the content
            require URI;
            my $url = URI->new( 'http:' );
            $url->query_form( ref( $data ) eq 'HASH' ? %$data : @$data );
            $content = $url->query;
        }
        elsif ( $data_type eq 'json' ) {
            $content_type = 'application/json';
            $content = $JSON->encode( $data );
        }
        else {
            $content_type = $data_type;
            $content = $data;
        }

        $http_request->header( 'Content-Type' => $content_type );
        if ( defined $content ) {
            $http_request->header( 'Content-Length' => length $content ) unless ref $content;
            $http_request->content( $content );
        }
        else {
            $http_request->header( 'Content-Length' => 0 );
        }
    }

    return $self;
}

1;

