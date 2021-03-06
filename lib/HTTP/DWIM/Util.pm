package HTTP::DWIM::Util;

use strict;
use warnings;

use URI;
use URI::Split qw/ uri_split uri_join /;
use Scalar::Util qw/ blessed /;
use File::Spec::Unix;

sub resolve {
    my $self = shift;
    my $base = shift;
    my $url = shift;

    $base = '' unless defined $base;
    $url = '' unless defined $url;

    if ( blessed $url && $url->isa( 'URI' ) ) {
        return $url->canonical;
    }

    my ( $scheme, $identity, $path, $query, $fragment ) = uri_split( $url );
    if ( $scheme ) {
        return URI->new( $url )->canonical;
    }

    my %base;
    #$base = "http://$base" if defined $base && $base =~ m/:/ && $base !~ m{^[\w\-]+://};
    $base = "http://$base" if $base =~ m/^(?:[\w\-\.]+)(?::\d+|$)/;
    @base{qw/ scheme identity path query fragment /} = uri_split( $base );

    my %url;
    $url{ scheme } = $base{ scheme };
    $url{ identity } = defined $identity ? $identity : $base{ identity };
    if ( $path !~ m{^/} ) {
        if ( '/' eq substr $base{ path }, -1 ) {
            $path = join '', $base{ path }, $path;
        }
        elsif ( length $path ) {
            $path = join '/', $base{ path }, $path;
        }
        else {
            $path = $base{ path };
        }
    }
    $url{ path } = $path;
    $url{ query } = $query;
    $url{ fragment } = $fragment;

    return URI->new( uri_join( @url{qw/ scheme identity path query fragment /} ) )->canonical;
}

1;
