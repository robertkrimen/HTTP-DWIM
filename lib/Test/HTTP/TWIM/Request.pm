package Test::HTTP::TWIM::Request;

use strict;
use warnings;

use Test::Builder;
our $Builder = Test::Builder->new;

use Any::Moose;

extends qw/ HTTP::DWIM::Request /;

has twim => qw/ is ro required 1 /;

has test_fail => qw/ is rw default 0 /;

around run => sub {
    my $inner = shift;
    my $self = shift;
    $self->twim->clear_response;
    my $response = $self->$inner( @_ );
    $self->ran( $response );
    return $response;
};

sub ran {
    my $self = shift;
    my $response = shift;
    my $fail = $self->test_fail;
    if ( defined $fail ) {
        my $level = 0;
        while ( my $package = caller $level ) {
            # Find the right level so we can report errors correctly
            last if $package eq 'main';
            last if $package !~ m/^(?:Moo|Mouse|Moose|HTTP::DWIM|Test::HTTP::[TD]WIM)(?::|$)/;
            $level += 1;
        }
        local $Test::Builder::Level = $Test::Builder::Level + $level;
        $Builder->ok( $fail ? !$response->is_success : $response->is_success ) if defined $fail;
    }
    $self->twim->ran( $response );
}

1;
