# Uses MKLROOT environment variable or CMake's MKL_ROOT to find MKL ScaLAPACK.
#
# Variables:
#   ScaLAPACK_FOUND
#
# Imported Targets: 
#   MKL::ScaLAPACK
#
# The MPI backend has to be specified
#        MKL_MPI_TYPE             := OMPI|MPICH          (default: MPICH)
#
# Note: Do not mix MPI implementations.
#       The module depends on FindThreads and FindOpenMP.
#
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")
include(FindPackageHandleStandardArgs)

find_package(MKL REQUIRED)

function(__mkl_find_library _name)
    find_library(${_name}
        NAMES ${ARGN}
        HINTS ENV MKLROOT
              ${MKL_ROOT}
        PATH_SUFFIXES ${_mkl_libpath_suffix}
    )
    mark_as_advanced(${_name})
endfunction()

__mkl_find_library(MKL_SCALAPACK_LIB mkl_scalapack_lp64)
if(MKL_MPI_TYPE MATCHES "OMPI")
     __mkl_find_library(MKL_BLACS_LIB mkl_blacs_openmpi_lp64)
else() # MPICH
    __mkl_find_library(MKL_BLACS_LIB mkl_blacs_intelmpi_lp64)
endif()

find_package_handle_standard_args(ScaLAPACK
  DEFAULT_MSG MKL_BLACS_LIB
              MKL_SCALAPACK_LIB
)

if (ScaLAPACK_FOUND AND NOT TARGET MKL::ScaLAPACK)
    add_library(MKL::BLACS UNKNOWN IMPORTED)
    set_target_properties(MKL::BLACS PROPERTIES IMPORTED_LOCATION ${MKL_BLACS_LIB})

    add_library(MKL::ScaLAPACK UNKNOWN IMPORTED)
    set_target_properties(MKL::ScaLAPACK PROPERTIES 
      IMPORTED_LOCATION "${MKL_SCALAPACK_LIB}"
      INTERFACE_LINK_LIBRARIES "MKL::BLAS_INTERFACE;MKL::THREADING;MKL::CORE;MKL::BLACS;${__mkl_threading_backend};Threads::Threads"
      )
endif()

