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

=head2 id

Returns a unique id of this field in the space of all forms in the process.

Usage:

  my $id = $this->id();

=cut

sub id{
  my ($self) = @_;
  return $self->form()->meta()->id().'_'.$self->name();
}

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

=head2 roles_names

Returns an array of Roles this field implements.

=cut

sub roles_names{
  my ($self) = @_;
  return  map{ $_->name() } $self->meta->calculate_all_roles_with_inheritance();
}

=head2 does_role

Returns true if this field does the given role.

Usage:

  if( $this->does_role('Mandatory') ){
    ...
  }


  if( $this->does_role('+My::Specific::Role') ){
    ...
  }

=cut

sub does_role{
  my ($self , $role) = @_;
  if( $role =~ /^\+/ ){
    $role =~ s/^\+//;
  }else{
    $role = 'JCOM::Form::FieldRole::'.$role;
  }
  return $self->does($role);
}

=head2 short_class

Accessor shortcut for meta short class.

Usage:

 $this->short_class();

=cut

sub short_class{
  my ($self) = @_;
  return $self->meta->short_class();
}

#__PACKAGE__->meta->make_immutable();
1;
