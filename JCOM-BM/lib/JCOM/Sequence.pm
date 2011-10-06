package JCOM::Sequence;
use Moose;

=head1 NAME

JCOM::Sequence - A straight forward simple sequence.

=cut

has 'value' => ( is => 'rw' , isa => 'Int' , default => 0 );

=head2 next

Returns the next number in this sequence.

Usage:

  my $n = $this->next();

=cut

sub next{
  my ($self) = @_;
  return $self->value($self->value() + 1);
}

__PACKAGE__->meta->make_immutable();

1;
