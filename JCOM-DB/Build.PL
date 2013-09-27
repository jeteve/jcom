use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'JCOM::DB',
    license             => 'perl',
    dist_author         => q{Jerome Eteve <jerome@eteve.net>},
    dist_version_from   => 'lib/JCOM/DB.pm',
    requires => {
	Moose => '1.23'
    },
    build_requires => {
        'Test::More' => 0,
	'Test::Exception' => 0,
	'DBI' => 0,
	'DBD::Pg' => 0,
	'DBIx::Class' => 0,
        'Digest::SHA' => 5.61,
	'Crypt::OpenPGP' => 0,
    },
    add_to_cleanup      => [ 'JCOM-DB-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
