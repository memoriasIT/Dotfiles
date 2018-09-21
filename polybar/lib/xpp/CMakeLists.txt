cmake_minimum_required(VERSION 3.0 FATAL_ERROR)
project(xpp)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${PROJECT_SOURCE_DIR}/cmake)

#
# Process dependencies
#
find_package(PkgConfig)
pkg_check_modules(XCBPROTO REQUIRED xcb-proto)

find_package(PythonInterp 2.7 REQUIRED)
find_package(XCB REQUIRED XCB ICCCM EWMH UTIL IMAGE)

if(NOT PYTHON_EXECUTABLE)
  message(FATAL_ERROR "Missing PYTHON_EXECUTABLE")
endif()

set(XPP_INCLUDE_DIRS
  ${PROJECT_SOURCE_DIR}/include
  ${XCB_XCB_INCLUDE_DIR}
  ${XCB_EWMH_INCLUDE_DIR}
  ${XCB_ICCCM_INCLUDE_DIR}
  ${XCB_UTIL_INCLUDE_DIR}
  ${XCB_IMAGE_INCLUDE_DIR})
set(XPP_LIBRARIES
  ${XCB_XCB_LIBRARY}
  ${XCB_EWMH_LIBRARY}
  ${XCB_ICCCM_LIBRARY}
  ${XCB_UTIL_LIBRARY}
  ${XCB_IMAGE_LIBRARY})

#
# Loop through a hardcoded list of python executables to locate the python module "xcbgen"
#
foreach(CURRENT_EXECUTABLE python2 python2.7 python3 python)
  message(STATUS "Searching for xcbgen with " ${CURRENT_EXECUTABLE})

  execute_process(COMMAND "${CURRENT_EXECUTABLE}" "-c"
    "import re,xcbgen;print(re.compile('/xcbgen/__init__.py.*').sub('',xcbgen.__file__))"
    RESULT_VARIABLE _xcbgen_status
    OUTPUT_VARIABLE _xcbgen_location
    ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)

  # When a shell script returns successfully its return code is 0
  if(_xcbgen_status EQUAL 0)
    set(PYTHON_XCBGEN "${_xcbgen_location}" CACHE STRING "Location of python module: xcbgen ")
    message(STATUS "Found xcbgen in " ${PYTHON_XCBGEN})
    break()
  endif()

endforeach(CURRENT_EXECUTABLE)

if(NOT PYTHON_XCBGEN)
  message(FATAL_ERROR "Missing required python module: xcbgen")
endif()

#
# Include XCB libs depending on what protos we build
#
if(NOT XCB_PROTOS)
  set(XCB_PROTOS
    "bigreq"
    "composite"
    "damage"
    "dpms"
    "dri2"
    "dri3"
    "glx"
    "present"
    "randr"
    "record"
    "render"
    "res"
    "screensaver"
    "shape"
    "shm"
    "sync"
    "xc_misc"
    "xevie"
    "xf86dri"
    "xfixes"
    "xinerama"
    "xinput"
    "xkb"
    "xprint"
    "xproto"
    "xselinux"
    "xtest"
    "xv"
    "xvmc")
endif()

if(";${XCB_PROTOS};" MATCHES ";randr;")
  find_package(XCB REQUIRED RANDR)
  set(XPP_INCLUDE_DIRS ${XPP_INCLUDE_DIRS} ${XCB_RANDR_INCLUDE_DIR})
  set(XPP_LIBRARIES ${XPP_LIBRARIES} ${XCB_RANDR_LIBRARY})
endif()
if(";${XCB_PROTOS};" MATCHES ";render;")
  find_package(XCB REQUIRED RENDER)
  set(XPP_INCLUDE_DIRS ${XPP_INCLUDE_DIRS} ${XCB_RENDER_INCLUDE_DIR})
  set(XPP_LIBRARIES ${XPP_LIBRARIES} ${XCB_RENDER_LIBRARY})
endif()
if(";${XCB_PROTOS};" MATCHES ";damage;")
  find_package(XCB REQUIRED DAMAGE)
  set(XPP_INCLUDE_DIRS ${XPP_INCLUDE_DIRS} ${XCB_DAMAGE_INCLUDE_DIR})
  set(XPP_LIBRARIES ${XPP_LIBRARIES} ${XCB_DAMAGE_LIBRARY})
