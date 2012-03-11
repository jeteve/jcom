package JCOM::KVPairs::Pure;
use Moose;
extends qw/JCOM::KVPairs/;

=head1 NAME

JCOM::KVPairs::Pure - A pure Perl structure based KVPairs Set.

=head2 SYNOPSYS

 my $set = JCOM::KVPairs::Pure
             ->new({ array => [ { 1 => 'One'},
                                { 2 => 'Two'},
                                 ...
                              ]});


=cut

has 'array' => ( is => 'ro' , isa => 'ArrayRef[HashRef]' , required => 1);

## Internal stuff
has '_index' => ( is => 'ro' , isa => 'HashRef[Defined]' , lazy_build => 1 );
has '_it' => ( is => 'rw' , isa => 'Int' , clearer => '_clear_it' );

sub _build__index{
  my ($self) = @_;

  my $idx = {};
  foreach my $kv ( @{$self->array()} ){
    my @kv = %$kv;
    if( $idx->{$kv[0]}){
      confess("Key ".$kv[0]." is repeated in your key value pairs");
    }
    $idx->{$kv[0]} = $kv[1];
  }
  return $idx;
}

sub size{
  my ($self) = @_;
  return scalar(@{$self->array()});
}

sub lookup{
  my ($self , $key) = @_;
  return $self->_index()->{$key};
}

sub next_kvpair{
  my ($self) = @_;
  unless( defined $self->_it() ){
    $self->_it(0);
  }

  if( my $kv = $self->array->[$self->_it()] ){
    $self->_it($self->_it() + 1 );
    return %{$kv};
  }

  ## We reached the end.
  $self->_clear_it();
  return ();
}

1;
