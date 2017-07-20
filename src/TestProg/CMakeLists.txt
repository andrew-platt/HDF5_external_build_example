cmake_minimum_required(VERSION 3.2.2)
project(rdwt)

#find_package(HDF5_fortran QUIET)
#if (HDF5_compression)
#   if (ZLIB_USE_EXTERNAL)     # set if we are building this from source
#      find_package(ZLIB QUIET)
#   endif()
#endif()
enable_language(Fortran)

if (BUILD_HDF5)
   INCLUDE_DIRECTORIES (${HDF5_INCLUDE_PATH})
   LINK_DIRECTORIES (${HDF5_LINK_DIRECTORIES})
#   if (HDF5_compression)
#      if (ZLIB_USE_EXTERNAL)     # set if we are building this from source
#         INCLUDE_DIRECTORIES (${hdf_ZLIB_INCLUDE_DIRS})
#      endif()
#   endif()
endif()

add_executable(rdwt h5_rdwt.f90)
target_link_libraries(rdwt ${HDF5_LIBRARIES})




project(cmprss)

#find_package(HDF5_fortran QUIET)
#if (HDF5_compression)
#   if (ZLIB_USE_EXTERNAL)     # set if we are building this from source
#      find_package(ZLIB QUIET)
#   endif()
#endif()
enable_language(Fortran)

if (BUILD_HDF5)
   INCLUDE_DIRECTORIES (${HDF5_INCLUDE_PATH})
   LINK_DIRECTORIES (${HDF5_LINK_DIRECTORIES})

#   if (HDF5_compression)
#      if (ZLIB_USE_EXTERNAL)     # set if we are building this from source
#         INCLUDE_DIRECTORIES (${hdf_ZLIB_INCLUDE_DIRS})
#      endif()
#   endif()
endif()

add_executable(cmprss h5_cmprss.f90)
target_link_libraries(cmprss ${HDF5_LIBRARIES}) 


#message(STATUS "----------------------------------------------------------")
#get_cmake_property(_variableNames VARIABLES)
#foreach (_variableName ${_variableNames})
#   message(STATUS "${_variableName}=${${_variableName}}")
#endforeach()





