package JCOM::Form::Field;
use Moose -traits => 'JCOM::Form::Meta::Class::Trait::HasShortClass';

__PACKAGE__->meta->short_class('GenericField');

=head1 NAME

JCOM::Form::Field - A field for JCOM::Form s

=cut

has 'form' => ( isa => 'JCOM::Form' , is => 'ro' , weak_ref => 1 , required => 1 );
has 'name' => ( isa => 'Str' , is => 'ro' , required => 1 );
has 'errors' => ( isa => 'ArrayRef[Str]' , is => 'rw' , default => sub{ [] } , required => 1 );
has 'value' => ( is => 'rw' , clearer => 'clear_value' );

sub add_error{
  my ($self , $err_str) = @_;
  push @{$self->errors()} , $err_str;
}

sub has_errors{
  my ($self) = @_;
  return scalar(@{$self->errors()});
}

=head2 validate

Does nothing. Can be extended by roles.

=cut

sub validate{}

sub clear{
  my ($self) = @_;
  $self->errors([]);
  $self->clear_value();
}

#__PACKAGE__->meta->make_immutable();
1;
