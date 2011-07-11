package HTTP::DWIM;

use strict;
use warnings;

use Any::Moose;

use LWP::UserAgent;
use Util::Utl;

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
}

sub get {
    my $self = shift;
    my $request = $self->GET( @_ );
    return $request->run;
}

sub dwim {
    my $class = shift;
    my $base = shift;
    return $class->new( base => $base, @_ );
}

1;
