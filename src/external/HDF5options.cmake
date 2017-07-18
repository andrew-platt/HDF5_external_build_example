set(HDF5_BUILD_FORTRAN  ON    CACHE BOOL "Build the Fortran bit")
set(HDF5_BUILD_CPP_LIB  ON    CACHE BOOL "Build the CPP libs")
if (${LIB_TYPE} MATCHES "SHARED")
   set(BUILD_SHARED_LIBS   ON    CACHE BOOL "Shared HDF5 libs")
else()   #otherwise they are static
   set(BUILD_SHARED_LIBS   OFF   CACHE BOOL "Shared HDF5 libs")
endif()


set(BUILD_TESTING       OFF   CACHE BOOL "Build the testing stuff")
set(HDF5_BUILD_EXAMPLES OFF   CACHE BOOL "Build the examples")
set(HDF5_BUILD_TOOLS    OFF   CACHE BOOL "Build the tools")
set(HDF5_BUILD_HL_LIB   OFF   CACHE BOOL "Build the Hi Level stuff -- not sure what it does")
set(HDF5_NO_PACKAGES    OFF   CACHE BOOL "Not sure??")
#set( OFF CACHE BOOL "")

# Compression options
if(HDF5_COMPRESSION)
#FIXME: add queries here for existing libs?
   set(HDF5_ENABLE_Z_LIB_SUPPORT ON CACHE BOOL "Z_Lib compression support")
   set(HDF5_ALLOW_EXTERNAL_SUPPORT TGZ CACHE STRING "Z_Lib as a tgz file")
   set(TGZPATH ${CMAKE_SOURCE_DIR}/external CACHE PATH "Z_Lib as a tgz file")
   set(ZLIB_TGZ_NAME ZLib.tar.gz CACHE STRING "Z_Lib as a tgz file")
   set(ZLIB_PACKAGE_NAME zlib CACHE STRING "name of zlib package")
   set(ZLIB_EXTERNALLY_CONFIGURED ON CACHE BOOL "Externally configured")
   #set(ZLIB_INSTALL_BIN_DIR "${CMAKE_CURRENT_BINARY_DIR}/bin" CACHE STRING "location for the libs")
   #set(ZLIB_INSTALL_LIB_DIR "${CMAKE_CURRENT_BINARY_DIR}/lib" CACHE STRING "location for the libs")
endif()


set(HDF5_ENABLE_SZIP_SUPPORT OFF CACHE BOOL "")
set(HDF5_ENABLE_SZIP_ENCODING OFF CACHE BOOL "")

set(HDF5_PACKAGE_EXTLIBS   OFF   CACHE BOOL "Not sure")


set(ALLOW_UNSUPPORTED ON CACHE BOOL "Allow unsupported compile configs")
