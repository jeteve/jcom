#!perl -T

use Test::More;
# use File::Temp;
use DBI;
use DBD::SQLite;

use JCOM::BM::DBICWrapper;


package My::Schema;
use base qw/DBIx::Class::Schema::Loader/;
__PACKAGE__->naming('current');
1;


package My::Model;
use Moose;
with qw/JCOM::BM::DBICWrapper/;
1;

package My::Model::O::Product;
use Moose;
extends 'JCOM::BM::DBICObject';
has 'o' => ( isa => 'My::Schema::Product' , is => 'ro' , required => 1 , handles => [ 'id' , 'name' ] );
sub turn_on{
    my ($self) = @_;
    return "Turning on $self";
}

1;

package My::Model::Factory::Product;
use Moose;
extends  qw/JCOM::BM::DBICFactory/ ;

sub wrap{
    my ($self , $o) = @_;
    return My::Model::O::Product->new({o => $o , bm => $self->bm() });
}
1;

package main;

## Connect to a DB and dynamically build the DBIC model.
ok( my $dbh = DBI->connect("dbi:SQLite::memory:" , "" , "") , "Ok connected as a DBI");
ok( $dbh->{AutoCommit} = 1 , "Ok autocommit set");
ok( $dbh->do("PRAGMA foreign_keys = ON") , "Ok set foreign keys");
ok( $dbh->do('CREATE TABLE builder(id INTEGER PRIMARY KEY AUTOINCREMENT, bname VARCHAR(255) NOT NULL)') , "Ok creating builder table");
ok( $dbh->do('CREATE TABLE product(id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR(255), builder_id INTEGER,FOREIGN KEY (builder_id) REFERENCES builder(id))') , "Ok creating product table");

## Build a schema dynamically.
ok( my $schema = My::Schema->connect(sub{ return $dbh ;} ), "Ok built schema with dbh");
## Just to check
ok( $schema->resultset('Builder') , "Builder resultset is there");
ok( $schema->resultset('Product') , "Product resultset is there");


## Build a My::Model using it
ok( my $bm = My::Model->new({ jcom_schema => $schema }) , "Ok built a model");

## And test a few stuff.
ok( my $pf = $bm->jcom_factory('Product') , "Ok got product factory");
ok( my $bf = $bm->jcom_factory('Builder') , "Ok got builder factory");

## Object creation.
ok( my $b = $bf->create( { bname => 'Builder1' }) , "Ok built the first builder");
## Object loopback
ok( $b = $bf->find($b->id()) , "Ok found it by id");
cmp_ok( $b->bname , 'eq' , 'Builder1' , "Good data");

## Now a product
ok( my $p = $pf->create( { name => 'Hoover' , builder => $b }) , "Ok could make a product");
ok( $p->id() , "Hoover product has got an ID");
ok( $p->turn_on() , "Can be turned on as well");

done_testing();
