# Contributing

These are the guidelines for contributing to this repository.

Please see the [Code of Conduct](https://github.com/jonasbn/perl-test-timer/CODE_OF_CONDUCT.md).

## Issues

File an issue if you think you've found a [bug](https://en.wikipedia.org/wiki/Software_bug). Please describe the following:

1. What version of the involved component was used
2. What environment was the component used in (OS, Perl version etc.)
3. What was expected
4. What actually occurred
5. What can be done to reproduce the issue

Please use the [issue template](https://github.com/jonasbn/perl-test-timer/.github/ISSUE_TEMPLATE.md).

## Patches

Patches for fixes, features, and improvements are accepted via pull requests.

Pull requests should be based on the **master** branch, unless you want to contribute to an active branch for a specific topic.

Please use the [PR template](https://github.com/jonasbn/perl-test-timer/.github/PULL_REQUEST_TEMPLATE.md).

Coding guidelines are basic, please use:

- [EditorConfig](http://editorconfig.org/) configuration included in repository as `.editorconfig`
- [PerlTidy](http://perltidy.sourceforge.net/) configuration included in repository as `.perltidyrc`

For other coding conventions please see the Perl::Critic configuration in: `t/perlcriticrc`.

Do note that the repository uses [Probot](https://probot.github.io/), so if you write comments formatted as:

```perl
# @todo You have an in issue in your heading
# @body But a descriptive body
```

The [`TODO bot`](https://probot.github.io/apps/todo/) will the create a GitHub issue automatically upon `push` to the repository.

All contributions are welcome and most will be accepted.

## Licensing and Copyright

Please note that accepted contributions are included in the repository and hence under the same license as the repository contributed to.

## Acknowledgement and Mentions

Please note that all contributions are acknowledged and contributors are mentioned by available identification, if you as a contributor would prefer not to be mentioned explicitly please indicate this, PR mechanics cannot be ignored.

If you prefer to be mentioned in a specific manner other than by GitHub handle or similar please indicate this and accommodation will be attempted, limited only be the means available.
