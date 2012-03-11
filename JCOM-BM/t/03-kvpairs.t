#!perl -T
use Test::More;
use JCOM::KVPairs::Pure;

ok( my $set = JCOM::KVPairs::Pure->new({ array => [ { 1 => 'One'},
                                                    { 2 => 'Two'},
                                                    { 3 => 'Three' }
                                                  ]}) , "Ok can build set");

cmp_ok( $set->size(), '==' , 3 , "Ok size is good");
my $it = 0;
while( my @kv = $set->next_kvpair() ){
  $it++;
}
cmp_ok( $it , '==' , 3 , "We went though the iteration 3 times");

my @kv = $set->next_kvpair();
cmp_ok( @kv[0] , '==' , 1 , "Got first kv pair (1)");
cmp_ok( @kv[1] , 'eq' , 'One' , "And it matches 'One'");

ok( my $two = $set->lookup(2) , "Ok can lookup 2");
cmp_ok( $two , 'eq' , 'Two' , "Got the right thing back");

done_testing();
