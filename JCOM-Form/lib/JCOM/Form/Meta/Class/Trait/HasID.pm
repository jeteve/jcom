package JCOM::Form::Meta::Class::Trait::HasID;
use Moose::Role;
use JCOM::Sequence;

=head2 NAME

JCOM::Form::Meta::Class::Trait::HasID - Gives a meta->id and a meta->id_prefix attribute to this trait consumer.

=cut

{
  my $FORMSEQ = JCOM::Sequence->new();
  sub _next_default_id{
    my ($self) = @_;
    return ( $self->id_prefix() // $self ).$FORMSEQ->next();
  }
}

has 'id' => ( isa => 'Str' , is => 'rw', lazy => 1 , default => sub{ $_[0]->_next_default_id() } );
has 'id_prefix' => ( isa => 'Str' , is => 'rw' );

1;
