package HTML::FormHandler::Model::Object;
# ABSTRACT: stub for Object model
our $VERSION = '100.000001';
use Moose::Role;

sub update_model {
    my $self = shift;

    my $item = $self->item;
    return unless $item;
    foreach my $field ( $self->all_fields ) {
        my $name = $field->name;
        next unless $item->can($name);
        $item->$name( $field->value );
    }
}

use namespace::autoclean;
1;
