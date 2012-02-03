package JCOM::Form::Meta::Class::Trait::HasShortClass;
use Moose::Role;

=head2 NAME

JCOM::Form::Meta::Class::Trait::HasShortClass - Gives a 'meta->short_class' attribute to this trait consumer.

=cut

has 'short_class' => ( is => 'rw' , isa => 'Str');
1;
