use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'JCOM::BM',
    license             => 'perl',
    dist_author         => q{Jerome Eteve <jerome.eteve@gmail.com>},
    dist_version_from   => 'lib/JCOM/BM.pm',
    build_requires => {
        'Test::More' => 0,
	'Moose' => 0,
        'DBIx::Class::Schema::Loader' => 0,
	'Module::Pluggable::Object' => 0,
	'DBIx::Class' => 0,
        'Test::Fatal' => 0.008
    },
    add_to_cleanup      => [ 'JCOM-BM-*' ],
    #create_makefile_pl => 'traditional',
);

$builder->create_build_script();
