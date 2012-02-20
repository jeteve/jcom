package JCOM::Form::Clerk::Hash;
use Moose;
use DateTime::Format::ISO8601;

extends qw/JCOM::Form::Clerk/;

=head1 NAME

JCOM::Form::Clerk::Hash - A Clerk that will fill a form from a hash of values.

=cut

has '+source' => ( isa => 'HashRef' );
has '_date_parser' => ( is => 'ro' , default => sub{ DateTime::Format::ISO8601->new() });

=head2 fill_form

Fills the form.

=cut

sub fill_form{
  my ($self , $form) = @_;
  $form->do_accept($self);
}

=head2 visit_form

Fills the given form with values from the source hash.

See superclass L<JCOM::Form::Clerk> for details.

=cut

sub visit_form{
  my ($self, $form) = @_;

  foreach my $field ( @{$form->fields()} ){
    my $m = '_fill_field_'.$field->meta->short_class();
    $self->$m($field);
    $field->validate();
  }
  return $form;
}


sub _fill_field_Date{
  my ($self , $field) = @_;
  # Grab the date from the hash.
  if( my $date_str = $self->source->{$field->name()} ){
    eval{
      $field->value($self->_date_parser()->parse_datetime($date_str));
    };
    if( $@ ){
      $field->add_error("Invalid date format in $date_str. Please use something like 2011-11-20");
    }
  }else{
    $field->clear_value();
  }
}

sub _fill_field_String{
  my ($self, $field) = @_;
  my $str = $self->source->{$field->name()};
  if( defined $str ){
    $field->value($str);
  }else{
    $field->clear_value();
  }
}

sub _fill_field_Boolean{
  my ($self , $field) = @_;
  my $value = $self->source->{$field->name()};
  if( $value ){
    $field->value(1);
  }else{
    $field->clear_value();
  }
}

__PACKAGE__->meta->make_immutable();
1;
