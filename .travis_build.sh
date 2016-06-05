#! /usr/bin/env bash
if [[ "$TRAVIS_OS_NAME" != "osx" ]]; then exit ; fi

cmake --version
exit

rm  -rf .travis_build.dir
mkdir   .travis_build.dir
cd      .travis_build.dir
cmake   ../ -DINSTALL_PREFIX=$HOME/noinst -DBUILD_TYPE=Release
make
exit