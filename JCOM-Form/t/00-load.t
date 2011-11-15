#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'JCOM::Form' ) || print "Bail out!
";
}

diag( "Testing JCOM::Form $JCOM::Form::VERSION, Perl $], $^X" );
