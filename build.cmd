@if defined TRACEON (@echo on) else (@echo off)

  REM  If this batch file works, then it was written by Fish.
  REM  If it doesn't then I don't know who the heck wrote it.

  setlocal
  pushd .

  set "_versnum=1.0"
  set "_versdate=June 26, 2016"

  goto :init

::-----------------------------------------------------------------------------
::                              BUILD.CMD
::-----------------------------------------------------------------------------
:help

  echo.
  echo     NAME
  echo.
  echo         %nx0%   --   Builds the external Hercules package
  echo.
  echo     SYNOPSIS
  echo.
  echo         %nx0%   [ { -i   ^| --pkgdir    }    pkgdir     ]             \
  echo                     [ { -n   ^| --pkgname   }   pkgname     ]             \
  echo                     [ { -o   ^| --install   } [ instdir  ]  ]             \
  echo                       [ -u   ^| --uninstall ]                             \
  echo                     [ { -a   ^| --arch      }  64      ^| 32    ^| BOTH  ]  \
  echo                     [ { -c   ^| --config    }  Release ^| Debug ^| BOTH  ]  \
  echo                       [ -all ^| --all ]                                   \
  echo                       [ -r   ^| --rebuild ]
  echo.
  echo     ARGUMENTS
  echo.
  echo         pkgdir     The package directory where the CMakeLists.txt
  echo                    file exists.  This is usually the name of the
  echo                    package's primary source directory ^(i.e. its
  echo                    repository directory^).  The default when not
  echo                    specified is the same one as where %nx0%
  echo                    is running from.
  echo.
  echo         pkgname    The single word alphanumeric package name.  The
  echo                    default if not specified is derived from the last
  echo                    directory component of pkgdir.  The value "." may
  echo                    be specified to derive from the last component of
  echo                    the current directory instead.
  echo.
  echo         install    Install the package into the specified directory.
  echo                    If not specified the package won't be installed.
  echo.
  echo         instdir    The package installation directory.  If specified
  echo                    the given directory MUST exist.  If not specified
  echo                    the package's CMake default is used instead.
  echo.
  echo         uninstall  Uninstalls the previously installed package.
  echo.
  echo     OPTIONS
  echo.
  echo         arch       The build architecture.   The default is 64.
  echo.
  echo         config     The build configuration.  The default is Release.
  echo.
  echo         all        Shorthand for "--arch BOTH --config BOTH".
  echo.
  echo         rebuild    Forces a complete reconfigure and rebuild.
  echo.
  echo     NOTES
  echo.
  echo         %nx0% first creates a build directory in the current directory,
  echo         switches to the build directory, runs vstools.cmd ^(to initialize
  echo         the proper build environment^) followed by the cmake command ^(to
  echo         create the makefile^) and then finally runs nmake and nmake install
  echo         commands to actually build and install the package for the specified
  echo         architecture and configuration combination.  The name of the binary
  echo         build directory is derived from the package's name and the specified
  echo         architetcure/configuration combination.  The vstools.cmd batch file
  echo         is presumed to exist in the same directory as %nx0%.
  echo.
  echo     EXIT STATUS
  echo.
  echo         0      All requested actions successfully completed.
  echo         n      One or more actions failed w/error^(s^) where 'n' is the
  echo                highest return code detected.
  echo.
  echo     AUTHOR
  echo.
  echo         "Fish"  ^(David B. Trout^)
  echo.
  echo     VERSION
  echo.
  echo         %_versnum%     ^(%_versdate%^)

  call :setrc1
  %exit%

