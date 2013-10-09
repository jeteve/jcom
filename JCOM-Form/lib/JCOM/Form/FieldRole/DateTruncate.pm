package JCOM::Form::FieldRole::DateTruncate;
use Moose::Role;
with qw/JCOM::Form::FieldRole/;

=head1 NAME

JCOM::Form::FieldRole::DateTruncate - Truncate a Date to the given date_truncation.

=cut

has 'date_truncation' => ( is => 'rw' , isa => 'Str', required => 1);

around 'value' => sub{
  my ($orig, $self, $new_date) = @_;
  unless( $new_date ){ return $self->$orig() ; };

  return $self->$orig($new_date->truncate( to => $self->date_truncation ));
};

around 'value_struct' => sub{
  my ($orig, $self, @rest) = @_;
  unless(defined $self->value() ){
    return undef;
  }
  if( grep { $_ eq $self->date_truncation() } ( "year", "month", "week", "day" ) ){
    return $self->value()->ymd();
  }else{
    return $self->value()->iso8601();
  }
};

1;
