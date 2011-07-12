package Test::HTTP::TWIM::Request;

use strict;
use warnings;

use Any::Moose;

extends qw/ HTTP::DWIM::Request /;

has twim => qw/ is ro required 1 /;

1;
