package JCOM::BM::DBICObject;
use Moose;
has 'bm' => ( does => 'JCOM::BM::DBICWrapper' , required => 1 , is => 'ro' );

=head1 NAME

JCOM::BM::DBICObject - Base class for object containing business code around another DBIC object.

=head1 PROPERTIES

=over

=item bm

The business model. Mandatory.

=back

=head1 EXAMPLE

  package My::BM::O::User;
  use Moose;
  extends qw/JCOM::BM::DBICObject/;

  has 'dbuser' => ( isa => 'My::Schema::Result::User' , is => 'ro' , required => 1 , handles => qw/.*/ );

  sub check_password{
      my ($self , $password) = @_;
      return $self->password() eq $password; # Do NOT do that :)
  }
  1;

=cut

__PACKAGE__->meta->make_immutable();
1;
