package JCOM::Form::Field::Integer;
use Moose;

extends qw/JCOM::Form::Field/;

=head1 NAME

JCOM::Form::Field::String - A Pure and single string field.

=cut

has '+value' => ( isa => 'Int' );

__PACKAGE__->meta->short_class('Integer');

__PACKAGE__->meta->make_immutable();
1;
