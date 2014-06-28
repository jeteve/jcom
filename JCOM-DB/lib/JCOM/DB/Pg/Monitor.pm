package JCOM::DB::Pg::Monitor;
use Moose::Role;
use Digest::SHA;

use Log::Log4perl;

with qw/JCOM::DB::DBIAble/;

my $LOGGER = Log::Log4perl->get_logger();

=head1 NAME

JCOM::DB::Pg::Monitor - Gives Mutex monitor capabilities to your consuming objects.

=head2 SYNOPSIS

This is a Moose::Role. Consume it in your DB management class and implement the method
jcom_get_dbh.


Example:

    package My::DB;
    use Moose;
    with qw/JCOM::DB::Pg::Monitor/;

    sub jcon_get_dbh{ .. return the dbh connection of your choice ..}
    ...

    package main;
    my $db = .. an instance of My::DB ..;


    $db->jcom_db_mutex($key , sub{ ... Mutually exclusive stuff ... } );

=cut

=head2 jcom_db_mutex

Executes the given bit of code in a mutually exclusive (between processes)
way according to the given $key.

$key can be an arbitratry string.

Note that withing the Same DB session, no deadlock can happen if
you try locking on the same key.

But keep in mind that in general, it's not really a good idea to mutex on something else
in your exclusive code. So really you should use this function ONCE at the highest possible level
of your application (at the interface layer level is good).


Usage:

   my $o = <Any role consuming object>
   my $res = $o->jcom_db_mutex('an object:123456',
                      sub{
                         ... load an object 123456 and do exclusive stuff on it ...
                         ... return a SCALAR ..
                      });

=cut

sub jcom_db_mutex{
  my ($self, $key, $exclusive_code) = @_;



  my $dbh = $self->jcom_get_dbh();

  my ( $ia , $ib ) = $self->_jcom_db_mutex_keyab($key);

  $LOGGER->debug("WILL LOCK ON key '$key': $ia,$ib");
  $dbh->selectrow_arrayref("SELECT pg_advisory_lock(?, ?)" , {}, $ia , $ib);
  $LOGGER->debug("PASSED LOCK ON $ia,$ib");

  my $res = eval { scalar(&{$exclusive_code}()) };
  my $err = $@;
  $dbh->selectrow_arrayref("SELECT pg_advisory_unlock(?, ?)",{},  $ia, $ib);

  if( $err ){
    confess("ERROR IN jcom_db_mutex: $err");
  }
  return $res;
}

=head2 jcom_db_mutex_busy

Is the given key busy (locked) or not. Useful to avoid doing something twice in a raw.

Note that there is no guarranty about this. You should just see that as a preliminary
probing to proper locking.

Usage:


  # Avoid doing sub twice in a row.
  unless( $this->jcom_db_mutex_busy($key) ){
      $this->jcom_db_mutex($key, sub{ ... });
  }

=cut

sub jcom_db_mutex_busy{
  my ($self, $key) = @_;

  my $dbh = $self->jcom_get_dbh();
  my ( $ia , $ib ) = $self->_jcom_db_mutex_keyab($key);

  $LOGGER->debug("WILL PROBE LOCK ON key '$key': $ia,$ib");

  my $row = $dbh->selectrow_arrayref("SELECT pg_try_advisory_lock(?, ?)" , {}, $ia , $ib);
  if( $row->[0] ){
    $dbh->selectrow_arrayref("SELECT pg_advisory_unlock(?, ?)",{},  $ia, $ib);
    return 0; # The lock was not busy
  }

  # Lock is busy
  return 1;
}

sub _jcom_db_mutex_keyab{
  my ($self, $key) = @_;
  unless( $key ){ confess("No key given"); }

  my $twenty_bytes = Digest::SHA::sha1($key);
  my $four_first = substr($twenty_bytes, 0, 4);
  my $four_next  = substr($twenty_bytes, 4, 4);
  # Build two 32 bits integers.
  my $ia = unpack('i' , $four_first);
  my $ib = unpack('i' , $four_next);
  return ($ia, $ib);
}

1;