::-----------------------------------------------------------------------------
::                               INIT
::-----------------------------------------------------------------------------
:init

  @REM Define some constants...

  set "TRACE=if defined DEBUG echo"
  set "return=goto :EOF"
  set "break=goto :break"
  set "skip=goto :skip"
  set "exit=goto :exit"
  set "help=goto :help"

  set "numbers=0123456789"
  set "letters=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

  set /a "rc=0"
  set /a "maxrc=0"

  set "n0=%~n0"               && @REM (our name only)
  set "nx0=%~nx0"             && @REM (our name and extension)
  set "dp0=%~dp0"             && @REM (our own drive and path only)
  set "dp0=%dp0:~0,-1%"       && @REM (remove trailing backslash)
  set "nx0_cmdline=%0 %*"     && @REM (save original cmdline used)

  @REM Define external tools

  set "cmake=cmake.exe"
  set "vstools=%dp0%\vstools.cmd"

  @REM  Options as listed in help...

  set "pkgdir="
  set "pkgname="
  set "install="
  set "instdir="
  set "uninstall="
  set "arch="
  set "config="
  set "rebuild="
  set "bldall="

  @REM  Default values...

  set "def_pkgdir=%dp0%"
  set "def_instdir=dummy-non-empty-value"
  set "def_arch=64"
  set "def_config=Release"

  goto :parse_args

::-----------------------------------------------------------------------------
::                             load_tools
::-----------------------------------------------------------------------------
:load_tools

  call :fullpath "%cmake%"
  if not defined # (
    echo ERROR: %cmake% not found. 1>&2
    set "cmake="
    call :setrc1
  )

  call :fullpath "%vstools%"  vstools
  if not defined # (
    echo ERROR: %vstools% not found. 1>&2
    set "vstools="
    call :setrc1
  )

  %return%

::-----------------------------------------------------------------------------
::                             fullpath
::-----------------------------------------------------------------------------
:fullpath

  set "@=%path%"
  set "path=.;%path%"
  set "#=%~$PATH:1"
  set "path=%@%"
  if defined # (
    if not "%~2" == "" (
      set "%~2=%#%"
    )
  )
  %return%

::-----------------------------------------------------------------------------
::                              isdir
::-----------------------------------------------------------------------------
:isdir

  if not exist "%~1" (
    set "isdir="
    %return%
  )
  set "isdir=%~a1"
  if defined isdir (
    if /i not "%isdir:~0,1%" == "d" set "isdir="
  )
  %return%

::-----------------------------------------------------------------------------
::                              tempfn
::-----------------------------------------------------------------------------
:tempfn

  setlocal
  set "var_name=%~1"
  set "file_ext=%~2"
  set "%var_name%="
  set "@="
  for /f "delims=/ tokens=1-3" %%a in ("%date:~4%") do (
    for /f "delims=:. tokens=1-4" %%d in ("%time: =0%") do (
      set "@=TMP%%c%%a%%b%%d%%e%%f%%g%random%%file_ext%"
    )
  )
  endlocal && set "%var_name%=%@%"
  %return%

::-----------------------------------------------------------------------------
::                              dirname
::-----------------------------------------------------------------------------
:dirname

  set "dirname=%~nx1"    && @REM (get just the final directory name component)
  %return%

::-----------------------------------------------------------------------------
::                             isalphanum
::-----------------------------------------------------------------------------
:isalphanum

  set "@=%~1"

  set "isalphanum="

  if not "%@%" == "" (
    for /f "delims=%numbers%%letters%" %%i in ("%@%/") do (
      if "%%i" == "/" set "isalphanum=1"
    )
  )

  :: (ensure first char is letter not number)

  set "@=%@:~0,1%"

  if defined isalphanum (
    for /f "delims=%letters%" %%i in ("%@%/") do (
      if not "%%i" == "/" set "isalphanum="
    )
  )

  %return%

::-----------------------------------------------------------------------------
::                           get_cache_value
::-----------------------------------------------------------------------------
:get_cache_value

  set "_cachefile=%~1"
  set "_varname=%~2"
  set "cache_value="

  for /f "tokens=*" %%a in (%_cachefile%) do (
    call :cache_stmt "%%a"
    if defined cache_value (
      %return%
    )
  )

  %return%

:cache_stmt

  set "stmt=%~1"

  for /f "tokens=1-2* delims=:=" %%a in ("%stmt%") do (
    if /i "%%a" == "%_varname%" (
      set "cache_value=%%c"
      %return%
    )
  )

  %return%

