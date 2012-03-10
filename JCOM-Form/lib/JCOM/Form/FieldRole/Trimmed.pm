package JCOM::Form::FieldRole::Trimmed;
use Moose::Role;

with qw/JCOM::Form::FieldRole/;

=head1 NAME

JCOM::Form::FieldRole::Trimmed - A Role that trims the value to avoid heading and trailing spacing characters.

=cut


around 'value' => sub{
  my ($orig, $self , $new_v ) = @_;

  unless( defined $new_v ){
    return $self->$orig();
  }
  $new_v =~ s/^\s+//;
  $new_v =~ s/\s+$//;
  return $self->$orig($new_v);
};


1;
