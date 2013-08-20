#!perl -T
use strict;
use warnings;
use Test::More;
use Test::Exception;
use JCOM::Form;
use JCOM::Form::Clerk::Hash;


package MyFormMax;
use Moose;
extends qw/JCOM::Form/;

sub build_fields{
  my ($self) = @_;
  my $sf = $self->add_field('String' , 'astr' )->add_role('MaxLength', { max_length => 10 });
}

1;
package main;

my $f = MyFormMax->new();

## Test valid input
JCOM::Form::Clerk::Hash->new( source => { astr => '0123456789' } )->fill_form($f);
ok( !$f->has_errors() , "Ok not errors");
$f->clear();

## Test invalid input
JCOM::Form::Clerk::Hash->new( source => { astr => '012345678910'} )->fill_form($f);
ok( $f->has_errors() , "Ok errors due to max length");
$f->clear();

done_testing();