::-----------------------------------------------------------------------------
::                   ( parse_options_loop helper )
::-----------------------------------------------------------------------------
:isopt

  @REM  Examines first character of passed value to determine
  @REM  whether it's the next option or not. If it starts with
  @REM  a '/' or '-' then it's the next option. Else it's not.

  set           "isopt=%~1"
  if not defined isopt     %return%
  if "%isopt:~0,1%" == "/" %return%
  if "%isopt:~0,1%" == "-" %return%
  set "isopt="
  %return%

::-----------------------------------------------------------------------------
::                   ( parse_options_loop helper )
::-----------------------------------------------------------------------------
:parseopt

  @REM  This function expects the next two command line arguments
  @REM  %1 and %2 to be passed to it.  %1 is expected to be a true
  @REM  option (its first character should start with a / or -).
  @REM
  @REM  Both arguments are then examined and the results are placed into
  @REM  the following variables:
  @REM
  @REM    opt:        The current option as-is (e.g. "-d")
  @REM
  @REM    optname:    Just the characters following the '-' (e.g. "d")
  @REM
  @REM    optval:     The next token following the option (i.e. %2),
  @REM                but only if it's not an option itself (not isopt).
  @REM                Otherwise optval is set to empty/undefined since
  @REM                it is not actually an option value but is instead
  @REM                the next option.

  set "opt=%~1"
  set "optname=%opt:~1%"
  set "optval=%~2"
  setlocal
  call :isopt "%optval%"
  endlocal && set "#=%isopt%"
  if defined # set "optval="
  %return%

::-----------------------------------------------------------------------------
::                             parse_args
::-----------------------------------------------------------------------------
:parse_args

  set /a "rc=0"

  if /i "%~1" == "?"       %help%
  if /i "%~1" == "/?"      %help%
  if /i "%~1" == "-?"      %help%
  if /i "%~1" == "-h"      %help%
  if /i "%~1" == "--help"  %help%

  call :load_tools
  if not "%rc%" == "0" %exit%

:parse_options_loop

  if "%~1" == "" goto :options_loop_end

  @REM  Parse next option...

  set "cmdline_arg=%~1"

  call :isopt    "%~1"
  call :parseopt "%~1" "%~2"
  shift /1

  if not defined isopt (

    @REM  Must be a positional option.
    @REM  Set optname identical to opt
    @REM  and empty meaningless optval.

    set "optname=%opt%"
    set "optval="
    goto :parse_positional_arg
  )

  if /i "%optname%" == "?"   goto :parse_help_opt
  if /i "%optname%" == "h"   goto :parse_help_opt
  if /i "%optname%" == "i"   goto :parse_pkgdir_opt
  if /i "%optname%" == "n"   goto :parse_pkgname_opt
  if /i "%optname%" == "o"   goto :parse_install_opt
  if /i "%optname%" == "u"   goto :parse_uninstall_opt
  if /i "%optname%" == "a"   goto :parse_arch_opt
  if /i "%optname%" == "c"   goto :parse_config_opt
  if /i "%optname%" == "r"   goto :parse_rebuild_opt
  if /i "%optname%" == "all" goto :parse_all_opt

  @REM  Determine if "--xxxx" long option

  call :isopt "%optname%"
  if not defined isopt goto :parse_unknown_opt

  @REM  Long "--xxxxx" option parsing...
  @REM  We use %~1 here (instead of %~2)
  @REM  since shift /1 was already done.

  call :parseopt "%optname%" "%~1"

  if /i "%optname%" == "help"      goto :parse_help_opt
  if /i "%optname%" == "pkgdir"    goto :parse_pkgdir_opt
  if /i "%optname%" == "pkgname"   goto :parse_pkgname_opt
  if /i "%optname%" == "install"   goto :parse_install_opt
  if /i "%optname%" == "uninstall" goto :parse_uninstall_opt
  if /i "%optname%" == "arch"      goto :parse_arch_opt
  if /i "%optname%" == "config"    goto :parse_config_opt
  if /i "%optname%" == "rebuild"   goto :parse_rebuild_opt
  if /i "%optname%" == "all"       goto :parse_all_opt
  if /i "%optname%" == "version"   goto :parse_version_opt

  goto :parse_unknown_opt

  @REM ------------------------------------
  @REM  Options that require an argument
  @REM ------------------------------------

