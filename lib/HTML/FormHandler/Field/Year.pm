package HTML::FormHandler::Field::Year;
# ABSTRACT: year selection list
our $VERSION = '100.000001';
use Moose;
extends 'HTML::FormHandler::Field::IntRange';

has '+range_start' => (
    default => sub {
        my $year = (localtime)[5] + 1900 - 5;
        return $year;
    }
);
has '+range_end' => (
    default => sub {
        my $year = (localtime)[5] + 1900 + 10;
        return $year;
    }
);

=head1 DESCRIPTION

Provides a list of years starting five years back and extending 10 years into
the future.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
