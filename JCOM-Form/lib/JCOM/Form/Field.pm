package JCOM::Form::Field;
use Moose;

=head1 NAME

JCOM::Form::Field - A field for JCOM::Form s

=cut

has 'form' => ( isa => 'JCOM::Form' , is => 'ro' , weak_ref => 1 , required => 1 );
has 'name' => ( isa => 'Str' , is => 'ro' , required => 1 );

has 'errors' => ( isa => 'ArrayRef[Str]' , is => 'rw' , default => sub{ [] } , required => 1 );

__PACKAGE__->meta->make_immutable();
1;
