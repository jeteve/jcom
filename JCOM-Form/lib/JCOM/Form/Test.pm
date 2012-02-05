package JCOM::Form::Test;
use Moose;
use Class::MOP;
use Module::Pluggable::Object;

=head1 NAME

JCOM::Form::Test - A Test form containing all the supported native field types.

=cut

extends qw/JCOM::Form/;

=head2 build_fields

See super class L<JCOM::Form>

=cut

sub build_fields{
  my ($self) = @_;

  my @res = ();
  my $mp = Module::Pluggable::Object->new( search_path => 'JCOM::Form::Field' );
  foreach my $field_class ( $mp->plugins() ){
    Class::MOP::load_class($field_class);
    $self->add_field('+'.$field_class , 'field_'.$field_class->meta->short_class() );
  }

  ## Add a mandatory field.
  my $field = JCOM::Form::Field::String->new({ name => 'mandatory_str' , form => $self });
  $self->add_field($field);
  $field->add_role('Mandatory');

  $field = JCOM::Form::Field::String->new({ name => 'mandatory_and_long' , form => $self });
  $self->add_field($field);
  $field->add_role('+JCOM::Form::FieldRole::Mandatory')->add_role('MinLength')->min_length(3);


  my $email = $self->add_field('String' , 'email');
  $email->add_role('Email');
  #$field->meta->short_class('String');
}

__PACKAGE__->meta->make_immutable();

1;
