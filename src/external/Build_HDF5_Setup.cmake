      # The included script needs these defined:
      #     3rd_party_BUILD_DIR         
      #     3rd_party_LIB_DIR           
      #     3rd_party_BIN_DIR           
      #     3rd_party_Fortran_MODULE_DIR
      # and will return these for linking
      #     HDF5_LINK_DIRECTORIES
      #     HDF5_INCLUDE_PATH 
   set (HDF5_EXTERNALLY_CONFIGURED 1)
   set (HDF5_EXPORTED_TARGETS "hdf5-targets")
   set (HDF5_CMAKE_Fortran_MODULE_DIRECTORY "${3rd_party_Fortran_MODULE_DIR}")      # location same as the ExternalProject add info below



   # Need to set flags for C++11 standard.  HDF5 needs this
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
  
   if (${LIB_TYPE} MATCHES "SHARED")
      SET(LIB_SHARED ON)
   elseif (${LIB_TYPE} MATCHES "STATIC")
      SET(LIB_SHARED OFF)
   endif()

   set(HDF5_CMAKE_ARGS "")
   list(APPEND HDF5_CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX:STRING=${3rd_party_BUILD_DIR}
      -DCMAKE_Fortran_MODULE_DIRECTORY:STRING=${HDF5_CMAKE_Fortran_MODULE_DIRECTORY}
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
      -DHDF5_BUILD_FORTRAN:BOOL=ON
      -DHDF5_BUILD_CPP_LIB:BOOL=ON
      -DBUILD_SHARED_LIBS:BOOL=${LIB_SHARED}
      -DHDF5_EXPORTED_TARGETS:STRING=hdf5-targets
      -DBUILD_TESTING:BOOL=OFF
      -DHDF5_BUILD_EXAMPLES:BOOL=OFF
      -DHDF5_BUILD_TOOLS:BOOL=OFF
      -DHDF5_BUILD_HL_LIB:BOOL=OFF
      -DHDF5_NO_PACKAGES:BOOL=OFF
      -DHDF5_PACKAGE_EXTLIBS:BOOL=OFF
      -DALLOW_UNSUPPORTED:BOOL=ON
      -DHDF5_ALLOW_EXTERNAL_SUPPORT:BOOL=ON 
#options don't work on linux??
#      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${3rd_party_LIB_DIR}
#      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${3rd_party_LIB_DIR}
#      -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${3rd_party_LIB_DIR}
#      -DCMAKE_PDB_OUTPUT_DIRECTORY:PATH=${3rd_party_LIB_DIR}
      -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS})




   if(HDF5_COMPRESSION)
      list(APPEND HDF5_CMAKE_ARGS
         -DHDF5_ENABLE_Z_LIB_SUPPORT=ON)

      if( BUILD_ZLIB )
         set(HDF5_DEPENDS "localZLIB")
         set(localZLIB_args "")
         list(APPEND localZLIB_args
            -DZLIB_EXTERNALLY_CONFIGURED:BOOL=ON
            -DCMAKE_INSTALL_PREFIX:STRING=${3rd_party_BUILD_DIR}
            -DBUILD_SHARED_LIBS:BOOL=${LIB_SHARED}
            -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE})
