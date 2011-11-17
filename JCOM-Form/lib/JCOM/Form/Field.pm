package JCOM::Form::Field;
use Moose;

=head1 NAME

JCOM::Form::Field - A field for JCOM::Form s

=cut

has 'form' => ( isa => 'JCOM::Form' , is => 'ro' , weak_ref => 1 , required => 1 );
has 'name' => ( isa => 'Str' , is => 'ro' , required => 1 );

has 'errors' => ( isa => 'ArrayRef[Str]' , is => 'rw' , default => sub{ [] } , required => 1 );

sub short_class{
  my ($self) = @_;
  my $class = ref($self) || $self;
  $class =~ s/^JCOM::Form::Field:://;
  $class =~ s/\W+/_/g;
  return $class;
}

sub add_error{
  my ($self , $err_str) = @_;
  push @{$self->errors()} , $err_str;
}

sub has_errors{
  my ($self) = @_;
  return scalar(@{$self->errors()});
}

__PACKAGE__->meta->make_immutable();
1;
