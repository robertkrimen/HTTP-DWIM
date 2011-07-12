package HTTP::DWIM::Request;

use strict;
use warnings;

use Any::Moose;

use HTTP::Request;
use JSON::XS; my $JSON = JSON::XS->new;

use HTTP::DWIM::Response;

has response_class => qw/ is rw required 1 /, trigger => \&HTTP::DWIM::load_class_attribute;
has request_agent => qw/ is rw required 1 /;
has http_request => qw/ is rw required 1 isa HTTP::Request /;
has [qw/ _success _error _complete /] => qw/ is rw isa Maybe[CodeRef] /;

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

sub query {
    my $self = shift;
    if ( !@_ ) {
        # TODO What here? HASH? String?
    }
    my $query = shift;

    my $http_request = $self->http_request;
    my $url = $http_request->uri;
    if ( defined $query ) {
        if ( ref $query eq 'HASH' || ref $query eq 'ARRAY' )
                { $url->query_form( ref( $query ) eq 'HASH' ? %$query : @$query ) }
        else    { $url->query( "$query" ) }
    }
    else {
        $url->query( '' );
    }
}

sub content {
    my $self = shift;
    if ( !@_ ) {
        # TODO What here?
    }
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
        $self->query( $data );
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

sub new_response {
    my $self = shift;
    my $class = $self->response_class;
    return $class->new( @_ );
}

sub fulfill_success {
    my $self = shift;
    my $response = shift;
    return unless my $code = $self->success;
    $code->( $response->content, $response );
}

sub fulfill_error {
    my $self = shift;
    my $response = shift;
    return unless my $code = $self->error;
    $code->( $self );
}

sub fulfill_complete {
    my $self = shift;
    my $response = shift;
    return unless my $code = $self->complete;
    $code->( $self );
}

for my $method (qw/ success error complete /) {
    no strict 'refs';
    my $accessor = "_$method";
    *$method = sub {
        my $self = shift;
        return $self->$accessor unless @_;
        $self->$accessor( @_ );
        return $self;
    };
}

sub run {
    my $self = shift;
    # TODO Add fulfill_exception?
    my $request_agent = $self->request_agent;
    my $http_response;
    if ( ref $request_agent eq 'CODE' ) {
        $http_response = $request_agent->( $self->http_request );
    }
    else {
        $http_response = $request_agent->request( $self->http_request );
    }
    my $response = $self->new_response( http_response => $http_response );

    if ( $response->is_success )    { $self->fulfill_success( $response ) }
    else                            { $self->fulfill_error( $response ) }
    $self->fulfill_complete( $response );
    return $response;
}

1;

