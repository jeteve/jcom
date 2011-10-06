#!perl -T
use Test::More;
use JCOM::Sequence;

ok( my $s = JCOM::Sequence->new() );
my $n;
ok( $n = $s->next() );
cmp_ok( $n , '<' , $s->next() , "Ok sequence is going up");
done_testing();
