package JCOM::Form::Test;
use Moose;
use Moose::Util qw/apply_all_roles/;
use Class::MOP;
use Module::Pluggable::Object;

=head1 NAME

JCOM::Form::Test - A Test form containing all the supported native field types.

=cut

extends qw/JCOM::Form/;

sub build_fields{
  my ($self) = @_;

  my @res = ();
  my $mp = Module::Pluggable::Object->new( search_path => 'JCOM::Form::Field' );
  foreach my $field_class ( $mp->plugins() ){
    Class::MOP::load_class($field_class);
    warn "Loaded $field_class";
    $self->add_field($field_class.'' , 'field_'.$field_class->meta->short_class() );
  }

  ## Add a mandatory field.
  my $field = JCOM::Form::Field::String->new({ name => 'mandatory_str' , form => $self });
  apply_all_roles($self->add_field($field) , 'JCOM::Form::FieldRole::Mandatory' );
  $field->meta->short_class('String');
}

__PACKAGE__->meta->make_immutable();

1;
