# Contributing

These are the guidelines for contributing to this repository.

## Issues

File an issue if you think you've found a [bug](https://en.wikipedia.org/wiki/Software_bug). Please describe the following:

1. What version of the involved component was used
2. What environment was the component used in (OS, Perl version etc.)
3. What was expected
4. What actually occurred
5. What had to be done to reproduce the issue

Please use the [issue template](https://github.com/jonasbn/perl-test-timer/blob/master/.github/ISSUE_TEMPLATE.md).

## Patches

Patches for fixes, features, and improvements are accepted via pull requests.

Pull requests should be based on the **master** branch, unless you want to contribute to an active branch for a specific topic.

Please use the [PR template](https://github.com/jonasbn/perl-test-timer/blob/master/.github/PULL_REQUEST_TEMPLATE.md).

Coding guidelines are basic, please use:

- [EditorConfig](http://editorconfig.org/) (configuration included in repository as `.editorconfig`)
- [PerlTidy](http://perltidy.sourceforge.net/) (can be downloaded from [Gist](https://gist.github.com/jonasbn/d6c6f1fc5d075e2f9b27))

```
# REF: http://www.perlmonks.org/?node_id=485885
# PBP .perltidyrc file

-l=78   # Max line width is 78 cols
-i=4    # Indent level is 4 cols
-ci=4   # Continuation indent is 4 cols
-st     # Output to STDOUT
-se     # Errors to STDERR
-vt=2   # Maximal vertical tightness
-cti=0  # No extra indentation for closing brackets
-pt=1   # Medium parenthesis tightness
-bt=1   # Medium brace tightness
-sbt=1  # Medium square bracket tightness
-bbt=1  # Medium block brace tightness
-nsfs   # No space before semicolons
-nolq   # Don't outdent long quoted strings
-wbb="% + - * / x != == >= <= =~ < > | & **= += *= &= <<= &&= -= /= |= >>= ||= .= %= ^= x="
        # Break before all operators
```

For other coding conventions please see the Perl::Critic configuration in: `t/perlcriticrc`.

And if you are really adventurous, you are most welcome to read [my general coding conventions](https://gist.github.com/jonasbn/c2f703c68340384cfc61bb9c38adb2ff) (WIP).

All contributions are welcome and most will be accepted.

## Licensing and Copyright

Please note that accepted contributions are included in the repository and hence under the same license as the repository contributed to.
