#! /usr/bin/env bash
rm  -rf .travis_build.dir
mkdir   .travis_build.dir
cd      .travis_build.dir
cmake   ../ -DINSTALL_PREFIX=$HOME/noinst -DBUILD_TYPE=Release
make