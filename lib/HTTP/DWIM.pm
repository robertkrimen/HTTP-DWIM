package HTTP::DWIM;
# ABSTRACT: Simple HTTP request & response management

=pod


    my $dwim = HTTP::DWIM->new( base => 'example.com' );
    my ( $request );

    $request = $dwim->GET( '/', { a => 1, b => 2 } );
    # http://example.com/?a=1&b=2

    $response = $dwim->get( '/', { a => 1, b => 2 }, sub {
        my ( $data, $status, $response ) = @_;
        # This executes first
    } )->complete( sub {
        # Then this
    } );

=cut

use strict;
use warnings;

use Any::Moose;

use LWP::UserAgent;
use Util::Utl;
use Class::Load qw/ load_class /;

use HTTP::DWIM::Util;
use HTTP::DWIM::Request;

has base => qw/ is rw /;

has request_agent => qw/ is ro lazy_build 1 /;
sub _build_request_agent {
    return LWP::UserAgent->new
}

has request_class => qw/ is rw lazy_build 1 /, trigger => \&load_class_attribute;
sub _build_request_class { 'HTTP::DWIM::Request' }

has response_class => qw/ is rw lazy_build 1 /, trigger => \&load_class_attribute;
sub _build_response_class { 'HTTP::DWIM::Response' }

sub load_class_attribute {
    my $self = shift;
    my $value = shift;
    load_class $value;
}

has _twim_new_request_arguments => qw/ is rw isa Maybe[CodeRef] /;

sub new_request {
    my $self = shift;
    my $class = $self->request_class;
    local @_ = @_;
    unshift @_, response_class => $self->response_class;
    if ( my $arguments = $self->_twim_new_request_arguments ) {
        @_ = $arguments->( @_ );
    }
    return $class->new( @_ );
}

sub request {
    my $self = shift;
    my %options = @_;

    my ( $url ) = @options{qw/ url /};
    $url = HTTP::DWIM::Util->resolve( $self->base, $url );
    
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

    for (qw/ success error complete /) {
        if ( $options{ $_ } ) {
            $request->$_( $options{ $_ } );
        }
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
    my $base;
    $base = shift if @_ % 2; # Odd number of arguments
    return $class->new( base => $base, @_ );
}

1;
