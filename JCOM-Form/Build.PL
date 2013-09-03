use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'JCOM::Form',
    license             => 'perl',
    dist_author         => q{Jerome Eteve <jerome.eteve@gmail.com>},
    dist_version_from   => 'lib/JCOM/Form.pm',
    build_requires => {
        'Test::More' => 0,
        'JCOM::Sequence' => 0,
        'JCOM::KVPairs::Pure' => 0,
        'Moose' => 1.23,
        'MooseX::Clone' => 0.05,
        'DateTime::Format::ISO8601' => 0.06,
        'Mail::RFC822::Address' => 0.3,
    },
    add_to_cleanup      => [ 'JCOM-Form-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
