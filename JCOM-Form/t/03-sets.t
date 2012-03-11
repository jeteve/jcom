#!perl -T
use strict;
use warnings;
use Test::More;
use Test::Exception;
use JCOM::Form;
use JCOM::Form::Clerk::Hash;

# ok( my $f = JCOM::Form::Test->new() );
# ok( scalar( @{$f->fields()} ) , "Ok form has fields");
# foreach my $field ( @{$f->fields() }){
#   diag($field->name().' '.join(',' , $field->meta->linearized_isa()));
# }


# $f->clear();
# ok( my $clerk = JCOM::Form::Clerk::Hash->new( source => { field_String => 'Blabla' , field_Date => '2011-10-10',
#                                                           field_Boolean => 'Something true',
#                                                         } ) );
# ok( $clerk->fill_form($f) , "Ok the clerk can fill the form" );
# ok( $f->field('field_Boolean')->value() , "Ok boolean field is true");
# ok( $f->field('mandatory_and_long')->has_errors() , "Ok mandatory and long string has errors");
# diag(join(',' , @{$f->field('mandatory_and_long')->errors()} )  );
# $f->clear();

package MyFormSet;
use Moose;
extends qw/JCOM::Form/;

sub build_fields{
  my ($self) = @_;
  my $sf = $self->add_field('Set' , 'aset' );
}

1;
package main;

my $f = MyFormSet->new();
## Test field_Set
JCOM::Form::Clerk::Hash->new( source => { aset => 1 } )->fill_form($f);
ok( !$f->has_errors() , "Ok not errors");
$f->clear();
$f->field('aset')->add_role('Mandatory');
JCOM::Form::Clerk::Hash->new( source => {} )->fill_form($f);
ok($f->has_errors() , "Ok got error, because of mandatory");

$f->clear();
JCOM::Form::Clerk::Hash->new( source => { aset => [ 1, 2 ] } )->fill_form($f);
ok(! $f->has_errors() , "Ok No error again");

$f->field('aset')->add_role('MonoValued');
$f->clear();
JCOM::Form::Clerk::Hash->new( source => { aset => [ 1, 2 ] } )->fill_form($f);
ok($f->has_errors() , "Ok Error. Should be monovalued");
$f->clear();
JCOM::Form::Clerk::Hash->new( source => { aset => [ 2 ] } )->fill_form($f);
ok(!$f->has_errors() , "Mono valued => no error");



done_testing();
