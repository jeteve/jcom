package JCOM::Form::Clerk::Hash;
use Moose;
use DateTime::Format::ISO8601;

extends qw/JCOM::Form::Clerk/;

has '+source' => ( isa => 'HashRef' );
has '_date_parser' => ( is => 'ro' , default => sub{ DateTime::Format::ISO8601->new() });

sub fill_form{
  my ($self, $form) = @_;

  foreach my $field ( @{$form->fields()} ){
    my $m = '_fill_field_'.$field->short_class();
    $self->$m($field);
  }
  return $form;
}


sub _fill_field_Date{
  my ($self , $field) = @_;
  # Grab the date from the hash.
  if( my $date_str = $self->source->{$field->name()} ){
    $field->value($self->_date_parser()->parse_datetime($date_str));
  }
}

sub _fill_field_String{
  my ($self, $field) = @_;
  my $str = $self->source->{$field->name()};
  if( defined $str ){
    $field->value($str);
  }
}

__PACKAGE__->meta->make_immutable();
1;
