#!/usr/bin/env perl

use strict;
use warnings;

use Test::Most;

use HTTP::DWIM::URL;

my ( $base, $url );

is( HTTP::DWIM::URL->resolve( $base, '' ), '/' );
is( HTTP::DWIM::URL->resolve( $base, '/' ), '/' );
is( HTTP::DWIM::URL->resolve( $base, 'http://localhost' ), 'http://localhost/' );
is( HTTP::DWIM::URL->resolve( $base, 'http://localhost?xyzzy=1' ), 'http://localhost?xyzzy=1' );
is( HTTP::DWIM::URL->resolve( $base, 'http://localhost/?xyzzy=1' ), 'http://localhost/?xyzzy=1' );
is( HTTP::DWIM::URL->resolve( $base, 'http://localhost?xyzzy=1#fragment' ), 'http://localhost?xyzzy=1#fragment' );
is( HTTP::DWIM::URL->resolve( $base, 'http://example.com:80?xyzzy=1#fragment' ), 'http://example.com?xyzzy=1#fragment' );
is( HTTP::DWIM::URL->resolve( $base, 'http://example.com:81?xyzzy=1#fragment' ), 'http://example.com:81?xyzzy=1#fragment' );
is( HTTP::DWIM::URL->resolve( $base, 'http://alice:xyzzy@example.com:81?xyzzy=1#fragment' ), 'http://alice:xyzzy@example.com:81?xyzzy=1#fragment' );

$base = 'http://example.org';
is( HTTP::DWIM::URL->resolve( $base, undef ), 'http://example.org/' );
is( HTTP::DWIM::URL->resolve( $base, '' ), 'http://example.org/' );
is( HTTP::DWIM::URL->resolve( $base, '/' ), 'http://example.org/' );
is( HTTP::DWIM::URL->resolve( $base, 'http://localhost' ), 'http://localhost/' );
is( HTTP::DWIM::URL->resolve( $base, 'http://localhost?xyzzy=1' ), 'http://localhost?xyzzy=1' );
is( HTTP::DWIM::URL->resolve( $base, 'http://localhost/?xyzzy=1' ), 'http://localhost/?xyzzy=1' );
is( HTTP::DWIM::URL->resolve( $base, 'http://localhost?xyzzy=1#fragment' ), 'http://localhost?xyzzy=1#fragment' );
is( HTTP::DWIM::URL->resolve( $base, 'http://example.com:80?xyzzy=1#fragment' ), 'http://example.com?xyzzy=1#fragment' );
is( HTTP::DWIM::URL->resolve( $base, 'http://example.com:81?xyzzy=1#fragment' ), 'http://example.com:81?xyzzy=1#fragment' );
is( HTTP::DWIM::URL->resolve( $base, 'http://alice:xyzzy@example.com:81?xyzzy=1#fragment' ), 'http://alice:xyzzy@example.com:81?xyzzy=1#fragment' );
is( HTTP::DWIM::URL->resolve( $base, '/path' ), 'http://example.org/path' );
is( HTTP::DWIM::URL->resolve( $base, '/path?query' ), 'http://example.org/path?query' );
is( HTTP::DWIM::URL->resolve( $base, '/path?query#fragment' ), 'http://example.org/path?query#fragment' );
is( HTTP::DWIM::URL->resolve( $base, '//localhost/path?query#fragment' ), 'http://localhost/path?query#fragment' );

$base = 'http://example.org/0/1/2';
is( HTTP::DWIM::URL->resolve( $base, '/path' ), 'http://example.org/path' );
is( HTTP::DWIM::URL->resolve( $base, '/path?query' ), 'http://example.org/path?query' );
is( HTTP::DWIM::URL->resolve( $base, 'path' ), 'http://example.org/0/1/2/path' );
is( HTTP::DWIM::URL->resolve( $base, 'path?query' ), 'http://example.org/0/1/2/path?query' );

$base = 'http://example.org/0/1/2/';
is( HTTP::DWIM::URL->resolve( $base, '/path' ), 'http://example.org/path' );
is( HTTP::DWIM::URL->resolve( $base, '/path?query' ), 'http://example.org/path?query' );
is( HTTP::DWIM::URL->resolve( $base, 'path' ), 'http://example.org/0/1/2/path' );
is( HTTP::DWIM::URL->resolve( $base, 'path?query' ), 'http://example.org/0/1/2/path?query' );

done_testing;
