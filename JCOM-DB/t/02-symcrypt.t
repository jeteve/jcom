#!perl -T

use utf8;

use Test::More;
use Test::Exception ;
use DBI;


package MyTest::Schema;
use base qw/DBIx::Class::Schema/;

use Moose;
has 'jcom_sym_key' => ( is => 'rw' , isa => 'Str' , default => '' );

1;

package MyTest::Schema::Result::ARow;
use JCOM::DBIC::FilterColumn::SymCrypt;
use base qw/DBIx::Class::Core/;
__PACKAGE__->load_components(qw/+JCOM::DBIC::FilterColumn::SymCrypt/);
__PACKAGE__->table('test_arow');
__PACKAGE__->add_column('id', 'a' , 'b');
__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_columns( 'a' ,
                          { %{__PACKAGE__->column_info('a')},
                            jcom_symcrypt => 1
                          });
__PACKAGE__->add_columns( 'b' ,
                          { %{__PACKAGE__->column_info('b')},
                            jcom_symcrypt => 1,
			    jcom_symcrypt_binary => 1,
                          });

1;



package main;
use JCOM::DBIC::FilterColumn::SymCrypt;

unless( $ENV{'TEST_PG_DSN'} && $ENV{'PGUSER'} && $ENV{'PGPASSWORD'} ){
    plan skip_all => q|
No TEST_PG_DSN specified in environment. Bailing out.

run this with something like:

TEST_PG_DSN="dbi:Pg:dbname=testdb;host=localhost" PGUSER=bill PGPASSWORD=baroud" perl -Ilib t/...

|;
}


my $dsn = $ENV{'TEST_PG_DSN'};

ok( my $schema = MyTest::Schema->connect($dsn, $ENV{'PGUSER'}, $ENV{'PGPASSWORD'}, { AutoCommit => 1 }),
    "Ok Created schema");
lives_ok(sub{ $schema->txn_begin();} , "Ok beginning transation");

## Create the table test_arow
$schema->storage->dbh_do(
    sub {
	my ($storage, $dbh, @cols) = @_;
	$dbh->do('DROP TABLE IF EXISTS test_arow');
	$dbh->do("CREATE TABLE test_arow(id SERIAL,a TEXT, b TEXT)");
    });

## We need to do this, because our ARow class is in the same file.
$schema->register_source('ARow' , MyTest::Schema::Result::ARow->result_source_instance());

$schema->jcom_sym_key('Boudin Blanc aux noisettes');

## Create an object row
ok( my $row = $schema->resultset('ARow')->create({ a => 'Dis camion' }) , "Ok row created");

ok( my $rt_row = $schema->resultset('ARow')->find($row->id()) , "Ok Found it in the DB");
cmp_ok( $rt_row->a() , 'eq' , $row->a() , "And the value of a has stayed the same");

## For unicode/binary testing.
my $unistr = "\x{00B5}\x{03A9}";
{
    ok( utf8::is_utf8($unistr) , "Ok this string is marked as unicode/UTF8");
    ok( $row->update({ a => $unistr }) , "Ok setting a unicode");
    ## Round trip
    ok( my $rt_row = $schema->resultset('ARow')->find($row->id()) , "Ok Found it in the DB");
    cmp_ok( $rt_row->a() , 'eq' , $unistr , "Retrieved string is correct");
    ok( utf8::is_utf8($rt_row->a()) , "And is utf8");
}

{
  ## Now test a null value
  ok($row->update({ a => undef }) , "Ok updating to a null value");
  ## Round trip
  ok( my $rt_row = $schema->resultset('ARow')->find($row->id()) , "Ok Found it in the DB");
  ok(! defined $rt_row->a() , "NULL turns to undefined");
}

{
    ## Now test a pure binary storage
    my $bin = Encode::encode_utf8($unistr);
    ok( $row->update({ b => $bin}) , "Ok update");
    ok( my $rt_row = $schema->resultset('ARow')->find($row->id()) , "Ok Found it in the DB");
    cmp_ok( $rt_row->b() , 'eq' ,  $bin , "Retrieved bytes are correct");
    ok( ! utf8::is_utf8($rt_row->b()) , "And are NOT utf8");
}

done_testing();



END{
    $schema->txn_rollback() if $schema;
    #$schema->txn_rollback() if $schema;
}
