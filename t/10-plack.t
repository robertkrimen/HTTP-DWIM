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
        my $dwim = HTTP::DWIM->new( request_agent => $_[0] );
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
    }
;

done_testing;
