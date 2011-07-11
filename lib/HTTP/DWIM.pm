package HTTP::DWIM;

use strict;
use warnings;

use Any::Moose;

use LWP::UserAgent;
use Util::Utl;
use Class::Load qw/ load_class /;

use HTTP::DWIM::URL;
use HTTP::DWIM::Request;

has base => qw/ is rw /;

has request_agent => qw/ is ro lazy_build 1 /;
sub _build_request_agent {
    return LWP::UserAgent->new
}

has request_class => qw/ is ro lazy_build 1 /, trigger => \&load_class_attribute;
sub _build_request_class { 'HTTP::DWIM::Request' }

has response_class => qw/ is ro lazy_build 1 /, trigger => \&load_class_attribute;
sub _build_response_class { 'HTTP::DWIM::Response' }

sub load_class_attribute {
    my $self = shift;
    my $value = shift;
    load_class $value;
}

sub new_request {
    my $self = shift;
    my $class = $self->request_class;
    return $class->new( response_class => $self->response_class, @_ );
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
    my $request = $self->new_request( request_agent => $self->request_agent, http_request => $http_request );

    if ( $type eq 'GET' ) {
        my $query = utl->first( \%options, qw/ query content data /, { exclusive => 1 } );
        $request->query( $query );
    }
    else {
        my $query = $options{ query };
        $request->query( $query );
        my $content = utl->first( \%options, qw/ content data /, { exclusive => 1 } );
        $request->content( $content );
    }

    return $request;
}

for my $type (qw/ OPTIONS HEAD GET DELETE /) {
    no strict 'refs';
    *$type = sub {
        my $self = shift;
        my ( $url, $query, $success, $options );
        $url = shift if ! ref $_[0];
        $query = shift unless ref $_[0] eq 'CODE';
        $success = shift if ref $_[0] eq 'CODE';
        $options = ref $_[0] eq 'HASH' ? shift : { @_ };
        return $self->request( type => $type, url => $url, query => $query, success => $success, %$options );
    };
    my $method = lc $type;
    *$method = sub {
        my $self = shift;
        my $request = $self->$type( @_ );
        return $request->run;
    };
}

for my $type (qw/ POST PUT /) {
    no strict 'refs';
    *$type = sub {
        my $self = shift;
        my ( $url, $content, $success, $options );
        $url = shift if ! ref $_[0];
        $content = shift unless ref $_[0] eq 'CODE';
        $success = shift if ref $_[0] eq 'CODE';
        $options = ref $_[0] eq 'HASH' ? shift : { @_ };
        return $self->request( type => $type, url => $url, content => $content, success => $success, %$options );
    };
    my $method = lc $type;
    *$method = sub {
        my $self = shift;
        my $request = $self->$type( @_ );
        return $request->run;
    };
}

sub dwim {
    my $class = shift;
    my $base = shift;
    return $class->new( base => $base, @_ );
}

1;
