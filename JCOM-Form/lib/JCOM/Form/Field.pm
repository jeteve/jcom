package JCOM::Form::Field;
use Moose -traits => 'JCOM::Form::Meta::Class::Trait::HasShortClass';
use Moose::Util qw/apply_all_roles/;

__PACKAGE__->meta->short_class('GenericField');

=head1 NAME

JCOM::Form::Field - A field for JCOM::Form s

=cut

has 'form' => ( isa => 'JCOM::Form' , is => 'ro' , weak_ref => 1 , required => 1 );
has 'label' => ( isa => 'Str', is => 'rw' , required => 1 , default => '' );
has 'name' => ( isa => 'Str' , is => 'ro' , required => 1 );
has 'errors' => ( isa => 'ArrayRef[Str]' , is => 'rw' , default => sub{ [] } , required => 1 );
has 'value' => ( is => 'rw' , clearer => 'clear_value' );

=head2 set_label

Chainable label method.

=cut

sub set_label{
  my ($self , $label) = @_;
  $self->label($label);
  return $self;
}

=head2 add_error

Adds an error string to this field.

=cut

sub add_error{
  my ($self , $err_str) = @_;
  push @{$self->errors()} , $err_str;
}

=head2 has_errors

Returns the number of errors in this form.

=cut

sub has_errors{
  my ($self) = @_;
  return scalar(@{$self->errors()});
}

=head2 validate

Does nothing. Can be extended by roles.

=cut

sub validate{}

=head2 clear

Resets this field value and errors

=cut

sub clear{
  my ($self) = @_;
  $self->errors([]);
  $self->clear_value();
}

=head2 add_role

Adds a Subrole of L<JCOM::Form::FieldRole> or a custom defined FormRole.

=cut

sub add_role{
  my ($self , $role) = @_;

  if( $role =~ /^\+/ ){
    $role =~ s/^\+//;
  }else{
    $role = 'JCOM::Form::FieldRole::'.$role;
  }

  ## Maintain important meta attributes.
  my $short_class = $self->meta->short_class();
  apply_all_roles($self , $role );

  ## Maintain important meta attributes.
  $self->meta->short_class($short_class);
  return $self;
}

#__PACKAGE__->meta->make_immutable();
1;
