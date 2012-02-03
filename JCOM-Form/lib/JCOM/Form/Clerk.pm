package JCOM::Form::Clerk;
use Moose;

has 'source' => ( required => 1 , is => 'ro' );

=head1 NAME

JCOM::Form::Clerk - A form clerk that can fill a form from some source.

=head2 SYNOPSIS

A Clerk knows how to fill a form from the input it expects.

=cut

=head2 fill_form

Fill the given form from the given source.

Usage:

  $this->fill_form($form);

=cut

sub fill_form{
  my ($self , $form) = @_;
  confess "Please implement this";
}

__PACKAGE__->meta->make_immutable();
1;
