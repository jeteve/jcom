#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'JCOM::DB' ) || print "Bail out!
";
}

diag( "Testing JCOM::DB $JCOM::DB::VERSION, Perl $], $^X" );
