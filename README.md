# The decNumber C library

## Overview

The decNumber library implements the General Decimal Arithmetic Specification in ANSI C. This specification defines a decimal arithmetic which meets the requirements of commercial, financial, and human-oriented applications. It also matches the decimal arithmetic in the IEEE 754 Standard for Floating Point Arithmetic.

The library fully implements the specification, and hence supports integer, fixed-point, and floating-point decimal numbers directly, including infinite, NaN (Not a Number), and subnormal values. Both arbitrary-precision and fixed-size representations are supported.

Refer to the package's PDF file for more information.

## Library structure

The library comprises several modules (corresponding to classes in an object- oriented implementation). Each module has a header file (for example, decNumber.h ) which defines its data structure, and a source file of the same name (e.g., decNumber.c ) which implements the operations on that data structure. These correspond to the instance variables and methods of an object-oriented design.

Refer to the package's PDF file for more information.

## Relevant standards

It is intended that, where applicable, functions provided in the decNumber package follow the requirements of:

* the decimal arithmetic requirements of IEEE 754 except that:

1. the IEEE remainder operator (decNumberRemainderNear) is restricted to those values where the intermediate integer can be represented in the current precision, because the conventional implementation of this operator would be very long-running for the range of numbers supported (up to +/- 10**1,000,000,000).

2. the mathematical functions in the decNumber module do not, in general, correspond to the recommended functions in IEEE 754 with the same or similar names; in particular, the power function has some different special cases, and most of the functions may be up to one unit wrong in the last place (note, however, that the squareroot function is correctly rounded)

* the floating-point decimal arithmetic defined in ANSI X3.274-1996 (including errata through 2001); note that this applies to functions in the decNumber module only, with appropriate context.

Please advise the author of any discrepancies with these standards.

Refer to the package's PDF file for more information.

# ICU License - ICU 1.8.1 and later

COPYRIGHT AND PERMISSION NOTICE

Copyright (c) 1995-2005 International Business Machines Corporation and others. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, provided that the above copyright notice(s) and this permission notice appear in all copies of the Software and that both the above copyright notice(s) and this permission notice appear in supporting documentation.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT OF THIRD PARTY RIGHTS. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR HOLDERS INCLUDED IN THIS NOTICE BE LIABLE FOR ANY CLAIM, OR ANY SPECIAL INDIRECT OR CONSEQUENTIAL DAMAGES, OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

Except as contained in this notice, the name of a copyright holder shall not be used in advertising or otherwise to promote the sale, use or other dealings in this Software without prior written authorization of the copyright holder.

----
All trademarks and registered trademarks mentioned herein are the property of their respective owners.

## BUILD INSTRUCTIONS

This package is built using CMake.

CMake is an open-source, cross-platform family of tools designed to build, test and package software. CMake is used to control the software compilation process using simple platform and compiler independent configuration files, and generate native makefiles and workspaces that can be used in the compiler environment of your choice.

If you are already familiar with GNU autoconf tools, CMake basically replaces the "autogen.sh" and "configure" steps with a portable, platform independent way of creating makefiles that can be used to build your project/package with. 

CMake can be downloaded and installed from:

  [https://cmake.org/](https://cmake.org/)

## DECNUMBER

The decNumber project is hosted on GitHub at the following URL:


  [https://github.com/hercules-390/decNumber-icu-368.git](https://github.com/hercules-390/decNumber-icu-368.git)


You can either clone the git repository (recommended) or download the source code .zip file from github.  (click the green "Clone or download" button)

Once downloaded, create a build directory (outside the project directory where the build will take place) called:


    xxxxxxxxAA.yyyyyyy


where `xxxxxxxx` is the name of the project/package (e.g. "decNumber"), `AA` is the build architecture (`32` or `64`) and `yyyyyyy` is the configuration type (`Debug` or `Release`):


```
    mkdir  decNumber32.Debug
    mkdir  decNumber32.Release
    mkdir  decNumber64.Debug
    mkdir  decNumber64.Release
```


On Windows, `xxxxxxxxAA` will be used for the `INSTALL_PREFIX` (the name of the directory where the package will be installed to (target of make install). On Linux, the default `INSTALL_PREFIX` is `/usr/local`.  Either can be overridden by specifying the `-D INSTALL_PREFIX=instdir` option on your cmake command.

Once the binary/build directory is created, to build and install the package into the specified installation directory, simply use the commands:


  (Windows)

```
    > mkdir <build-dir>
    > cd <build-dir>
    > vstools [32|64]
    > cmake -G "NMake Makefiles" srcdir
    > nmake
    > nmake install
```


  (Linux)

```
    $ mkdir <build-dir>
    $ cd <build-dir>
    $ cmake srcdir
    $ make
    # sudo make install
```


Where `srcdir` is the package's source (repository) directory, where the `CMakeLists.txt` file exists.

The `vstools.cmd` batch file (Windows only) initializes the proper Microsoft Visual C/C++ build environment for the chosen build architecture (32 bit or 64 bit) and must be issued before the cmake and nmake commands.

To override the default installation directory use the `-D INSTALL_PREFIX=xxx` cmake option:


  (Windows)

    > cmake -G "NMake Makefiles"  -D INSTALL_PREFIX=dirpath  srcdir


  (Linux)

    $ cmake  -D INSTALL_PREFIX=dirpath  srcdir


Surround `INSTALL_PREFIX=dirpath` with double quotes if it contains blanks.

## CLANG

To build on Linux platforms using clang instead of gcc, simply export the `CC` and `CXX` flags before invoking CMake:


```
    $ export CC=clang
    $ export CXX=clang++
    $ cmake srcdir
```


If clang/clang++ is not in your `$PATH`, then you will need to specify its full path in the CC/CXX export commands.

## BUILD.CMD

On Windows, to make things _really simple_, you can instead use the provided `build.cmd` batch file  which performs the complete build for you automatically by creating the build directory and automatically invoking each command:


    build  -i srcdir


Enter `build /?` or `build --help` for more information.

## BUILD

On Linux, to make things _really simple_, you can instead use the provided `build` bash script which performs the complete build for you automatically by creating the build directory and automatically invoking each command:


    build  -i srcdir


Enter `build -h` or `build --help` for more information.
