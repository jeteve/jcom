package JCOM::DBIC::FilterColumn::SymCrypt;
use strict;
use warnings;

use base qw/DBIx::Class/;


use Crypt::CBC;
use namespace::clean;

=head1 NAME

JCOM::DBIC::FilterColumn::SymCrypt - Symetric encryption filtering for DBIC Row Objects.

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
