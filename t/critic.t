# Courtesy of Jeffrey Ryan Thalhammer
# http://search.cpan.org/~thaljef/Test-Perl-Critic/lib/Test/Perl/Critic.pm

use Test::Perl::Critic ( -severity => 5 );
all_critic_ok();

__END__

=pod

=head1 NAME

critic.t - a unit test from Test::Perl::Critic

=head1 DESCRIPTION

This test checks your code against Perl::Critic, which is a implementation of
a subset of the Perl Best Practices.

It's severity can be controlled using the severity parameter in the use
statement. 1 being the lowest and 5 being the highests.

Setting the severity lower, indicates level of strictness

Over the following range:

gentle, stern, harsh, cruel, brutal

So gentle would only catch severity 5 issues.

Since this tests tests all packages in your distribution, perlcritic
commandline tool can be used in addition.

L<perlcritic>

=cut
