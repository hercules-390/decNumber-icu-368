#------------------------------------------------------------------------------
#   Global settings
#------------------------------------------------------------------------------

cmake_minimum_required( VERSION 3.2 )

cmake_policy( SET CMP0048 NEW )

#------------------------------------------------------------------------------
#   Load some handy CMake modules
#------------------------------------------------------------------------------

if( NOT EXISTS "${CMAKE_SOURCE_DIR}/cmake/modules" )
    message( FATAL_ERROR "CMake modules directory not found! ${CMAKE_SOURCE_DIR}/cmake/modules" )
else()

    set( CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/modules" )

    include( Vdump )
    include( Trace )

endif()

#------------------------------------------------------------------------------
#   Parse the build directory and set needed variables.
#------------------------------------------------------------------------------

set( TRAVIS $ENV{TRAVIS} )

if( NOT TRAVIS )

    message( "Local build" )

    include( ParseBinaryDir )
    ParseBinaryDir()

else( NOT TRAVIS )

    message( "Remote build ( Travis )" )

endif( NOT TRAVIS )


#------------------------------------------------------------------------------
#   Define the project
#------------------------------------------------------------------------------

project( decNumber VERSION 3.6.8 )

set( PROJECT_DESCRIPTION
     "ANSI C General Decimal Arithmetic Library"
     CACHE PATH "Project description" FORCE )


#------------------------------------------------------------------------------
#   Retrieve Git repository revision information
#------------------------------------------------------------------------------

find_package( Git )

if( GIT_FOUND AND EXISTS ${CMAKE_SOURCE_DIR}/.git )
    include( GIT_Revision )
    message( "Building ${CMAKE_PROJECT_NAME} revision ${GIT_WC_REVISION}" )
endif()


#------------------------------------------------------------------------------
#   Construct a list of this project's public headers
#------------------------------------------------------------------------------

#  PROGRAMMING NOTE: do NOT use GLOB to collect a list of source files from
#  your source tree because, if no "CMakeLists.txt" file changes when a file
#  is added or removed from your project, then the previously generated build
#  system will never know to ask CMake to regenerate itself to reflect the
#  newly added/removed files(s).

set( PUBLIC_HEADERS

    include/decimal128.h
    include/decimal32.h
    include/decimal64.h
    include/decPacked.h
    include/decNumber.h
    include/decContext.h
    include/decQuad.h
)
list( SORT PUBLIC_HEADERS )


#------------------------------------------------------------------------------
#   Construct a list of this project's source files
#------------------------------------------------------------------------------

#  PROGRAMMING NOTE: do NOT use GLOB to collect a list of source files from
#  your source tree because, if no "CMakeLists.txt" file changes when a file
#  is added or removed from your project, then the previously generated build
#  system will never know to ask CMake to regenerate itself to reflect the
#  newly added/removed files(s).

set( ${PROJECT_NAME}_SRCS

     source/decContext.c
     source/decDouble.c
     source/decNumber.c
     source/decPacked.c
     source/decQuad.c
     source/decSingle.c
     source/decimal128.c
     source/decimal32.c
     source/decimal64.c
)
list( SORT ${PROJECT_NAME}_SRCS )


#------------------------------------------------------------------------------
#   Required headers
#------------------------------------------------------------------------------

include( CheckIncludeFile )
include( CheckHeader )

check_header( stdbool.h )       # defines HAVE_STDBOOL_H
check_header( stdint.h )        # defines HAVE_STDINT_H


#------------------------------------------------------------------------------
#   Always generate the platform.h header
#------------------------------------------------------------------------------

if( NOT EXISTS ${CMAKE_SOURCE_DIR}/platform.h.in )
    message( FATAL_ERROR "Unable to find platform.h.in!" )
else()
    configure_file( ${CMAKE_SOURCE_DIR}/platform.h.in
                    ${CMAKE_BINARY_DIR}/platform.h )
endif()


#------------------------------------------------------------------------------
#   Update the INCLUDE directories search order
#------------------------------------------------------------------------------

include_directories( BEFORE ${CMAKE_BINARY_DIR} ${CMAKE_SOURCE_DIR}/include )


#------------------------------------------------------------------------------
#   Adjust needed compile flags for this project/package
#------------------------------------------------------------------------------

if( IS_BIG_ENDIAN )
  set( PKG_C_FLAGS "${PKG_C_FLAGS} -D DECLITEND=0" )
else()
  set( PKG_C_FLAGS "${PKG_C_FLAGS} -D DECLITEND=1" )
endif()
set(   PKG_C_FLAGS "${PKG_C_FLAGS} -D DECPRINT=0"  )

set( CMAKE_C_FLAGS_DEBUG          "${CMAKE_C_FLAGS_DEBUG}          ${PKG_C_FLAGS}" )
set( CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO} ${PKG_C_FLAGS}" )

set( CMAKE_C_FLAGS_DEBUG          "${CMAKE_C_FLAGS_DEBUG}          -D HAVE_PLATFORM_H -D DEBUG" )
set( CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO} -D HAVE_PLATFORM_H" )


#------------------------------------------------------------------------------
#   Set the build architecture      (32 bit or 64- bit)
#------------------------------------------------------------------------------

if( WIN32 )
  # (the toolchain being used (i.e. vstools.cmd 32/64) defines this on Windows)
else()
  if( BITNESS STREQUAL "32" )
    set( CMAKE_C_FLAGS_DEBUG          "${CMAKE_C_FLAGS_DEBUG}          -m32 -fPIC" )
    set( CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO} -m32 -fPIC" )
  else()
    set( CMAKE_C_FLAGS_DEBUG          "${CMAKE_C_FLAGS_DEBUG}          -m64 -fPIC" )
    set( CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO} -m64 -fPIC" )
  endif()
endif()

trace( CMAKE_C_FLAGS_DEBUG )
trace( CMAKE_C_FLAGS_RELWITHDEBINFO )


#------------------------------------------------------------------------------
#   Define the package's build and install targets
#------------------------------------------------------------------------------

if( SHARED_LIBRARY )

    add_library( ${FULLNAME}  SHARED  ${${PROJECT_NAME}_SRCS} )

    set_target_properties( ${FULLNAME} PROPERTIES
                           PUBLIC_HEADER        "${PUBLIC_HEADERS}"
                           OUTPUT_NAME           ${FULLNAME}
                           PDB_NAME              ${FULLNAME} )

    install( TARGETS ${FULLNAME}
             PUBLIC_HEADER DESTINATION include
             LIBRARY       DESTINATION lib )

else()

    add_library( ${FULLNAME}  STATIC  ${${PROJECT_NAME}_SRCS} )

    set_target_properties( ${FULLNAME} PROPERTIES
                           PUBLIC_HEADER                "${PUBLIC_HEADERS}"
                           OUTPUT_NAME                   ${FULLNAME}
                           COMPILE_PDB_NAME              ${FULLNAME} )

    install( TARGETS ${FULLNAME}
             PUBLIC_HEADER DESTINATION include
             ARCHIVE       DESTINATION lib )

endif()


#------------------------------------------------------------------------------
#   Define additional files to be installed
#------------------------------------------------------------------------------

install( FILES "ICU-license.html" DESTINATION . )
install( FILES "decnumber.pdf"    DESTINATION . )
install( FILES "readme.txt"       DESTINATION . )
install( FILES "ERRATA"           DESTINATION . )
if( WIN32 )
install( FILES "${CMAKE_BINARY_DIR}/${FULLNAME}.pdb" DESTINATION lib )
endif()


#------------------------------------------------------------------------------
#   Generate the .pc package configuration file
#------------------------------------------------------------------------------

if( NOT EXISTS ${CMAKE_SOURCE_DIR}/${CMAKE_PROJECT_NAME}.pc.in )
    message( AUTHOR_WARNING "Will not install ${CMAKE_PROJECT_NAME}.pc" )
else()

    set( PACKAGE_NAME        "${FULLNAME}" )
    set( PACKAGE_DESCRIPTION "${PROJECT_DESCRIPTION} (${BITNESS}-bit ${CONFIG})" )
    set( PACKAGE_VERSION     "${PROJECT_VERSION}"  )

    configure_file( ${CMAKE_SOURCE_DIR}/${CMAKE_PROJECT_NAME}.pc.in
                    ${CMAKE_BINARY_DIR}/${FULLNAME}.pc @ONLY )

    install( FILES  ${CMAKE_BINARY_DIR}/${FULLNAME}.pc
                     DESTINATION lib/pkgconfig )
endif()


#------------------------------------------------------------------------------
#   The CPack installers
#------------------------------------------------------------------------------

if( SHARED_LIBRARY )
    include( InstallRequiredSystemLibraries )
endif()

set( CPACK_PACKAGE_NAME                "${CMAKE_PROJECT_NAME}"  )
set( CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PROJECT_DESCRIPTION}" )
set( CPACK_PACKAGE_VERSION_MAJOR       "${CMAKE_VERSION_MAJOR}" )
set( CPACK_PACKAGE_VERSION_MINOR       "${CMAKE_VERSION_MINOR}" )
set( CPACK_PACKAGE_VERSION_PATCH       "${CMAKE_VERSION_PATCH}" )
set( CPACK_PACKAGE_DESCRIPTION_FILE    "${CMAKE_CURRENT_SOURCE_DIR}/readme.txt" )
set( CPACK_RESOURCE_FILE_LICENSE       "${CMAKE_CURRENT_SOURCE_DIR}/ICU-license.html" )

if( WIN32 )
    set( CPACK_GENERATOR "ZIP" )
else()
    set( CPACK_GENERATOR "TGZ" )
endif()

include( CPack )


#------------------------------------------------------------------------------
#   Create an uninstall target
#------------------------------------------------------------------------------

#  First, create the cmake script that will do the actual uninstall.

configure_file( "${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
                "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake" @ONLY )

#  Now simply define an uninstall target that will run the above script.

add_custom_target( uninstall
                   COMMAND ${CMAKE_COMMAND} -P
                   "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake" )


#------------------------------------------------------------------------------
#   CMake debugging: dump variables at exit
#------------------------------------------------------------------------------

get_filename_component( CURRENT_LIST_FILE "${CMAKE_CURRENT_LIST_FILE}" NAME )
vdump( "${CURRENT_LIST_FILE}" "exit" )
