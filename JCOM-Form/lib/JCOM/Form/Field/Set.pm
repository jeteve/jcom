package JCOM::Form::Field::Set;
use Moose;

extends qw/JCOM::Form::Field/;

=head1 NAME

JCOM::Form::Field::Set - A Set of Value's (Not references).

=head1 NOTES

The 'value' field of this is in fact a set of values.

=cut

has '+value' => ( isa => 'ArrayRef[Value]' );

__PACKAGE__->meta->short_class('Set');
__PACKAGE__->meta->make_immutable();
1;
