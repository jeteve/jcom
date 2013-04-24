#!perl -T
use strict;
use warnings;
use Test::More;
use Test::Exception;
use JCOM::Form;
use JCOM::Form::Clerk::Hash;

use Data::Dumper;

package MyFormRE;
use Moose;
extends qw/JCOM::Form/;

sub build_fields{
  my ($self) = @_;
  my $sf = $self->add_field('String' , 'astring' );
  $sf->add_role('RegExpMatch' , { regexp_match => qr/^[a-z]+$/,
                                  regexp_match_desc => 'lower case characters'
                                } );
}

1;
package main;

my $f = MyFormRE->new();

## No error with that.
JCOM::Form::Clerk::Hash->new( source => { astring => 'abcd' } )->fill_form($f);
ok( !$f->has_errors() , "Ok not errors");
$f->clear();

{
  ## Some erroneous value.
  JCOM::Form::Clerk::Hash->new( source => { astring => '99abcd' } )->fill_form($f);
  ok($f->has_errors() , "Errors");
  cmp_ok($f->field('astring')->errors()->[0] , '=~' , qr/lower case/ , "Ok good error");
  $f->clear();

}

done_testing();
