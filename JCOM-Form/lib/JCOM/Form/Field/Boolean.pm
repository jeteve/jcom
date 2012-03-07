package JCOM::Form::Field::Boolean;
use Moose;

extends qw/JCOM::Form::Field/;

=head1 NAME

JCOM::Form::Field::String - A Pure and single boolean field. Could render as a checkbox.

=head1 NOTES

The state of this is either a true value or nothing. Meaning undef. This is
to stay consistent with the Role Mandatory.

=cut

has '+value' => ( isa => 'Bool' );

__PACKAGE__->meta->short_class('Boolean');
__PACKAGE__->meta->make_immutable();
1;