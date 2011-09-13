#!/usr/bin/env perl

use strict;
use warnings;

use Test::Most;

use HTTP::DWIM;

my ( $base, $dwim, $request );

$dwim = HTTP::DWIM->new( base => 'localhost:8090' );

ok( $dwim );

$request = $dwim->GET( '/' );
ok( $request );
is( $request->method, 'GET' );
is( $request->url, 'http://localhost:8090/' );

$request = $dwim->GET( '/', { a => 1, b => 2 } );
ok( $request );
is( $request->url, 'http://localhost:8090/?a=1&b=2' );

$request = $dwim->GET( '/', { a => '=&', b => 2 } );
ok( $request );
is( $request->url, 'http://localhost:8090/?a=%3D%26&b=2' );

$request = $dwim->POST( '/', { a => '=&', b => 2 } );
ok( $request );
is( $request->method, 'POST' );
is( $request->url, 'http://localhost:8090/' );
is( $request->content, 'a=%3D%26&b=2' );
is( $request->content_type, 'application/x-www-form-urlencoded' );

done_testing;
