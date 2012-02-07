package JCOM::BM::Factory;
use Moose;

=head1 NAME

JCOM::BM::Factory - A Factory class to inherit from

=cut

=head2 create

Should create a new object given the parameters.

=cut

sub create{
  my ($self) = @_;
  confess("Please implement that");
}

=head2 search

Should return an iterable set of objects given the parameters.

=cut

sub search{
  my ($self) = @_;
  confess("Please implement that");
}

=head2 find

Just return one or zero object given the parameters.

=cut

sub find{
  my ($self) = @_;
  confess("Please implement that");
}

__PACKAGE__->meta->make_immutable();
1;