#            -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${3rd_party_LIB_DIR}
#            -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${3rd_party_LIB_DIR})
#            -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${3rd_party_LIB_DIR}
#            -DCMAKE_PDB_OUTPUT_DIRECTORY:PATH=${3rd_party_LIB_DIR})
#            -DZLIB_PACKAGE_EXT:STRING=${HDF_PACKAGE_EXT}
#            -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
#            -DZLIB_USE_EXTERNAL:BOOL=OFF)

         ExternalProject_Add(localZLIB
            PREFIX 3rd_party
            URL ${CMAKE_SOURCE_DIR}/external/ZLib.tar.gz
            CMAKE_ARGS ${localZLIB_args})
  
         ExternalProject_Get_Property (localZLIB BINARY_DIR )
         ExternalProject_Get_Property (localZLIB SOURCE_DIR)
         ExternalProject_Get_Property (localZLIB INSTALL_DIR)
         set(localZLIB_BINARY_DIR ${BINARY_DIR})
         set(localZLIB_SOURCE_DIR ${SOURCE_DIR})
         set(localZLIB_INSTALL_DIR ${INSTALL_DIR})

         set(localZLIB_INCLUDE_DIR ${3rd_party_BUILD_DIR}/src/localZLIB)
         link_directories(${localZLIB_INCLUDE_DIR})


         if (WIN32)
            set (localZLIB_LIB_NAME "zlib")
         else ()
            set (localZLIB_LIB_NAME "z")
         endif ()
         set (localZLIB_LIBRARY ${3rd_party_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}${localZLIB_LIB_NAME}${CMAKE_STATIC_LIBRARY_SUFFIX})
         if (WIN32)
            set (localZLIB_LIBRARY "optimized ${localZLIB_LIBRARY} debug ${3rd_party_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}${localZLIB_LIB_NAME}_D${CMAKE_STATIC_LIBRARY_SUFFIX}")       #spec both optimized and debug
         endif()

         if (${LIB_TYPE} MATCHES "SHARED")
            set (localZLIB_SHARED_LIBRARY ${3rd_party_LIB_DIR}/${CMAKE_SHARED_LIBRARY_PREFIX}${localZLIB_LIB_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX})
            if (WIN32)
               set (localZLIB_SHARED_LIBRARY "optimized ${localZLIB_SHARED_LIBRARY} debug ${3rd_party_LIB_DIR}/${CMAKE_SHARED_LIBRARY_PREFIX}${localZLIB_LIB_NAME}_D${CMAKE_SHARED_LIBRARY_SUFFIX}")       #spec both optimized and debug
            endif()
         endif()
         set (ZLIB_FOUND 1)


            # Now set some more info for the HDF5 compile
         list(APPEND HDF5_CMAKE_ARGS
            -DZLIB_USE_EXTERNAL:BOOL=ON
            -DH5_ZLIB_HEADER:STRING=zlib.h
            -DZLIB_INCLUDE_DIR:PATH=${localZLIB_INCLUDE_DIR}
            -DZLIB_LIBRARIES:FILEPATH=${localZLIB_LIBRARY})
         if (${LIB_TYPE} MATCHES "SHARED")
            list(APPEND HDF5_CMAKE_ARGS
               -DZLIB_SHARED_LIBRARY:FILEPATH=${localZLIB_SHARED_LIBRARY})
         endif()
      else( BUILD_ZLIB )
         # Force it to use the system one if it can find it (which it should have before when the BUILD_ZLIB flag was set)
         list(APPEND HDF5_CMAKE_ARGS
            -DZLIB_USE_EXTERNAL:BOOL=OFF)
      endif()


   else()
      list(APPEND HDF5_CMAKE_ARGS
      -DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=OFF
      -DHDF5_ENABLE_SZIP_SUPPORT:BOOL=OFF
      -DHDF5_ENABLE_SZIP_ENCODING:BOOL=OFF)
   endif()






      # Add the HDF5 project
   ExternalProject_Add(localHDF5
         PREFIX 3rd_party
         DEPENDS ${HDF5_DEPENDS}
         CMAKE_ARGS ${HDF5_CMAKE_ARGS}
         INSTALL_DIR ${3rd_party_LIB_DIR}
#         SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/external/hdf5-1.10.1")
         SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/external/hdf5-1.8.19")

   externalproject_get_property (localHDF5 BINARY_DIR SOURCE_DIR INSTALL_DIR)


      # Can't find a way to automate this.  Not sure how to get the hdf5-targets exported from the HDF5 build.
   set(HDF5_LIBRARIES
      hdf5_fortran
      hdf5_f90cstub
      hdf5_cpp
      hdf5)
   if (WIN32)
      set(templist "")
      foreach (libname ${HDF5_LIBRARIES})
         if (${LIB_TYPE} MATCHES "SHARED")
           LIST(APPEND templist "optimized ${CMAKE_SHARED_LIBRARY_PREFIX}${libname}${CMAKE_SHARED_LIBRARY_SUFFIX}")
           LIST(APPEND templist "debug ${CMAKE_SHARED_LIBRARY_PREFIX}${libname}_D${CMAKE_SHARED_LIBRARY_SUFFIX}")
         elseif (${LIB_TYPE} MATCHES "STATIC")
           LIST(APPEND templist "optimized ${CMAKE_STATIC_LIBRARY_PREFIX}${libname}${CMAKE_STATIC_LIBRARY_SUFFIX}")
           LIST(APPEND templist "debug ${CMAKE_STATIC_LIBRARY_PREFIX}${libname}_D${CMAKE_STATIC_LIBRARY_SUFFIX}")
        endif()
     endforeach()
     set(HDF5_LIBRARIES "${templist}")
   else()
      set(templist "")
      foreach (libname ${HDF5_LIBRARIES})
         if (${LIB_TYPE} MATCHES "SHARED")
            LIST(APPEND templist "${CMAKE_SHARED_LIBRARY_PREFIX}${libname}-shared${CMAKE_SHARED_LIBRARY_SUFFIX}")
         elseif (${LIB_TYPE} MATCHES "STATIC")
            LIST(APPEND templist "${CMAKE_STATIC_LIBRARY_PREFIX}${libname}-static${CMAKE_STATIC_LIBRARY_SUFFIX}")
         endif()
      endforeach()
      set(HDF5_LIBRARIES "${templist}")
   endif()




      ##########################################
      # set some names for compilation / linking
   #FIXME: if we don't build, we need to add the zlib dependencies to the libs.
   if (BUILD_ZLIB)
      set(HDF5_LIBRARIES ${HDF5_LIBRARIES} ${localZLIB_LIB_NAME})
   else()
      set(HDF5_LIBRARIES ${HDF5_LIBRARIES} ${ZLIB_LIBRARIES})
   endif()


      # Linux with gfortran needs the libdl library
   get_filename_component(FCNAME ${CMAKE_Fortran_COMPILER} NAME)
   if (((FCNAME MATCHES "gfortran.*") OR (FCNAME MATCHES "f95.*")) AND (UNIX AND NOT APPLE))
      list(APPEND HDF5_LIBRARIES dl)
   endif()

   set (HDF5_LINK_DIRECTORIES "${3rd_party_LIB_DIR}")
   set (HDF5_INCLUDE_PATH "${HDF5_CMAKE_Fortran_MODULE_DIRECTORY}/${SEARCH_TYPE}")

      # Visual studio puts things in funny places. There is probably a cleaner way to set the path based on returned values from HDF5, but I don't know how yet.
   if (MSVC)
      set (HDF5_INCLUDE_PATH "${HDF5_CMAKE_Fortran_MODULE_DIRECTORY}/$(ConfigurationName)")
      set (HDF5_LINK_DIRECTORIES "${3rd_party_LIB_DIR}/$(ConfigurationName)")
   endif()



