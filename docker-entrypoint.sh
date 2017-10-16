#!/bin/bash

set -e

cd /usr/src/perl-test-timer

if [ "$1" = 'ci' ]; then

    provewatcher --watch lib --watch t --run 'prove --lib'

elif [ "$1" = 'test' ]; then

    prove --lib --verbose

elif [ "$1" = 'authortest' ]; then

    dzil test --author

elif [ "$1" = 'shell' ]; then

    bash -il

fi

exit $?
