package JCOM::Form::Field::Set;
use Moose;

extends qw/JCOM::Form::Field/;

=head1 NAME

JCOM::Form::Field::Set - A Set of Pure scalar Value's (Not references).

=head1 NOTES

The 'value' field of this is in fact a set of values.

=cut

has '+value' => ( isa => 'ArrayRef[Value]' , trigger => \&_value_set );

has '_values_idx' => ( isa => 'HashRef[Value]' , is => 'rw' , required => 1 , default => sub{ {}; } );

__PACKAGE__->meta->short_class('Set');
__PACKAGE__->meta->make_immutable();

=head2 has_value

Tests if this field is currently holding the given value.

Usage:

 if( $this->has_value($whatever_value) ){
    ...
 }

=cut

sub has_value{
  my ($self, $v) = @_;
  return exists $self->_values_idx->{$v};
}


sub _value_set{
  my ($self , $value, $old_value ) = @_;
  $self->_values_idx({});
  my $v_index = 0;
  foreach my $v ( @$value ){
    $self->_values_idx()->{$v} = $v_index++;
  }
}

=head2 value_struct

See superclass.

=cut

sub value_struct{
  my ($self) = @_;
  unless( $self->value() ){
    return undef;
  }
  return $self->value();
}

=head2 clear

Overrides clear so it maintains the value index.

=cut

sub clear{
   my ($self) = @_;
   $self->next::method();
   $self->_values_idx({});
};

1;
