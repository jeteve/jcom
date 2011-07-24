package JCOM::DBIC::FilterColumn::SymCrypt;
use strict;
use warnings;

use base qw/DBIx::Class/;


use Crypt::CBC;
use namespace::clean;

=head1 NAME

JCOM::DBIC::FilterColumn::SymCrypt - Symetric encryption filtering for DBIC Row Objects.

=head1 DESCRIPTION



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
		filter_to_storage => \&_encrypt_column,
		filter_from_storage => \&_decrypt_column
	    });	
    } # End of option jcom_symcrypt
}

sub _encrypt_column{
    my ($self, $value) = @_;
    return $self->_build_cypher->encrypt_hex($value);
}

sub _decrypt_column{
    my ($self, $value) = @_;
    return $self->_build_cypher->decrypt_hex($value);
}

sub _build_cypher{
    my ($self) = @_;
    my $schema = $self->result_source->schema();
    my $key = $schema->jcom_sym_key();
    unless( $key  ){
	$schema->throw_exception( "Could not find any defined jcom_sym_key in Schema $schema.");
    }
    return Crypt::CBC->new( -key    => $key,
			    -cipher => 'Blowfish' );    
}

1;
