package JCOM::DB::Pg::Blobs;
use Moose::Role;

requires 'jcom_get_dbh';

=head1 NAME

JCOM::DB::Pg::Blobs - Blobs management methods for Postgresql related DB modules.

=head2 SYNOPSIS

This is a Moose::Role. Consume it in your DB management class and implement the method
jcom_get_dbh.

Note that blob management in postgresql do not work outside a transaction.

Example:

    package My::DB;
    use Moose;
    with qw/JCOM::DB::Pg::Blobs/;

    sub jcon_get_dbh{ .. return the dbh connection of your choice ..}
    ...

    package main;
    my $db = .. an instance of My::DB ..;

    #### IMPORTANT: IN A TRANSACTION
    my $blob = $db->jcom_store_blob('binary content');
    my $content = $db->jcom_fetch_blob($blob);
    etc..

=cut

=head2 jcom_create_blob

Creates a Postgresql empty blob (oid) and returns it.

Note that it is not very useful. Use jcom_stream_in_blob or
jcom_store_blob instead.

Usage:

   my $blob = $this->jcom_create_blob()

=cut

sub jcom_create_blob{
    my ($self) = @_ ;
    my $dbh = $self->jcom_get_dbh();

    my $oid = $dbh->func($dbh->{pg_INV_WRITE} || $dbh->{pg_INV_READ},'lo_creat') 
	|| confess "CANT CREATE BLOB\n" ;
    return $oid ;
}


=head2 jcom_store_blob ($buf)

Stores the given binary content in the postgresql db and return the blob id.

Usage:

   my $blob = $this->jcom_store_blob('Full short binary content');


=cut

sub jcom_store_blob{
    my ($self , $buf ) = @_ ;
    my $oid = $self->jcom_create_blob ;
    my $dbh = $self->jcom_get_dbh();
    my $fh = $dbh->func($oid,
			$dbh->{pg_INV_WRITE},
			'lo_open');
    my $blength = length($buf) ;
    my $nbytes = $dbh->func($fh, $buf, $blength , 'lo_write');
    $dbh->func($fh, 'lo_close');
    return $oid ;
}

=head2 jcom_stream_in_blob ($sub)

Pulls data using the given read code, storing it into a new blob.

Returns the new blob id.

Usage:

    my $blob = $this->jcom_stream_in_blob(sub{ return 'Next slice of bytes or undef' ;});

=cut

sub jcom_stream_in_blob{
  my ($self,$read) = @_;
  my $oid = $self->jcom_create_blob();
  my $dbh = $self->jcom_get_dbh();
  my $fh = $dbh->func($oid,$dbh->{pg_INV_WRITE},
                      'lo_open');
  while( defined( my $buf = &{$read}() ) ){
    my $blength = length($buf) ;
    my $nbytes = $dbh->func($fh, $buf, $blength , 'lo_write');
  }
  $dbh->func($fh, 'lo_close');
  return $oid;
}

=head2 jcom_stream_out_blob

Streams out the given blob ID in the given write sub and return the number of bytes
retrieved.

Example:

   $s->stream_out_blob(sub{ my $fresh_bytes = shift ; ... ; } , $oid );

=cut

sub jcom_stream_out_blob{
  my ($self,$write,$oid) = @_;
  my $dbh = $self->jcom_get_dbh();

  my $fh = $dbh->func($oid ,  $dbh->{pg_INV_READ}, 'lo_open');
  my $buf = '' ;
  my $total_bytes = 0;
  # Read by chunks of 1024
  while( my $nbytes = $dbh->func($fh , $buf, 1024 , 'lo_read') ){
    $total_bytes += $nbytes;
    ## Call write with this chunk
    &{$write}(substr($buf, 0 , $nbytes ));
  }
  return $total_bytes;
}

=head2 jcom_fetch_blob ($oid)

Fectches the blob binary content in one go

Usage:

  my $small_content = $this->jcom_fetch_blob($blob);

=cut

sub jcom_fetch_blob{
    my ($self , $oid ) = @_ ;
    my $dbh = $self->jcom_get_dbh();

    my $fh = $dbh->func($oid ,  $dbh->{pg_INV_READ}, 'lo_open');
    my $content ; 
    my $buf = '' ;
    # Read by chunks of 1024
    while( my $nbytes = $dbh->func($fh , $buf, 1024 , 'lo_read') ){   
        $content .= substr($buf, 0 , $nbytes );
    }
    return $content ;
}




1;
