#!perl -T
use strict;
use warnings;
use Test::More;
use Test::Exception;
use JCOM::Form::Test;
use JCOM::Form::Clerk::Hash;

use DateTime;

ok( my $f = JCOM::Form::Test->new() );
ok( scalar( @{$f->fields()} ) , "Ok form has fields");
foreach my $field ( @{$f->fields() }){
  diag($field->name());
}
ok( my $clerk = JCOM::Form::Clerk::Hash->new( source => { field_String => 'Blabla' , field_Date => '2011-10-10' } ) );
ok( $clerk->fill_form($f) , "Ok the clerk can fill the form" );
$f->clear();



ok( $clerk = JCOM::Form::Clerk::Hash->new( source => { field_String => 'Blabla' , field_Date => 'BAD_DATE_STRING' } ) );
ok( $clerk->fill_form($f) , "Ok the clerk can fill the form" );
ok( $f->has_errors() , "Form has errors");
ok( $f->field('mandatory_str')->has_errors() , "Ok mandatory string has errors!");
$f->clear();
ok( ! $f->has_errors() , "Form has no errors after clear");



done_testing();
