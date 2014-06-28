#!perl
use Test::More;
use Test::Exception ;
use DBI;
use POSIX ":sys_wait_h";


package My::Object;
use Moose;
with qw/JCOM::DB::Pg::Monitor/;
has 'dbh' => ( is => 'ro', required => 1);
sub jcom_get_dbh{ return shift->dbh(); }
1;

package main;

eval{ require Test::postgresql;};
if( $@ ){
  plan skip_all => 'No Test::postgresql';
  done_testing();
};

my $pgsql = Test::postgresql->new();
unless( $pgsql ){
  plan skip_all => ${"Test::postgresql::errstr"};
  done_testing();
}


my $dsn = $pgsql->dsn;
ok( my $dbh = DBI->connect($dsn , '' , '' , { AutoCommit => 1, RaiseError => 1 }) , "Ok connecting to db");
unless( $dbh ){
    BAIL_OUT("Could not connect to DB using $dsn");
}



ok( my $o = My::Object->new({ dbh => $dbh }) , "Ok created o");
is( $o->jcom_db_mutex('object:whatever', sub{ return 'toto'; }) , "toto" , "Ok good return");
is( $o->jcom_db_mutex('object:whatever', sub{ return 'toto'; }) , "toto" , "Ok good return");
is( $o->jcom_db_mutex('object:whatever', sub{ return 'toto'; }) , "toto" , "Ok good return");

$dbh->do("CREATE TABLE horrible_table(id INTEGER NOT NULL)");

# Ok now lets do some horrible stuff and check its alright.
my @pids = ();
foreach ( 1..10 ){
  if( my $pid = fork() ){
    push @pids , $pid;
    next;
  }

  {
    # In a child process.
    # Connect to the same DSN and so some horrible thing.
    my $dbh = DBI->connect($dsn , '' , '' , { AutoCommit => 1, RaiseError => 1 });
    my $o = My::Object->new({ dbh => $dbh });

    # Test a crash doesnt leave a locked key
    eval{ $o->jcom_db_mutex('some crashing key', sub{
                              die "Something wrong";
                            }) };

    $o->jcom_db_mutex('some key', sub{
                        my ($max) = $dbh->selectrow_array('SELECT MAX(id) FROM horrible_table');
                        $max //= 0;
                        ## sleep(1);
                        $dbh->do('INSERT INTO horrible_table(id) VALUES (?)', {} , $max + 1);
                      });

    exit(0);
  }
}

## Reconnect.
$dbh = DBI->connect($dsn , '' , '' , { AutoCommit => 1, RaiseError => 1 });
$o = My::Object->new({ dbh => $dbh });

# Wait for all pids.
foreach my $pid( @pids ){
  waitpid $pid, 0;
}

ok( ! $o->jcom_db_mutex_busy('some key') , "Ok 'some key' is NOT busy");

# Fork a process to make the lock busy again
{
  if( my $pid = fork() ){
    sleep(4);
    # This should be busy if the child process manages to start within 4 seconds.
    ok( $o->jcom_db_mutex_busy('some key') , "Ok 'some key' is busy");
    waitpid $pid, 0;
  }else{
    # In a child process.
    # Connect to the same DSN and so some horrible thing.
    my $dbh = DBI->connect($dsn , '' , '' , { AutoCommit => 1, RaiseError => 1 });
    my $o = My::Object->new({ dbh => $dbh });
    $o->jcom_db_mutex('some key', sub{
                        sleep(10);
                        1;
                      });
    exit(0);
  }
}



## Reconnect.
$dbh = DBI->connect($dsn , '' , '' , { AutoCommit => 1, RaiseError => 1 });
$o = My::Object->new({ dbh => $dbh });


my ($max) = $dbh->selectrow_array('SELECT MAX(id) FROM horrible_table');
is( $max , 10 , "Ok we could add 10 distinct ids concurrently");
ok( ! $o->jcom_db_mutex_busy('some key') , "Ok 'some key' is NOT busy");


done_testing();
