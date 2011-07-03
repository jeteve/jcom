package JCOM::DB::DBIAble;
use Moose::Role;

=head1 NAME

JCOM::DB::DbhAble - Role for any DB related object capable of giving DBI stuff, like a $dbh

=cut

requires qw/jcom_get_dbh/;

1;
