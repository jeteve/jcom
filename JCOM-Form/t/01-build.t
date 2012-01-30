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
ok( $f->field('field_date')->value(DateTime->now()), "Ok can set value");

ok( $f->add_field( JCOM::Form::Field::String->new({ form => $f , name => 'field3'})) , "Can add an instance");

dies_ok(sub{ $f->add_field('field1'); } , "Cannot add twice the same field");

done_testing();
