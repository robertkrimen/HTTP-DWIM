#!/usr/bin/env perl

use strict;
use warnings;

use Test::Most;

use Plack::Test;
use HTTP::DWIM;

test_psgi
    app => sub {
        my $env = shift;
        return [ 200, [ 'Content-Type' => 'text/plain' ], [ "Hello, World." ] ],
    },
    client => sub {
        my $dwim = HTTP::DWIM->dwim( base => 'localhost', request_agent => $_[0] );
        my ( $response, $value );

        undef $value;
        $response = $dwim->get( '/', sub {
            $value = 1;
        } );
        ok( $response );
        ok( $response->is_success );
        is( $value, 1 );

        undef $value;
        $response = $dwim->GET( '/', sub {
            $value = 1;
        } )->complete( sub {
            $value += 1;
        } )->run
        ;
        ok( $response );
        ok( $response->is_success );
        is( $value, 2 );

        $response = $dwim->post( '/', <<_END_ );
Hello, World.
_END_
        ok( $response );
        ok( $response->is_success );
    }
;

test_psgi
    app => sub {
        my $env = shift;
        return [ 200, [ 'Content-Type' => 'application/json' ], [ "{ \"a\": 1 }" ] ],
    },
    client => sub {
        my $dwim = HTTP::DWIM->dwim( base => 'localhost', request_agent => $_[0] );
        $dwim->get( sub {
            my $data = shift;
            cmp_deeply( $data, { a => 1 } );
        } );
    }
;

done_testing;
