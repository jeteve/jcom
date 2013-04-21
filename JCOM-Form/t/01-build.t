#!perl -T
use Test::More;
use Test::Exception;
use JCOM::Form;
use DateTime;

ok( my $f = JCOM::Form->new() );
diag($f->meta->id());
ok( $f->meta->id() =~ /^form_/ , "Ok form id is prefixed correctly");
ok( $f->id() , "Still ok to call deprecated id");

ok( $f->add_field('field1') );
ok( $f->add_field('String' , 'field2')->set_help('This is field 2')->set_placeholder('BLA') , "Ok can build field2 with help text and placeholder" );
ok( $f->add_field('Integer' , 'int_field') , "Ok can buid Integer field");

ok( $f->field('field1')->isa('JCOM::Form::Field::String') , "Ok field1 is a string");
ok( $f->field('field2')->isa('JCOM::Form::Field::String') , "Ok field2 is a string too");
ok( $f->field('int_field')->isa('JCOM::Form::Field::Integer') , "Ok field2 is an integer");
ok( $f->field('field2')->value('Bla') , "Ok can set value on f2");

ok( $f->add_field('Date' , 'field_date') , "Ok added date field");
ok( $f->add_field('+JCOM::Form::Field::Date' , 'field_date_2')  , "Ok added another field date");
ok( $f->field('field_date')->value(DateTime->now()), "Ok can set value");
ok( $f->field('int_field')->value(100) , "Ok can set valid integer value");
is( $f->field('int_field')->value() , 100 , "Good value is stored");
is( $f->field('int_field')->value(-100) , -100 , "Good value is stored");

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
ok( $f->is_valid() , "Is also valid");
ok( $f->field('field2')->set_label('Boudin blanc')->isa('JCOM::Form::Field') , "Ok can set label");
ok( $f->field('field2')->id() , "Ok got an id");
cmp_ok( $f->field('field2')->meta->short_class() , 'eq' , $f->field('field2')->short_class() , "Shortcut short_class works");

done_testing();
