#!/usr/bin/env perl

use strict;
use warnings;

use Test::Most;

use HTTP::DWIM;

my ( $dwim, $response );

$dwim = HTTP::DWIM->dwim( 'http://google.com' );

$response = $dwim->get( '' );
ok( $response->http_response->is_success );
unlike( $response->content, qr/xyzzy/ );

$response = $dwim->get( { q => 'xyzzy' } );
ok( $response->http_response->is_success );
like( $response->content, qr/xyzzy/ );

$response = $dwim->get( '' => { q => 'xyzzy' } );
ok( $response->http_response->is_success );
like( $response->content, qr/xyzzy/ );

done_testing;

1;
