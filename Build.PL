use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Test::Timer',
    license             => 'artistic',
    dist_author         => 'jonasbn <jonasbn@cpan.org>',
    dist_version_from   => 'lib/Test/Timer.pm',
    requires => {
        'Test::Builder' => 0, #core
		'Test::Builder::Module' => 0, #core
        'Benchmark'     => 0, #core
        'Carp'          => 0, #core
        'Error'         => 0, #core
        'Test::Tester'  => 0, 
    },
    build_requires => {
        'Test::More'          => 0, #core
        'Test::Exception'     => 0,
        'File::Spec'          => 0,
        'English'             => 0,
    },
    add_to_cleanup     => [ 'Test-Timer-*' ],
	create_makefile_pl => 'traditional',
    meta_merge => {
        resources => {
            homepage => 'http://logiclab.jira.com/wiki/display/TESTT/Home',
            bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Test-Timer',
            repository => 'https://github.com/jonasbn/testt',
            ProjectChangelog =>
                'http://logiclab.jira.com/browse/TESTT#selectedTab=com.atlassian.jira.plugin.system.project%3Achangelog-panel',
            ProjectSite => 'http://logicLAB.jira.com/browse/TESTT',
            ProjectWiki => 'http://logiclab.jira.com/wiki/display/TESTT/Home',
        }
    },
);

$builder->create_build_script();