:parse_pkgdir_opt

  if not defined optval goto :parse_missing_optarg
  set "pkgdir=%optval%"
  shift /1
  goto :parse_options_loop

:parse_pkgname_opt

  if not defined optval goto :parse_missing_optarg
  set "pkgname=%optval%"
  shift /1
  goto :parse_options_loop

:parse_arch_opt

  if not defined optval goto :parse_missing_optarg
  set "arch=%optval%"
  shift /1
  goto :parse_options_loop

:parse_config_opt

  if not defined optval goto :parse_missing_optarg
  set "config=%optval%"
  shift /1
  goto :parse_options_loop

  @REM ------------------------------------
  @REM  Options whose argument is optional
  @REM ------------------------------------

:parse_install_opt

  set "install=1"

  if not defined optval goto :parse_options_loop
  set "instdir=%optval%"
  set "def_instdir="
  shift /1
  goto :parse_options_loop

  @REM ------------------------------------
  @REM  Options that are just switches
  @REM ------------------------------------

:parse_help_opt

  %help%
  goto :parse_options_loop

:parse_uninstall_opt

  set "uninstall=1"
  goto :parse_options_loop

:parse_rebuild_opt

  set "rebuild=1"
  goto :parse_options_loop

:parse_all_opt

  set "bldall=1"
  goto :parse_options_loop

:parse_version_opt

  echo %nx0% version %_versnum% ^(%_versdate%^) 1>&2
  call :setrc1
  goto :parse_options_loop

  @REM ------------------------------------
  @REM      Positional arguments
  @REM ------------------------------------

:parse_positional_arg

  goto :parse_unknown_arg

  @REM ------------------------------------
  @REM  Error routines
  @REM ------------------------------------

:parse_unknown_arg

  echo ERROR: Unrecognized/extraneous argument '%cmdline_arg%'. 1>&2
  call :setrc1
  goto :parse_options_loop

:parse_unknown_opt

  echo ERROR: Unknown/unsupported option '%cmdline_arg%'. 1>&2
  call :setrc1
  goto :parse_options_loop

:parse_missing_optarg

  echo ERROR: Option '%cmdline_arg%' is missing its required argument. 1>&2
  call :setrc1
  goto :parse_options_loop

:options_loop_end

  %TRACE% Debug: values after parsing:
  %TRACE%.
  %TRACE% pkgdir    = "%pkgdir%"
  %TRACE% pkgname   = "%pkgname%"
  %TRACE% install   = "%install%"
  %TRACE% instdir   = "%instdir%"
  %TRACE% uninstall = "%uninstall%"
  %TRACE% arch      = "%arch%"
  %TRACE% config    = "%config%"
  %TRACE% rebuild   = "%rebuild%"
  %TRACE% bldall    = "%bldall%"
  %TRACE%.

  if not "%rc%" == "0" %exit%
  goto :validate_args

::-----------------------------------------------------------------------------
::                            validate_args
::-----------------------------------------------------------------------------
:validate_args

  ::  Use default pkgdir if pkgdir is not defined yet

  if not defined pkgdir (
    set "pkgdir=%def_pkgdir%"
  )

  ::  Validate pkgdir

  if not exist  "%pkgdir%" (
    echo ERROR: pkgdir "%pkgdir%" not found. 1>&2
    call :setrc1
    goto :validate_pkgdir_done
  )

  call :isdir "%pkgdir%"

  if not defined isdir (
    echo ERROR: pkgdir "%pkgdir%" is not a directory. 1>&2
    call :setrc1
    goto :validate_pkgdir_done
  )

  call :fullpath "%pkgdir%"

  if not defined # (
    echo ERROR: pkgdir "%pkgdir%" not found. 1>&2
    call :setrc1
    goto :validate_pkgdir_done
  )

  set "pkgdir=%#%"

  pushd "%pkgdir%"
  call :fullpath "CMakeLists.txt"
  popd

  if not defined # (
    echo ERROR: File "CMakeLists.txt" not found in pkgdir. 1>&2
    call :setrc1
    goto :validate_pkgdir_done
  )

