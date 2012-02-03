#!perl -T
use Test::More;
use Test::Exception;
use JCOM::Form;
use DateTime;

ok( my $f = JCOM::Form->new() );

ok( $f->add_field('field1') );
ok( $f->add_field('String' , 'field2') );

ok( $f->field('field1')->isa('JCOM::Form::Field::String') , "Ok field1 is a string");
ok( $f->field('field2')->isa('JCOM::Form::Field::String') , "Ok field2 is a string too");
ok( $f->field('field2')->value('Bla') , "Ok can set value on f2");

ok( $f->add_field('Date' , 'field_date') , "Ok added date field");
ok( $f->add_field('+JCOM::Form::Field::Date' , 'field_date_2')  , "Ok added another field date");
ok( $f->field('field_date')->value(DateTime->now()), "Ok can set value");

ok( $f->add_field( JCOM::Form::Field::String->new({ form => $f , name => 'field3'})) , "Can add an instance");

dies_ok(sub{ $f->add_field('field1'); } , "Cannot add twice the same field");

ok( $f->add_error('There is an error') , "Ok can add error");
ok( $f->has_errors() , "Form has errors");
$f->clear();
ok( ! $f->has_errors() , "Form doesnt have errors anymore");

$f->field('field2')->add_error('A field error');
ok( $f->has_errors() , "Ok form has error because of a field");
$f->clear();
ok(! $f->has_errors() , "Ok form is reset, so no error");
ok( $f->field('field2')->set_label('Boudin blanc')->isa('JCOM::Form::Field') , "Ok can set label");

done_testing();
