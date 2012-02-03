package JCOM::Form::FieldRole::Mandatory;
use Moose::Role;
with qw/JCOM::Form::FieldRole/;

=head1 NAME

JCOM::Form::FieldRole::Mandatory - A Role that makes the field mandatory

=cut

after 'validate' => sub{
  my ($self) = @_;
  unless( defined $self->value() ){
    $self->add_error("Mandatory Value");
  }
};

1;
