use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Test::Timer',
    license             => 'perl',
    dist_author         => 'jonasbn <jonasbn@cpan.org>',
    dist_version_from   => 'lib/Test/Timer.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Test-Timer-*' ],
);

$builder->create_build_script();
