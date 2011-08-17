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
    },
    add_to_cleanup      => [ 'JCOM-BM-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
