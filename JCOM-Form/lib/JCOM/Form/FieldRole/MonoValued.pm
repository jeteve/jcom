package JCOM::Form::FieldRole::MonoValued;
use Moose::Role;
with qw/JCOM::Form::FieldRole/;

=head1 NAME

JCOM::Form::FieldRole::MonoValued - A Role that makes a _Set_ field mono valued.

=cut

after 'validate' => sub{
  my ($self) = @_;
  unless( defined $self->value() ){
    return;
  }
  if( @{$self->value()} > 1 ){
    $self->add_error("Please provide only one value. The GUI code should not let you add more than one anyway.");
  }
};

1;
