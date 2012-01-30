package JCOM::Form::FieldRole::Mandatory;
use Moose::Role;

requires 'validate';

after 'validate' => sub{
  my ($self) = @_;
  unless( defined $self->value() ){
    $self->add_error("Mandatory Value");
  }
};

1;
