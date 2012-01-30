package JCOM::Form::Field::Date;
use Moose;
use DateTime;

extends qw/JCOM::Form::Field/;

=head1 NAME

JCOM::Form::Field::Date - A single DateTime field.

=cut

has '+value' => ( isa => 'DateTime' );

__PACKAGE__->meta->short_class('Date');
__PACKAGE__->meta->make_immutable();
1;
