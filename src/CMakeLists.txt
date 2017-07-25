cmake_minimum_required(VERSION 2.8.12)
project(HDF5test Fortran C CXX)


include(ExternalProject)

#
# If the user specifies -DCMAKE_BUILD_TYPE on the command line, take their definition
# and dump it in the cache along with proper documentation, otherwise set 
#CMAKE_BUILD_TYPE
# to Debug prior to calling PROJECT() 
#
IF(DEFINED CMAKE_BUILD_TYPE)
    SET(CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE} CACHE STRING "Choose the type of build, options are: None(CMAKE_CXX_FLAGS or CMAKE_C_FLAGS used) Debug Release RelWithDebInfo MinSizeRel.")
ELSE()
    SET(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build, options are: None(CMAKE_CXX_FLAGS or CMAKE_C_FLAGS used) Debug Release RelWithDebInfo MinSizeRel.")
ENDIF()



   # location of 3rd party builds
set (3rd_party_BUILD_DIR            "${CMAKE_CURRENT_BINARY_DIR}/3rd_party")
set (3rd_party_LIB_DIR              "${3rd_party_BUILD_DIR}/lib"           )
set (3rd_party_BIN_DIR              "${3rd_party_BUILD_DIR}/bin"           )
set (3rd_party_INCLUDE_DIR          "${3rd_party_BUILD_DIR}/include"       )
set (3rd_party_DATA_DIR             "${3rd_party_BUILD_DIR}/data"          )
set (3rd_party_Fortran_MODULE_DIR   "${3rd_party_BUILD_DIR}/Fortran_Module")


# Set library type
#set (LIB_TYPE STATIC)
set (LIB_TYPE SHARED)
string(TOLOWER ${LIB_TYPE} SEARCH_TYPE)         # make lower case and store as SEARCH_TYPE.  This is used for finding the HDF5 libraries to link

#### Check if we have HDF5 already
#find_package ( HDF5_fortran QUIET)
if ( NOT HDF5_FOUND )
    message ( STATUS "HDF5 not found. Building from source...")
    set ( BUILD_HDF5 TRUE )
else()
    set ( BUILD_HDF5 FALSE )
endif()


option (HDF5_COMPRESSION "Enable compression in HDF5." ON)
mark_as_advanced (HDF5_COMPRESSION)



   # If we are going to use HDF5, include the following
if ( BUILD_HDF5 )
 
      # If we are going to use ZLib, first look for it
   if (HDF5_COMPRESSION)

#FIXME: not sure what I did, but cannot compile with system zlib anymore on the mac....????
      if (NOT APPLE)
         find_package(ZLIB)
      endif()
      if ( NOT ZLIB_FOUND )
         message ( STATUS "ZLIB not found.  Building from source..." )
         set ( BUILD_ZLIB TRUE )
      else()
         set ( BUILD_ZLIB FALSE )
      endif()
   endif()

      # Now we can either have the HDF5 build system create this, or mamnually do it.  Trying HDF5 build system.


     # The included script needs these defined:
      #     3rd_party_BUILD_DIR         
      #     3rd_party_LIB_DIR           
      #     3rd_party_BIN_DIR           
      #     3rd_party_Fortran_MODULE_DIR
      # and will return these for linking
      #     HDF5_LINK_DIRECTORIES
      #     HDF5_INCLUDE_PATH 
   include ( external/Build_HDF5_Setup.cmake )
endif()




# Now add subdirectories
add_subdirectory (TestProg)



##print out all variables
#message(STATUS "----------------------------------------------------------")
#get_cmake_property(_variableNames VARIABLES)
#foreach (_variableName ${_variableNames})
#   message(STATUS "${_variableName}=${${_variableName}}")
#endforeach()

