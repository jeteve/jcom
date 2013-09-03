#!perl -T
use strict;
use warnings;
use Data::Dumper;
use Test::More;
use Test::Exception;
use JCOM::Form;
use JCOM::Form::Clerk::Hash;


package MyForm4Hash;
use Moose;
extends qw/JCOM::Form/;

sub build_fields{
  my ($self) = @_;
  $self->add_field('Boolean' , 'a_bool' );
  $self->add_field('Date' , 'a_date' );
  $self->add_field('Integer' , 'a_int' );
  $self->add_field('Set' , 'a_set' );
  $self->add_field('String' , 'a_string' );
}

1;
package main;

my $f = MyForm4Hash->new();

my @input_hashes = (

                    { a_bool => 0,
                      a_date => '1977-10-20T17:04:00',
                      a_int => 314,
                      a_set => [ 'a', 'b' , 3 ],
                      a_string => 'bla'
                    },
                    { a_bool => 1,
                      a_date => '1977-10-20T17:04:00',
                      a_int => 314,
                      a_set => [ 'a', 'b' , 3 ],
                      a_string => 'bla'
                    },
                    { a_bool => undef,
                      a_date => '1977-10-20T17:04:00',
                      a_int => 314,
                      a_set => [ 'a', 'b' , 3 ],
                      a_string => 'bla'
                    },
                    { a_bool => undef,
                      a_date => undef,
                      a_int => 314,
                      a_set => [ 'a', 'b' , 3 ],
                      a_string => 'bla'
                    },
                    { a_bool => undef,
                      a_date => undef,
                      a_int => undef,
                      a_set => undef,
                      a_string => undef
                    },
                   );

foreach my $input_hash ( @input_hashes ){
  ## Test valid input
  JCOM::Form::Clerk::Hash->new( source => $input_hash )->fill_form($f);
  ## diag(Dumper($f->dump_errors()));
  ok( !$f->has_errors() , "Ok not errors");
  my $h_f = $f->values_hash();
  is_deeply($h_f , $input_hash , "Ok got same hash as Hash clerk input");
}


done_testing();