:validate_pkgdir_done

  ::  Validate pkgname

  if "%pkgname%" == "." (
    goto :validate_dot_pkgname
  )

  if defined pkgname (
    goto :validate_specified_pkgname
  )

  ::  Derive pkgname from pkgdir value

  call :dirname "%pkgdir%"
  set "pkgname=%dirname%"
  goto :validate_derive_pkgname

:validate_dot_pkgname

  ::  Derive pkgname from current directory name

  call :dirname "%cd%"
  set "pkgname=%dirname%"
  goto :validate_derive_pkgname

:validate_derive_pkgname

  set "_pkgname=%pkgname%"
  set "pkgname="

  ::  The following loop constructs a pkgname value
  ::  by skipping all non-alphanumeric characters
  ::  and ensuring the first character is a letter.

:validate_derive_pkgname_loop

  if not defined _pkgname (
    @REM We're done. Go validate our results.
    goto :validate_specified_pkgname
  )

  :: Grab the next character from _pgkname...

  set "@=%_pkgname:~0,1%"
  set "_pkgname=%_pkgname:~1%"
  
  for /f "delims=%numbers%%letters%" %%i in ("%@%/") do (
    if "%%i" == "/" call :validate_derive_pkgname_append
    goto :validate_derive_pkgname_loop
  )

:validate_derive_pkgname_append

  set "pkgname=%pkgname%%@%"
  %return%

:validate_specified_pkgname

  call :isalphanum "%pkgname%"
  if not defined isalphanum (
    echo ERROR: Invalid pkgname "%pkgname%". 1>&2
    call :setrc1
    goto :validate_pkgname_done
  )

  goto :validate_pkgname_done

:validate_pkgname_done

  ::  Validate instdir

  if not defined instdir (

    @REM  They didn't specify an install directory.
    @REM  Leave 'instdir' undefined so cmake uses a
    @REM  default value.  Ensure 'def_instdir' is
    @REM  NOT empty to indicate that we're using a
    @REM  default value.

    set "instdir="
    set "def_instdir=dummy-non-empty-value"
    goto :validate_instdir_done
  )

  ::  Undefine 'def_instdir' so we know
  ::  we're using their specific value
  ::  and not the default.

  set "def_instdir="  && @REM (default value NOT being used)

  :: (change all "/" to "\")
  set "instdir=%instdir:/=\%"

  :: (remove any trailing "\")
  if "%instdir:~-1%" == "\" (
    set "instdir=%instdir:~0,-1%"
  )

  call :fullpath "%instdir%"

  if not defined # (
    echo ERROR: instdir "%instdir%" not found. 1>&2
    call :setrc1
    goto :validate_instdir_done
  )

  set "instdir=%#%"

  call :isdir "%instdir%"

  if not defined isdir (
    echo ERROR: instdir "%instdir%" is not a directory. 1>&2
    call :setrc1
    goto :validate_instdir_done
  )

:validate_instdir_done

  ::  Ignore specified arch and config values if bldall was specified

  if defined bldall (
    if defined arch (
      if /i not "%arch%" == "BOTH" (
        echo WARNING: arch ignored due to 'all' option. 1>&2
      )
      set "arch="
    )
    if defined config (
      if /i not "%config%" == "BOTH" (
        echo WARNING: config ignored due to 'all' option. 1>&2
      )
      set "config="
    )
  ) else (
    if not defined arch   set "arch=%def_arch%"
    if not defined config set "config=%def_config%"
  )

  ::  Validate arch and config if not bldall

  if not defined bldall (
    if /i not "%arch%" == "32" (
      if /i not "%arch%" == "64" (
        if /i not "%arch%" == "BOTH" (
          echo ERROR: Invalid arch "%arch%" 1>&2
          call :setrc1
        )
      )
    )
    if /i not "%config%" == "Debug" (
      if /i not "%config%" == "Release" (
        if /i not "%config%" == "BOTH" (
          echo ERROR: Invalid config "%config%" 1>&2
          call :setrc1
        )
      )
    )
  )

  ::  Both 'arch' and 'config' == "BOTH" implies 'bldall'

  if /i "%arch%" == "BOTH" (
    if /i "%config%" == "BOTH" (
      set "arch="
      set "config="
      set "bldall=1"
    )
  )

  goto :validate_args_done

