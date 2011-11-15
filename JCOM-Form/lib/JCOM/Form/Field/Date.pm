package JCOM::Form::Field::Date;
use Moose;
use DateTime;

extends qw/JCOM::Form::Field/;

=head1 NAME

JCOM::Form::Field::Date - A single DateTime field.

=cut

has 'value' => ( is => 'DateTime' , is => 'rw' );

__PACKAGE__->meta->make_immutable();
1;
