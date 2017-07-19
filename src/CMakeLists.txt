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
set (3rd_party_Fortran_MODULE_DIR   "${3rd_party_BUILD_DIR}/Fortran_Module")


# Set library type
set (LIB_TYPE STATIC)
#set (LIB_TYPE SHARED)
string(TOLOWER ${LIB_TYPE} SEARCH_TYPE)         # make lower case and store as SEARCH_TYPE.  This is used for finding the HDF5 libraries to link

#### Check if we have HDF5 already
find_package ( HDF5_fortran QUIET)
if ( NOT HDF5_FOUND )
    message ( STATUS "HDF5 not found. Building from source...")
    set ( BUILD_HDF5 TRUE )
endif()


option (HDF5_COMPRESSION "Enable compression in HDF5." OFF)
mark_as_advanced (HDF5_COMPRESSION)




if ( BUILD_HDF5 )
   set (HDF5_EXTERNALLY_CONFIGURED 1)
   set (HDF5_EXPORTED_TARGETS "hdf5-targets")
   set (HDF5_CMAKE_Fortran_MODULE_DIRECTORY "${3rd_party_Fortran_MODULE_DIR}")      # location same as the ExternalProject add info below

   # Need to set flags for C++11 standard.  HDF5 needs this, as does EnDyn.
   include(CheckCXXCompilerFlag)
   CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
   CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
   if(COMPILER_SUPPORTS_CXX11)
       set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
   elseif(COMPILER_SUPPORTS_CXX0X)
       set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
   else()
           message(STATUS "The compiler ${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler.")
   endif()
  
#Not sure if this logic works
   if (HDF5_COMPRESSION)
      set(HDF5_DEPENDS "zlib")
      find_package(ZLIB)
      add_library(zlib UNKNOWN IMPORTED)
      set_target_properties(zlib PROPERTIES IMPORTED_LOCATION ${ZLIB_LIBRARY})
   else()
      set(HDF5_DEPENDS "")
   endif()



   set(HDF5_CMAKE_ARGS "")
   list(APPEND HDF5_CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/3rd_party
      -DCMAKE_Fortran_MODULE_DIRECTORY=${HDF5_CMAKE_Fortran_MODULE_DIRECTORY}
      -DHDF5_BUILD_FORTRAN=ON
      -DHDF5_BUILD_CPP_LIB=ON
      -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
      -DBUILD_TESTING=OFF
      -DHDF5_BUILD_EXAMPLES=OFF
      -DHDF5_BUILD_TOOLS=OFF
      -DHDF5_BUILD_HL_LIB=OFF
      -DHDF5_NO_PACKAGES=OFF
      -DHDF5_PACKAGE_EXTLIBS=OFF
      -DALLOW_UNSUPPORTED=ON
      -DCMAKE_BUILD_TYPE=Release
      -DHDF5_INSTALL_LIB_DIR=${3rd_party_LIB_DIR}
      -DHDF5_INSTALL_BIN_DIR=${3rd_party_BIN_DIR})
      #-DHDF5_ENABLE_Z_LIB_SUPPORT  ON
      #-DHDF5_ALLOW_EXTERNAL_SUPPORT  TGZ
      #-DTGZPATH  ${CMAKE_SOURCE_DIR}/external
      #-DZLIB_TGZ_NAME  ZLib.tar.gz
      #-DZLIB_PACKAGE_NAME  zlib
      #-DZLIB_EXTERNALLY_CONFIGURED  ON
      ##-DZLIB_INSTALL_BIN_DIR  "${CMAKE_CURRENT_BINARY_DIR}/bin"
      ##-DZLIB_INSTALL_LIB_DIR  "${CMAKE_CURRENT_BINARY_DIR}/lib"
      #-DHDF5_ENABLE_SZIP_SUPPORT  OFF
      #-DHDF5_ENABLE_SZIP_ENCODING  OFF




      # Add the HDF5 project
   ExternalProject_Add(HDF5
         PREFIX 3rd_party
         DEPENDS ${HDF5_DEPENDS}
         CMAKE_ARGS ${HDF5_CMAKE_ARGS}
         SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/external/hdf5-1.8.19")

#   add_library(HDF5 IMPORTED)
   if (${LIB_TYPE} MATCHES "SHARED")
      set(HDF5_LIBRARIES
         ${CMAKE_SHARED_LIBRARY_PREFIX}hdf5_fortran${CMAKE_SHARED_LIBRARY_SUFFIX}
         ${CMAKE_SHARED_LIBRARY_PREFIX}hdf5_f90cstub${CMAKE_SHARED_LIBRARY_SUFFIX}
         ${CMAKE_SHARED_LIBRARY_PREFIX}hdf5_cpp${CMAKE_SHARED_LIBRARY_SUFFIX}
         ${CMAKE_SHARED_LIBRARY_PREFIX}hdf5${CMAKE_SHARED_LIBRARY_SUFFIX}      )
   elseif (${LIB_TYPE} MATCHES "STATIC")
      set(HDF5_LIBRARIES
         ${CMAKE_STATIC_LIBRARY_PREFIX}hdf5_fortran${CMAKE_STATIC_LIBRARY_SUFFIX}
         ${CMAKE_STATIC_LIBRARY_PREFIX}hdf5_f90cstub${CMAKE_STATIC_LIBRARY_SUFFIX}
         ${CMAKE_STATIC_LIBRARY_PREFIX}hdf5_cpp${CMAKE_STATIC_LIBRARY_SUFFIX}
         ${CMAKE_STATIC_LIBRARY_PREFIX}hdf5${CMAKE_STATIC_LIBRARY_SUFFIX}      )
   endif()


      ##########################################
      # set some names for compilation / linking
#   set (HDF5_LIBRARIES  "")
#   if (MSVC)
#      list(APPEND HDF5_LIBRARIES  libhdf5_fortran libhdf5_f90cstub libhdf5_cpp libhdf5)   # MS visual studo does not append the -static or -shared to the lib
#   else()
##      list(APPEND HDF5_LIBRARIES  hdf5_fortran-${SEARCH_TYPE} hdf5_f90cstub-${SEARCH_TYPE} hdf5_cpp-${SEARCH_TYPE} hdf5-${SEARCH_TYPE})
#      list(APPEND HDF5_LIBRARIES  hdf5_fortran hdf5_f90cstub hdf5_cpp hdf5)
#   endif()

      # Linux with gfortran needs the libdl library
   get_filename_component(FCNAME ${CMAKE_Fortran_COMPILER} NAME)
   if (((FCNAME MATCHES "gfortran.*") OR (FCNAME MATCHES "f95.*")) AND (UNIX AND NOT APPLE))
      list(APPEND HDF5_LIBRARIES dl)
   endif()

   set (HDF5_LINK_DIRECTORIES "${3rd_party_LIB_DIR}")
   set (HDF5_INCLUDE_PATH "${HDF5_CMAKE_Fortran_MODULE_DIRECTORY}/${SEARCH_TYPE}")

      # Visual studio puts things in funny places. There is probably a cleaner way to set the path based on returned values from HDF5, but I don't know how yet.
   if (MSVC)
      set (HDF5_INCLUDE_PATH "${HDF5_CMAKE_Fortran_MODULE_DIRECTORY}/${CMAKE_CFG_INTDIR}")
   endif()


endif()




# Now add subdirectories
add_subdirectory (TestProg)



##print out all variables
#message(STATUS "----------------------------------------------------------")
#get_cmake_property(_variableNames VARIABLES)
#foreach (_variableName ${_variableNames})
#   message(STATUS "${_variableName}=${${_variableName}}")
#endforeach()