:validate_args_done

  %TRACE% Debug: values after validation:
  %TRACE%.
  %TRACE% pkgdir    = "%pkgdir%"
  %TRACE% pkgname   = "%pkgname%"
  %TRACE% install   = "%install%"
  %TRACE% instdir   = "%instdir%"
  %TRACE% uninstall = "%uninstall%"
  %TRACE% arch      = "%arch%"
  %TRACE% config    = "%config%"
  %TRACE% rebuild   = "%rebuild%"
  %TRACE% bldall    = "%bldall%"
  %TRACE%.

  if not "%rc%" == "0" %exit%
  goto :BEGIN

::-----------------------------------------------------------------------------
::                               BEGIN
::-----------------------------------------------------------------------------
:BEGIN

  if defined bldall (

    call :do_build "32" "Debug"   "%instdir%"
    call :do_build "32" "Release" "%instdir%"
    call :do_build "64" "Debug"   "%instdir%"
    call :do_build "64" "Release" "%instdir%"

  ) else (

    if /i "%arch%" == "BOTH" (

      call :do_build "32" "%config%" "%instdir%"
      call :do_build "64" "%config%" "%instdir%"

    ) else (

      if /i "%config%" == "BOTH" (

        call :do_build "%arch%" "Debug"   "%instdir%"
        call :do_build "%arch%" "Release" "%instdir%"

      ) else (

        call :do_build "%arch%" "%config%" "%instdir%"
      )
    )
  )

  %exit%

::-----------------------------------------------------------------------------
::                                do_build
::-----------------------------------------------------------------------------
:do_build

  setlocal

    set "arch=%~1"
    set "config=%~2"
    set "instdir=%~3"

    set "blddir=%pkgname%%arch%.%config%"
    set "cachefile=%blddir%\CMakeCache.txt"
    set "did_vstools="
    set "rc=0"

    echo cmdline = %nx0_cmdline%
    echo.
    echo Build of %arch%-bit %config% version of %pkgname% begun on %date% at %time: =0%

    ::  Create build directory

    if defined rebuild (
      if exist "%blddir%" (
        rmdir /s /q "%blddir%"
      )
    )

    if not exist "%blddir%" (
      mkdir      "%blddir%"
      set "do_cmake=1"
    ) else (
      if not exist  "%blddir%\Makefile" (
        rmdir /s /q "%blddir%"
        mkdir       "%blddir%"
        set "do_cmake=1"
      ) else (
        set "do_cmake="   &&    @REM cmake has already been done
      )
    )

    ::  Check to make sure their instdir value matches the previously
    ::  configured value. (They can't specify one instdir on one run
    ::  and then later try specifying a completely different one!)

    if defined def_instdir (    @REM Default instdir being used
      %skip%
    )
    if defined do_cmake (       @REM CMake configure will be done
      %skip%
    )

    ::  Specific instdir specified AND cmake NOT being done.

    call :get_cache_value "%cachefile%" "CMAKE_INSTALL_PREFIX"

    if /i not "%instdir%" == "%cache_value%" (
      echo.
      echo ERROR: Specified instdir does not match previously configured value. 1>&2
      call :setrc1
      echo        Use --rebuild to reconfigure if you wish to use a new value. 1>&2
    )

:skip

    ::  Do the build...

    pushd "%blddir%"

      if %rc% EQU 0 call :do_cmakefile
      if %rc% EQU 0 call :do_nmake
      if %rc% EQU 0 call :do_install
      if %rc% EQU 0 call :do_UNinstall

    popd

    ::  Display results

    if %rc% EQU 0 set "result=SUCCEEDED"
    if %rc% NEQ 0 set "result=FAILED"

    echo.
    echo Build %result% on %date% at %time: =0%
    echo.

  endlocal
  %return%

