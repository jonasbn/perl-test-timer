use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Test::Timer',
    license             => 'artistic',
    dist_author         => 'jonasbn <jonasbn@cpan.org>',
    dist_version_from   => 'lib/Test/Timer.pm',
    requires => {
        'Exporter'      => 0, #core
        'Test::Builder' => 0, #core
        'Benchmark'     => 0, #core
        'Carp'          => 0, #core
        'Error'         => 0, #core
        'Test::Tester'  => 0, 
    },
    build_requires => {
        'Test::More'          => 0, #core
        'Test::Pod::Coverage' => 0,
        'Test::Pod'           => 0,
        'Test::Kwalitee'      => 0,
        'Test::Perl::Critic'  => 0,
        'Test::Exception'     => 0,
        'File::Spec'          => 0,
        'English'             => 0,
    },
    add_to_cleanup      => [ 'Test-Timer-*' ],
	create_makefile_pl => 'traditional',
);

$builder->create_build_script();
