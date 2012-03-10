package JCOM::Form::FieldRole::Email;
use Moose::Role;
with qw/JCOM::Form::FieldRole
        JCOM::Form::FieldRole::Trimmed
       /;

use Mail::RFC822::Address;

=head1 NAME

JCOM::Form::FieldRole::Email - A Role that checks if the value looks like an email.

=cut


around 'value' => sub{
  my ($orig, $self , $v ) = @_;
  unless( defined $v ){
    return $self->$orig();
  }
  my $new_v = lc($v);
  return $self->$orig($new_v);
};


after 'validate' => sub{
  my ($self) = @_;

  ## Nothing to validate.
  unless( $self->value() ){ return ;}
  unless( Mail::RFC822::Address::valid($self->value) ){
    $self->add_error("Invalid email. Please check it looks like john\@example.com");
  }
};
1;
