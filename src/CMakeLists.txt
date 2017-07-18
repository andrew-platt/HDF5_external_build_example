cmake_minimum_required(VERSION 2.8.12)
project(HDF5test Fortran C CXX)

# Set library type
set (LIB_TYPE STATIC)
#set (LIB_TYPE SHARED)
string(TOLOWER ${LIB_TYPE} SEARCH_TYPE)         # make lower case and store as SEARCH_TYPE.  This is used for finding the HDF5 libraries to link

#### Check if we have HDF5 already
find_package ( HDF5_fortran QUIET)
if ( NOT HDF5_FOUND )
    message ( STATUS "HDF5 not found. Forcing to build own copy...")
    set ( BUILD_HDF5 TRUE )
endif()


option (HDF5_COMPRESSION "Enable compression in HDF5." OFF)
mark_as_advanced (HDF5_COMPRESSION)










if ( BUILD_HDF5 )

   get_filename_component(default_install "${CMAKE_SOURCE_DIR}/../install" ABSOLUTE)




   
   set (CMAKE_INSTALL_PREFIX "${default_install}/bin")
   
   # FOR HDF5
   # Tell hdf5 that we are manually overriding certain settings
   set (HDF5_EXTERNALLY_CONFIGURED 1)
   # Avoid duplicating names of installed libraries
#   set (HDF5_EXTERNAL_LIB_PREFIX "extern_")
   # Export configuration to this export variable
   set (HDF5_EXPORTED_TARGETS "hdf5-targets")
   
   set (HDF5_INSTALL_CMAKE_DIR "${INSTALL_CMAKE_DIR}/hdf5")
   
   #set (CMAKE_INSTALL_PREFIX ${default_install})
   include (${CMAKE_SOURCE_DIR}/external/HDF5options.cmake)
#FIXME: not sure these next lines do anything.
#   set(HDF_USE_SYSTEM_ZLIB "false")      # Not sure if this will be an issue.
#   set(hdf_ZLIB_INCLUDE_DIRS ${CMAKE_SOURCE_DIR}/external/ZLib)
   
   set (CMAKE_Fortran_MODULE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/bin")
   set (HDF5_INSTALL_BIN_DIR "${CMAKE_CURRENT_BINARY_DIR}/bin")
   set (HDF5_INSTALL_LIB_DIR "${CMAKE_CURRENT_BINARY_DIR}/lib")
   set (HDF5_INSTALL_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/include")
   set (HDF5_INSTALL_DATA_DIR "${CMAKE_CURRENT_BINARY_DIR}/data")
   
   
   #######
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
   
   # Another option: Not sure if the target is right.
   #set_property(TARGET FASThdf5 PROPERTY CXX_STANDARD 11)
   ####
   
   # third option
   #set (CMAKE_CXX_STANDARD 11)      # required for HDF5

#   if (HDF5_ENABLE_Z_LIB_SUPPORT)
#     # We must tell the main HDF5 library that it depends on our zlib
#     set (HDF5_LIB_DEPENDENCIES zlib)
#   endif()

   add_subdirectory (external/hdf5-1.8.19)
#   add_subdirectory (external/hdf5-1.10.1)

endif()





# Now add subdirectories
add_subdirectory (TestProg)



##print out all variables
#message(STATUS "----------------------------------------------------------")
#get_cmake_property(_variableNames VARIABLES)
#foreach (_variableName ${_variableNames})
#   message(STATUS "${_variableName}=${${_variableName}}")
#endforeach()

