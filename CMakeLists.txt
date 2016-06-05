#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Global settings
#
cmake_minimum_required( VERSION 2.8 )

#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   check for an in-source build
#   and make sure the user doesn't play dirty with symlinks
#
#   You will still have to manually clean up a few files
#   if You accidentally try an in-source build:
#   file 'CMakeCache.txt' and directory 'CMakeFiles'
#
set( CMAKE_DISABLE_IN_SOURCE_BUILD ON )
set( CMAKE_DISABLE_SOURCE_CHANGES  ON )

get_filename_component( SOURCE_DIR "${CMAKE_SOURCE_DIR}" REALPATH)
get_filename_component( BINARY_DIR "${CMAKE_BINARY_DIR}" REALPATH)

if( "${SOURCE_DIR}" STREQUAL "${BINARY_DIR}" )
    message( FATAL_ERROR "
 in-source builds are not allowed;
 remove file 'CMakeCache.txt' and directory 'CMakeFiles'
" )
endif( )

#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   the directory with the CMAKE user modules
#
if( EXISTS "${CMAKE_SOURCE_DIR}/cmake/modules" )
    set( CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/modules" )
    include( Vdump )
    include( Trace )
else()
	message( FATAL_ERROR "
Cmake modules directory not found '${CMAKE_SOURCE_DIR}/cmake/modules'
" )
endif()

#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  	install prefix, and build type
#
get_filename_component( BINARY_HLQ ${CMAKE_BINARY_DIR} DIRECTORY )
get_filename_component( BINARY_DIR ${CMAKE_BINARY_DIR} NAME )

#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if( NOT DEFINED INSTALL_PREFIX )
	string( REGEX MATCH "([^\\.]*)" INSTALL_PREFIX ${BINARY_DIR} )
	if(	BINARY_DIR STREQUAL INSTALL_PREFIX )
		message( FATAL_ERROR "
Unable to determine INSTALL_PREFIX from  ${CMAKE_BINARY_DIR}
" )
	endif()
	set( INSTALL_PREFIX  "${BINARY_HLQ}/${INSTALL_PREFIX}")
endif()
set( CMAKE_INSTALL_PREFIX  "${INSTALL_PREFIX}" CACHE PATH "" FORCE )

#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if( NOT DEFINED BUILD_TYPE )
	string( REGEX MATCH "([^.]*\$)" BUILD_TYPE ${BINARY_DIR} )
	if(	BINARY_DIR STREQUAL BUILD_TYPE )
		message( FATAL_ERROR "
Unable to determine CMAKE_BUILD_TYPE from  ${CMAKE_BINARY_DIR}
" )
	endif()
endif()

include( CapitalizeWord )
Capitalize_Word( ${BUILD_TYPE} BUILD_TYPE )
if( NOT BUILD_TYPE MATCHES "Release" AND
    NOT BUILD_TYPE MATCHES "Debug" )
	message( FATAL_ERROR "
Invalid Release/Debug BUILD_TYPE ${BUILD_TYPE}
" )
endif()
set( CMAKE_BUILD_TYPE  "${BUILD_TYPE}" CACHE PATH "" FORCE )


#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   define the project
#
project( decNumber VERSION 3.6.8 )

#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  	revision information
#
find_package( Git )
if( GIT_FOUND AND EXISTS ${CMAKE_SOURCE_DIR}/.git )

	include( GIT_Revision )
	message( "@@ Building decNumber revision ${GIT_WC_REVISION}" )
endif()

#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  	headers
#
include( CheckIncludeFile )
include( CheckHeader )
check_header( stdbool.h )
check_header( stdint.h )

#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  	CFLAGS
#
if( WIN32 )

else()
    set( CMAKE_C_FLAGS_DEBUG    "-g -g3 -ggdb3"
        CACHE STRING "" FORCE )
    set( CMAKE_C_FLAGS_RELEASE  "-g -O2"
        CACHE STRING "" FORCE )

endif()

#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  	CDEFS
#
if( WIN32 )
    set( CDEFS_DEBUG            "/D HAVE_PLATFORM_H /D DEBUG" )
    set( CDEFS_RELEASE          "/D HAVE_PLATFORM_H /D NDEBUG" )

else()
    set( CDEFS_DEBUG            "-D HAVE_PLATFORM_H -D DEBUG" )
    set( CDEFS_RELEASE          "-D HAVE_PLATFORM_H -D NDEBUG" )

endif()

set( CMAKE_C_FLAGS_DEBUG    "${CMAKE_C_FLAGS_DEBUG}   ${CDEFS_DEBUG}" )
set( CMAKE_C_FLAGS_RELEASE  "${CMAKE_C_FLAGS_RELEASE} ${CDEFS_RELEASE}" )

# 	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   generate platform.h
#
if( EXISTS ${CMAKE_SOURCE_DIR}/platform.h.in.${CMAKE_SYSTEM_NAME} )
	configure_file( ${CMAKE_SOURCE_DIR}/platform.h.in.${CMAKE_SYSTEM_NAME}
    	            ${CMAKE_BINARY_DIR}/platform.h )
elseif( EXISTS ${CMAKE_SOURCE_DIR}/platform.h.in )
	configure_file( ${CMAKE_SOURCE_DIR}/platform.h.in
    	            ${CMAKE_BINARY_DIR}/platform.h )
else()
	message( FATAL_ERROR "** Unable to find platform.h.in" )
endif()

# 	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   generate stdbool.h
#
if( NOT HAVE_STDBOOL_H )
    if( EXISTS ${CMAKE_SOURCE_DIR}/stdbool.h.in )
	    configure_file( ${CMAKE_SOURCE_DIR}/stdbool.h.in
    	                ${CMAKE_BINARY_DIR}/stdbool.h )
    else()

    endif()
endif()

# 	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   generate stdint.h
#
if( NOT HAVE_STDINT_H )
    if( EXISTS ${CMAKE_SOURCE_DIR}/stdint.h.in )
	    configure_file( ${CMAKE_SOURCE_DIR}/stdint.h.in
    	                ${CMAKE_BINARY_DIR}/stdint.h )
    else()

    endif()
endif()

# 	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   decNumber.pc
#
if(     EXISTS ${CMAKE_SOURCE_DIR}/decNumber.pc.in )
	configure_file( ${CMAKE_SOURCE_DIR}/decNumber.pc.in
    	            ${CMAKE_BINARY_DIR}/decNumber.pc @ONLY )
    install(    FILES ${CMAKE_BINARY_DIR}/decNumber.pc
                DESTINATION lib/pkgconfig )
else()
        message( "@@ will not install 'decNumber.pc' " )
endif()

# 	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   include directories
#
include_directories(    BEFORE
                    ${CMAKE_BINARY_DIR}
                    ${CMAKE_SOURCE_DIR}/include
                    )

# 	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   the public headers
file( GLOB public_headers
        RELATIVE "${CMAKE_SOURCE_DIR}" "include/*.h" )

set(    public_headers
        include/decimal128.h
        include/decimal32.h
        include/decimal64.h
        include/decPacked.h
        include/decNumber.h
        include/decContext.h
        include/decQuad.h
        )
list( SORT public_headers )

# 	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   the sources
#

# 	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   decNumber
set(    _l
        decContext.c
        decDouble.c
        decNumber.c
        decPacked.c
        decQuad.c
        decSingle.c
        decimal128.c
        decimal32.c
        decimal64.c
    )
list( SORT _l )
set(    decNumber_SRCS "" )
foreach( _s IN LISTS _l )
    list(   APPEND
            decNumber_SRCS
            source/${_s} )
endforeach()

# 	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   the static library
add_library( decNumber        STATIC ${decNumber_SRCS} )
set_target_properties(  decNumber PROPERTIES
						OUTPUT_NAME decNumber
						PUBLIC_HEADER "${public_headers}" )
install( TARGETS decNumber
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
        PUBLIC_HEADER DESTINATION include)

# 	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   the shared library
if( SHARED_LIBRARY )
add_library( decNumber_shared SHARED ${decNumber_SRCS} )
set_target_properties(  decNumber_shared PROPERTIES
						OUTPUT_NAME decNumber
                        PUBLIC_HEADER "${public_headers}" )

install( TARGETS decNumber_shared
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
        PUBLIC_HEADER DESTINATION include)
endif()

get_filename_component( CURRENT_LIST_FILE "${CMAKE_CURRENT_LIST_FILE}" NAME)
Vdump( "${CURRENT_LIST_FILE}" "${CMAKE_CURRENT_LIST_LINE}" )
