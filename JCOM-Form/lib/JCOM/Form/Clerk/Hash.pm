package JCOM::Form::Clerk::Hash;
use Moose;
use DateTime::Format::ISO8601;

extends qw/JCOM::Form::Clerk/;

=head1 NAME

JCOM::Form::Clerk::Hash - A Clerk that will fill a form from a hash of values.

=cut

has '+source' => ( isa => 'HashRef' );

sub _get_source_value{
  my ($self, $field) = @_;
  return $self->source->{$field->name()}
}
__PACKAGE__->meta->make_immutable();
1;
