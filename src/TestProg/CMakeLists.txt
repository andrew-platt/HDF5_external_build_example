cmake_minimum_required(VERSION 3.2.2)
project(rdwt)

enable_language(Fortran)

INCLUDE_DIRECTORIES (${HDF5_INCLUDE_PATH})
LINK_DIRECTORIES (${HDF5_LINK_DIRECTORIES})

add_executable(rdwt h5_rdwt.f90)
target_link_libraries(rdwt  ${HDF5_LIBRARIES})




project(cmprss)

enable_language(Fortran)

INCLUDE_DIRECTORIES (${HDF5_INCLUDE_PATH})
LINK_DIRECTORIES (${HDF5_LINK_DIRECTORIES})

add_executable(cmprss h5_cmprss.f90)
target_link_libraries(cmprss ${HDF5_LIBRARIES}) 




project(TestCase)

enable_language(Fortran)

INCLUDE_DIRECTORIES (${HDF5_INCLUDE_PATH})
LINK_DIRECTORIES (${HDF5_LINK_DIRECTORIES})

add_executable(TestCase TestCase.f90)
target_link_libraries(TestCase ${HDF5_LIBRARIES}) 


