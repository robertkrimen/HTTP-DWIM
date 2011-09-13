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
is( $request->url, 'localhost/' );

done_testing;
