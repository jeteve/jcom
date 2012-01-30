package JCOM::Form::FieldRole::MinLength;
use Moose::Role;

requires 'validate';

has 'min_length' => ( is => 'rw' , isa => 'Int' , default => 0 , required => 1);

after 'validate' => sub{
  my ($self) = @_;
  unless( defined $self->value() ){ return ; }

  unless( length($self->value()) >= $self->min_length() ){
    $self->add_error('Value too short. Mininum length is '.$self->min_length());
  }

};

1;