endif()
if(";${XCB_PROTOS};" MATCHES ";sync;")
  find_package(XCB REQUIRED SYNC)
  set(XPP_INCLUDE_DIRS ${XPP_INCLUDE_DIRS} ${XCB_SYNC_INCLUDE_DIR})
  set(XPP_LIBRARIES ${XPP_LIBRARIES} ${XCB_SYNC_LIBRARY})
endif()
if(";${XCB_PROTOS};" MATCHES ";composite;")
  find_package(XCB REQUIRED COMPOSITE)
  set(XPP_INCLUDE_DIRS ${XPP_INCLUDE_DIRS} ${XCB_COMPOSITE_INCLUDE_DIR})
  set(XPP_LIBRARIES ${XPP_LIBRARIES} ${XCB_COMPOSITE_LIBRARY})
endif()
if(";${XCB_PROTOS};" MATCHES ";xkb;")
  find_package(XCB REQUIRED XKB)
  set(XPP_INCLUDE_DIRS ${XPP_INCLUDE_DIRS} ${XCB_XKB_INCLUDE_DIR})
  set(XPP_LIBRARIES ${XPP_LIBRARIES} ${XCB_XKB_LIBRARY})
endif()

set(PROTO_LIST)

if(NOT XCBPROTO_PREFIX)
  set(XCBPROTO_PREFIX /usr)
endif()
file(GLOB PROTO_LIST_RAW RELATIVE ${XCBPROTO_PREFIX}/share/xcb ${XCBPROTO_PREFIX}/share/xcb/*.xml)

#
# Filter glob
#
foreach(PROTO_RAW ${PROTO_LIST_RAW})
  string(REGEX REPLACE "(^xf86vidmode.xml|^ge.xml|.xml)\$" "" PROTO ${PROTO_RAW})
  if(PROTO AND ";${XCB_PROTOS};" MATCHES ";${PROTO};")
    message(STATUS "${PROJECT_NAME}: including xcb proto ${PROTO_RAW}")
    set(PROTO_LIST ${PROTO_LIST} ${PROTO})
  endif()
endforeach(PROTO_RAW)

#
# Add commands
#
set(PROTO_HEADER_FILES "")
foreach(PROTO ${PROTO_LIST})
  string(REGEX REPLACE "proto\$" "" PROTO_OUTPUT ${PROTO})
  set(OUTPUT_FILE ${PROJECT_SOURCE_DIR}/include/xpp/proto/${PROTO_OUTPUT}.hpp)
  add_custom_command(
    OUTPUT ${OUTPUT_FILE}
    COMMAND ${PYTHON_EXECUTABLE} ${PROJECT_SOURCE_DIR}/generators/cpp_client.py -p "${PYTHON_XCBGEN}"
    ${XCBPROTO_PREFIX}/share/xcb/${PROTO}.xml > ${OUTPUT_FILE})
  list(APPEND PROTO_HEADER_FILES ${OUTPUT_FILE})
endforeach(PROTO)

#
# Create project lib and commands
#
file(GLOB_RECURSE HEADER_FILES ${PROJECT_SOURCE_DIR}/include/*.hpp)
add_library(${PROJECT_NAME} ${HEADER_FILES} ${PROTO_HEADER_FILES})

target_include_directories(${PROJECT_NAME} PUBLIC ${XPP_INCLUDE_DIRS})
target_include_directories(${PROJECT_NAME} PRIVATE ${PROJECT_SOURCE_DIR}/include/xpp)
target_link_libraries(${PROJECT_NAME} PRIVATE ${XPP_LIBRARIES})

target_compile_options(${PROJECT_NAME} PRIVATE -std=c++14 -Wall -Wpedantic)
target_compile_options(${PROJECT_NAME} PRIVATE $<$<CONFIG:Debug>:-g3 -DDEBUG>)
target_compile_options(${PROJECT_NAME} PRIVATE $<$<CONFIG:Release>:-O3 -Wno-unused-variable>)
target_compile_options(${PROJECT_NAME} PUBLIC ${X11_XCB_DEFINITIONS} ${XCB_DEFINITIONS})

set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)

#
# Export lists to the parent scope if there are any
#
get_directory_property(HAS_PARENT PARENT_DIRECTORY)

if(HAS_PARENT)
  set(XPP_INCLUDE_DIRS ${XPP_INCLUDE_DIRS} PARENT_SCOPE)
  set(XPP_LIBRARIES ${PROJECT_NAME} PARENT_SCOPE)
endif()
