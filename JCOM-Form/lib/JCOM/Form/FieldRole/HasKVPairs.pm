package JCOM::Form::FieldRole::HasKVPairs;
use Moose::Role;
with qw/JCOM::Form::FieldRole/;

has 'kvpairs' => ( is => 'rw' , isa => 'JCOM::KVPairs');

=head1 NAME

JCOM::Form::FieldRole::HasKVPairs - A Role that makes a field only aware of a set of 'kvpairs' values ( a L<JCOM::KVPairs> ).

=cut

1;
