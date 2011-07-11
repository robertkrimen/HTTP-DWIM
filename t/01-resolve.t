#!/usr/bin/env perl

use strict;
use warnings;

use Test::Most;

use HTTP::DWIM::Util;
sub resolve {
    return HTTP::DWIM::Util->resolve( @_ );
}

my ( $base, $url );

is( resolve( $base, '' ), '/' );
is( resolve( $base, '/' ), '/' );
is( resolve( $base, 'http://localhost' ), 'http://localhost/' );
is( resolve( $base, 'http://localhost?xyzzy=1' ), 'http://localhost?xyzzy=1' );
is( resolve( $base, 'http://localhost/?xyzzy=1' ), 'http://localhost/?xyzzy=1' );
is( resolve( $base, 'http://localhost?xyzzy=1#fragment' ), 'http://localhost?xyzzy=1#fragment' );
is( resolve( $base, 'http://example.com:80?xyzzy=1#fragment' ), 'http://example.com?xyzzy=1#fragment' );
is( resolve( $base, 'http://example.com:81?xyzzy=1#fragment' ), 'http://example.com:81?xyzzy=1#fragment' );
is( resolve( $base, 'http://alice:xyzzy@example.com:81?xyzzy=1#fragment' ), 'http://alice:xyzzy@example.com:81?xyzzy=1#fragment' );

$base = 'http://example.org';
is( resolve( $base, undef ), 'http://example.org/' );
is( resolve( $base, '' ), 'http://example.org/' );
is( resolve( $base, '/' ), 'http://example.org/' );
is( resolve( $base, 'http://localhost' ), 'http://localhost/' );
is( resolve( $base, 'http://localhost?xyzzy=1' ), 'http://localhost?xyzzy=1' );
is( resolve( $base, 'http://localhost/?xyzzy=1' ), 'http://localhost/?xyzzy=1' );
is( resolve( $base, 'http://localhost?xyzzy=1#fragment' ), 'http://localhost?xyzzy=1#fragment' );
is( resolve( $base, 'http://example.com:80?xyzzy=1#fragment' ), 'http://example.com?xyzzy=1#fragment' );
is( resolve( $base, 'http://example.com:81?xyzzy=1#fragment' ), 'http://example.com:81?xyzzy=1#fragment' );
is( resolve( $base, 'http://alice:xyzzy@example.com:81?xyzzy=1#fragment' ), 'http://alice:xyzzy@example.com:81?xyzzy=1#fragment' );
is( resolve( $base, '/path' ), 'http://example.org/path' );
is( resolve( $base, '/path?query' ), 'http://example.org/path?query' );
is( resolve( $base, '/path?query#fragment' ), 'http://example.org/path?query#fragment' );
is( resolve( $base, '//localhost/path?query#fragment' ), 'http://localhost/path?query#fragment' );

$base = 'http://example.org/0/1/2';
is( resolve( $base, '/path' ), 'http://example.org/path' );
is( resolve( $base, '/path?query' ), 'http://example.org/path?query' );
is( resolve( $base, 'path' ), 'http://example.org/0/1/2/path' );
is( resolve( $base, 'path?query' ), 'http://example.org/0/1/2/path?query' );

$base = 'http://example.org/0/1/2/';
is( resolve( $base, '/path' ), 'http://example.org/path' );
is( resolve( $base, '/path?query' ), 'http://example.org/path?query' );
is( resolve( $base, 'path' ), 'http://example.org/0/1/2/path' );
is( resolve( $base, 'path?query' ), 'http://example.org/0/1/2/path?query' );

done_testing;
