package HTML::FormHandler::Field::Compound;
# ABSTRACT: field consisting of subfields
our $VERSION = '100.000001';
use Moose;
extends 'HTML::FormHandler::Field';
with 'HTML::FormHandler::Fields';
with 'HTML::FormHandler::BuildFields';
with 'HTML::FormHandler::InitResult';

=head1 SYNOPSIS

This field class is designed as the base (parent) class for fields with
multiple subfields. Examples are L<HTML::FormHandler::Field::DateTime>
and L<HTML::FormHandler::Field::Duration>.

A compound parent class requires the use of sub-fields prepended
with the parent class name plus a dot

   has_field 'birthdate' => ( type => 'DateTime' );
   has_field 'birthdate.year' => ( type => 'Year' );
   has_field 'birthdate.month' => ( type => 'Month' );
   has_field 'birthdate.day' => ( type => 'MonthDay');

If all validation is performed in the parent class so that no
validation is necessary in the child classes, then the field class
'Nested' may be used.

The array of subfields is available in the 'fields' array in
the compound field:

   $form->field('birthdate')->fields

Error messages will be available in the field on which the error
occurred. You can access 'error_fields' on the form or on Compound
fields (and subclasses, like Repeatable).

The process method of this field runs the process methods on the child fields
and then builds a hash of these fields values.  This hash is available for
further processing by L<HTML::FormHandler::Field/actions> and the validate method.

=head2 widget

Widget type is 'compound'

=head2 build_update_subfields

You can set 'defaults' or other settings in a 'build_update_subfields' method,
which contains attribute settings that will be merged with field definitions
when the fields are built. Use the 'by_flag' key with 'repeatable', 'compound',
and 'contains' subkeys, or use the 'all' key for settings which apply to all
subfields in the compound field.

=cut

has '+widget'     => ( default => 'Compound' );
has 'is_compound' => ( is      => 'ro', isa     => 'Bool', default => 1 );
has 'item'        => ( is      => 'rw', clearer => 'clear_item' );
has '+do_wrapper' => ( default => 0 );
has '+do_label'   => ( default => 0 );
has 'primary_key' => (
    is        => 'rw',
    isa       => 'ArrayRef',
    predicate => 'has_primary_key',
);

has '+field_name_space' => (
    default => sub {
        my $self = shift;
        return $self->form->field_name_space
            if $self->form && $self->form->field_name_space;
        return [];
    },
);

sub BUILD {
    my $self = shift;
    $self->_build_fields;
}

# this is for testing compound fields outside
# of a form
sub test_validate_field {
    my $self = shift;
    unless ( $self->form ) {
        if ( $self->has_input ) {
            $self->_result_from_input( $self->result, $self->input );
        }
        else {
            $self->_result_from_fields( $self->result );
        }
    }
    $self->validate_field;
    unless ( $self->form ) {
        foreach my $err_res ( @{ $self->result->error_results } ) {
            $self->result->_push_errors( $err_res->all_errors );
        }
    }
}

around '_result_from_object' => sub {
    my $orig = shift;
    my $self = shift;
    my ( $self_result, $item ) = @_;
    $self->item($item) if $item;
    $self->$orig(@_);
};

after 'clear_data' => sub {
    my $self = shift;
    $self->clear_item;
};

around '_result_from_input' => sub {
    my $orig = shift;
    my $self = shift;
    my ( $self_result, $input, $exists ) = @_;
    if ( !$input && !$exists ) {
        return $self->_result_from_fields($self_result);
    }
    else {
        return $self->$orig(@_);
    }
};

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
