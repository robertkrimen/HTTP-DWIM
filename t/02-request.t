#!/usr/bin/env perl

use strict;
use warnings;

use Test::Most;

use HTTP::DWIM;

my ( $base, $dwim );

$dwim = HTTP::DWIM->new;

ok( $dwim );

done_testing;
