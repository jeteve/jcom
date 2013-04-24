package JCOM::Form::Field;
use Moose -traits => 'JCOM::Form::Meta::Class::Trait::HasShortClass';
use Moose::Util qw/apply_all_roles/;

__PACKAGE__->meta->short_class('GenericField');

=head1 NAME

JCOM::Form::Field - A field for JCOM::Form s

=cut

has 'form' => ( isa => 'JCOM::Form' , is => 'ro' , weak_ref => 1 , required => 1 );

has 'name' => ( isa => 'Str' , is => 'ro' , required => 1 );
has 'help' => ( isa => 'Str', is => 'rw');
has 'placeholder' => ( isa => 'Str', is => 'rw' );

has 'label' => ( isa => 'Str', is => 'rw' , required => 1 , default => '' );
has 'value' => ( is => 'rw' , clearer => 'clear_value' );

has 'errors' => ( isa => 'ArrayRef[Str]' , is => 'rw' , default => sub{ [] } , required => 1 );

=head2 id

Returns a unique id of this field in the space of all forms in the process.

Usage:

  my $id = $this->id();

=cut

sub id{
  my ($self) = @_;
  return $self->form()->meta()->id().'_'.$self->name();
}

=head2 set_placeholder

Chainable placeholder(..);

Placeholder. This is an extra hint, like an example of what to enter
for users. Very useful for HMTL5 interfaces.

=cut

sub set_placeholder{
  my ($self, $placeholder) = @_;
  $self->placeholder($placeholder);
  return $self;
}

=head2 set_help

Chainable help() method.

=cut

sub set_help{
  my ($self, $help) = @_;
  $self->help($help);
  return $self;
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
Additionnaly, you can provide new parameters if the role you're applying
requires some mandatory attributes.

Returns the field so you can chain calls.

Usage:

 $this->add_role('Mandatory')
         ->add_role('+My::App::FieldRole::Whatever');
           ->add_role('RegExpMatch', { regexp_match => qr/^[A-Z]+$/ });

=cut

sub add_role{
  my ($self, $role, $new_args) = @_;
  $new_args //= {};

  if( $role =~ /^\+/ ){
    $role =~ s/^\+//;
  }else{
    $role = 'JCOM::Form::FieldRole::'.$role;
  }

  ## Maintain important meta attributes.
  my $short_class = $self->meta->short_class();

  ##apply_all_roles($self , $role );

  ## This is better, as apply can be used to add new arguments
  ## See http://search.cpan.org/~ether/Moose-2.0801/lib/Moose/Role.pm#APPLYING_ROLES
  Class::MOP::load_class( $role );
  $role->meta->apply($self, rebless_params => $new_args );

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