::-----------------------------------------------------------------------------
::                            do_cmakefile
::-----------------------------------------------------------------------------
:do_cmakefile

  if not defined do_cmake %return%

  echo.&& echo Configuring %pkgname%%arch%.%config% ...&& echo.

  if not defined did_vstools (
    call "%vstools%" "%arch%"
    set "did_vstools=1"
  )

  ::  If 'def_instdir' is still defined, then it means we should use the
  ::  CMake default installation directory (determine by our CMake script).
  ::  Otherwise if 'def_instdir' is undefined, it means we DON'T want to
  ::  use the CMake default but rather their specific directory instead.

  if defined def_instdir (
    @REM def_instdir is still defined; use the CMake script's default.
    set "install_prefix_opt="
  ) else (
    @REM def_instdir is UNDEFINED; use whatever directory they specified.
    set "install_prefix_opt=-D INSTALL_PREFIX="%instdir%""
  )

  :: PROGRAMMING NOTE: CMake apparently uses the 'RC' environment variable
  :: to hold the path to Microsoft's Resource Compiler (rc.exe) and becomes
  :: very upset when it doesn't find it.  Thus we undefine our existing rc
  :: variable before invoking CMake.  We will set it to its proper "return
  :: code" value again immediately after CMake finishes doing its thing.

  set "rc="     &&    @REM (allows cmake to find rc.exe)

  cmake -G "NMake Makefiles" %install_prefix_opt% "%pkgdir%"

  set "rc=%errorlevel%"
  call :update_maxrc

  if %rc% NEQ 0 (echo.&& echo ERROR: CMake has failed! rc=%rc%)

  %return%

::-----------------------------------------------------------------------------
::                            do_nmake
::-----------------------------------------------------------------------------
:do_nmake

  ::  We always do a make each time in case anything changed

  echo.&& echo Building %pkgname%%arch%.%config% ...&& echo.

  if not defined did_vstools (
    call "%vstools%" "%arch%"
    set "did_vstools=1"
  )

  nmake /nologo

  set "rc=%errorlevel%"
  call :update_maxrc

  if %rc% NEQ 0 (echo.&& echo ERROR: nmake has failed! rc=%rc%)

  %return%

::-----------------------------------------------------------------------------
::                            do_install
::-----------------------------------------------------------------------------
:do_install

  if not defined install %return%

  echo.&& echo Installing %pkgname%%arch%.%config% ...&& echo.

  if not defined did_vstools (
    call "%vstools%" "%arch%"
    set "did_vstools=1"
  )

  nmake /nologo install

  set "rc=%errorlevel%"
  call :update_maxrc

  if %rc% NEQ 0 (echo.&& echo ERROR: nmake install has failed! rc=%rc%)

  %return%

::-----------------------------------------------------------------------------
::                            do_UNinstall
::-----------------------------------------------------------------------------
:do_UNinstall

  if not defined uninstall %return%

  echo.&& echo UNinstalling %pkgname%%arch%.%config% ...&& echo.

  if not defined did_vstools (
    call "%vstools%" "%arch%"
    set "did_vstools=1"
  )

  nmake /nologo uninstall

  set "rc=%errorlevel%"
  call :update_maxrc

  if %rc% NEQ 0 (echo.&& echo ERROR: nmake uninstall has failed! rc=%rc%)

  %return%

::-----------------------------------------------------------------------------
::                              setrc1
::-----------------------------------------------------------------------------
:setrc1

  set /a "rc=1"
  call :update_maxrc
  %return%

::-----------------------------------------------------------------------------
::                           update_maxrc
::-----------------------------------------------------------------------------
:update_maxrc

  @REM maxrc remains negative once it's negative.

  if %maxrc% GEQ 0 (
    if %rc% LSS 0 (
      set /a "maxrc=%rc%"
    ) else (
      if %rc% GTR 0 (
        if %rc% GTR %maxrc% (
          set /a "maxrc=%rc%"
        )
      )
    )
  )

  %return%

::-----------------------------------------------------------------------------
::                                EXIT
::-----------------------------------------------------------------------------
:exit

  popd
  endlocal && exit /b %maxrc%

::-----------------------------------------------------------------------------
