package JCOM::Form::Field::String;
use Moose;

extends qw/JCOM::Form::Field/;

=head1 NAME

JCOM::Form::Field::String - A Pure and single string field.

=cut

has '+value' => ( isa => 'Str' );

__PACKAGE__->meta->short_class('String');
__PACKAGE__->meta->make_immutable();
1;
