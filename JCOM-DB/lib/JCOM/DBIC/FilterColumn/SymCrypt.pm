package JCOM::DBIC::FilterColumn::SymCrypt;
use strict;
use warnings;

use base qw/DBIx::Class/;


use Crypt::OpenPGP;
use namespace::clean;

=head1 NAME

JCOM::DBIC::FilterColumn::SymCrypt - Symetric encryption filtering for DBIC Row Objects.

=head1 DESCRIPTION

This package allows you to implement symetric encryption on some columns of
your DBIx::Class schema easily.

It uses Crypt::OpenPGP in the backend in GnuPG compat mode  and aims to stay compatible with Postgresql
pgcrypto open pgp symetrical encryption functions.

fyi, GnuPG compat mode means:

cipher = Rijndael (aes128), compression = Zlib, modification detection code (MDC) = 1

You can decrypt the stored bytes with

select pgp_sym_decrypt_bytea(dearmor( ... ), 'Boudin Blanc aux noisettes' , 'compress-algo=2') from .... ;

=head1 SYNOPSYS

In your schema, make sure you expose the jcom_sym_key accessor.
It will be used to read the current symetric key set in your schema.

You can use Moose to achieve this for instance:

  package MyTest::Schema;
  use base qw/DBIx::Class::Schema/;
  use Moose;
  has 'jcom_sym_key' => ( is => 'rw' , isa => 'Str' , default => '' );

In your resultclass, simply add some property to the field you want to have encrypted:

  package MyTest::Schema::Result::ARow;
  use JCOM::DBIC::FilterColumn::SymCrypt;
  use base qw/DBIx::Class::Core/;
  __PACKAGE__->load_components(qw/+JCOM::DBIC::FilterColumn::SymCrypt/);
  __PACKAGE__->table('test_arow');
  __PACKAGE__->add_column('id' , 'a');
  __PACKAGE__->set_primary_key('id');

  __PACKAGE__->add_columns( 'a' ,
                            { %{__PACKAGE__->column_info('a')},
                             jcom_symcrypt => 1
                            });

Then in your client code, use the object as usual. Just don't forget
to set the jcom_sym_key:

  $schema->jcom_sym_key('Boudin Blanc aux noisettes');

  ## Create an object row. The attribute a will be stored as an encrypted string of character (not bytes).
  my $row = $schema->resultset('ARow')->create({ a => 'Dis camion' });
  my $rt_row = $schema->resultset('ARow')->find($row->id());
  ## rt_row->a() is now the same as the original.


IMPORTANT NOTES:

This will store/retrieve the given string as BYTES, not as a unicode string.

To work in tainted mode, you need to use https://github.com/WCN/Crypt-OpenPGP/commits/subkeys-rijndael-taint

=cut


__PACKAGE__->load_components(qw/FilterColumn/);


=head2 register_column

Extends the register column to take the jcom_symcrypt
into account.

=cut

sub register_column{
    my ($self , $column, $info , @rest ) = @_;

    $self->next::method($column,$info, @rest);
    if( $info->{'jcom_symcrypt'} ){
	##  Installing filter_column on the column
	$self->filter_column(
	    $column => {
		filter_to_storage => \&_jcom_encrypt_column,
		filter_from_storage => \&_jcom_decrypt_column
	    });	
    } # End of option jcom_symcrypt
}

sub _jcom_encrypt_column{
    my ($self, $value) = @_;
    return $self->_jcom_build_cypher->encrypt( Data => $value,
					  Passphrase => $self->_jcom_get_sym_key(),
					  Armour => 1,
					);
}

sub _jcom_decrypt_column{
    my ($self, $value) = @_;
    return $self->_jcom_build_cypher->decrypt( Data => $value,
					  Passphrase => $self->_jcom_get_sym_key(),
					);
}

sub _jcom_build_cypher{
    my ($self) = @_;
    return Crypt::OpenPGP->new( Compat => 'GnuPG' );
}

sub _jcom_get_sym_key{
    my ($self) = @_;
    my $schema = $self->result_source->schema();
    my $key = $schema->jcom_sym_key();
    unless( $key  ){
	$schema->throw_exception( "Could not find any defined jcom_sym_key in Schema $schema.");
    }
    return $key;
}

1;
