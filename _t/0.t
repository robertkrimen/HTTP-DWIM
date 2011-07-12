#!/usr/bin/env perl

use strict;
use warnings;

use Test::HTTP;

my $test = Test::HTTP->new;

$test->get( 'http://google.com' );
$test->status_code_is( 404 );

1;
