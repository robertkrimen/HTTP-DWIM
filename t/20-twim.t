#!/usr/bin/env perl

use strict;
use warnings;

use Test::Most;

use Plack::Test;
use Test::HTTP::TWIM;

test_psgi
    app => sub {
        my $env = shift;
        return [ 200, [ 'Content-Type' => 'text/plain' ], [ "Hello, World." ] ],
    },
    client => sub {
        my $twim = Test::HTTP::TWIM->twim( request_agent => $_[0] );
        my ( $response, $value );

        undef $value;
        $response = $twim->get( '/', sub {
            $value = 1;
        } );
        ok( $response );
        ok( $response->is_success );
        is( $value, 1 );

        undef $value;
        $response = $twim->GET( '/', sub {
            $value = 1;
        } )->complete( sub {
            $value += 1;
        } )->run
        ;
        ok( $response );
        ok( $response->is_success );
        is( $value, 2 );
        $response->status_code_is( 200 );
        $twim->status_code_is( 200 );
        $twim->get;
    }
;

done_testing;

