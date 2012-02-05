package JCOM::Form::FieldRole::Repeat;
use Moose::Role;
with qw/JCOM::Form::FieldRole/;

=head1 NAME

JCOM::Form::FieldRole::Repeat - A Role that requires this field to repeat another one

=cut

has 'repeat_field' => ( is => 'rw' , isa => 'JCOM::Form::Field' , required => 0);

after 'validate' => sub{
  my ($self) = @_;
  unless( $self->repeat_field ){ return ; }

  if( ( $self->repeat_field->value() // '' ) ne ( $self->value() // '' ) ){
    $self->add_error("Please repeat the field \"".$self->repeat_field->label().'"');
  }

};

1;
