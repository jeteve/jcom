package JCOM::Form::Test;
use Moose;
use Class::MOP;
use Module::Pluggable::Object;

=head1 NAME

JCOM::Form::Test - A Test form containing all the supported native field types.

=cut

extends qw/JCOM::Form/;

has '+fields' => ( 'default' => sub{ shift->build_fields() } );

sub build_fields{
  my ($self) = @_;

  my @res = ();
  my $mp = Module::Pluggable::Object->new( search_path => 'JCOM::Form::Field' );
  foreach my $field_class ( $mp->plugins() ){
    Class::MOP::load_class($field_class);
    push @res, $field_class->new( name => 'field_' . $field_class->short_class() , form => $self );
  }
  return \@res;
}

__PACKAGE__->meta->make_immutable();

1;
