#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'JCOM::BM' ) || print "Bail out!
";
}

diag( "Testing JCOM::BM $JCOM::BM::VERSION, Perl $], $^X" );
