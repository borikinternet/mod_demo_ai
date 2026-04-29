cmake_minimum_required(VERSION 3.0)
project(mod_demo_ai)

set(CMAKE_CXX_STANDARD 17)

set(LCC_PROJECT_NAME ${CMAKE_PROJECT_NAME})
set(LCC_PROJECT_MAGIC_NUM 117)
set(LCC_PROJECTS_BASE_DIR ${PROJECT_SOURCE_DIR}/projects)

find_package(PkgConfig REQUIRED)
pkg_check_modules(SW REQUIRED freeswitch)
pkg_check_modules(SOFIA REQUIRED sofia-sip-ua)
pkg_check_modules(SPANDSP REQUIRED spandsp)

add_library(mod_demo_ai MODULE src/mod_demo_ai.c)
set_target_properties(mod_demo_ai
        PROPERTIES PREFIX "")
target_compile_options(mod_demo_ai PRIVATE
        ${SW_CFLAGS}
        -fPIC)
target_include_directories(mod_demo_ai PRIVATE
        include
        ${SW_INCLUDE_DIRS})
target_link_libraries(mod_demo_ai
        ${SW_LINK_LIBRARIES})
target_link_options(mod_demo_ai PRIVATE
        ${SW_LDFLAGS})
target_link_directories(mod_demo_ai PRIVATE
        ${SW_LIBRARY_DIRS})
install(TARGETS mod_demo_ai
        LIBRARY
        DESTINATION /usr/lib64/freeswitch/mod)
install(FILES conf/demo-ai.conf.xml
        DESTINATION /etc/freeswitch/autoload_configs)

add_library(mod_vosk SHARED EXCLUDE_FROM_ALL examples/mod_vosk.c
        examples/mod_skel.c)
set_target_properties(mod_vosk
        PROPERTIES PREFIX "")
target_include_directories(mod_vosk PRIVATE
        ${SW_INCLUDE_DIRS}
        ${libks_SOURCE_DIR}/src/include)
target_link_libraries(mod_vosk
        ks
        ${SW_LINK_LIBRARIES})
target_link_directories(mod_vosk PRIVATE
        ${SW_LIBRARY_DIRS})

# IDE-only target for CLion indexing/navigation of FreeSWITCH sources.
# This does not build or link FreeSWITCH.
file(GLOB_RECURSE FREESWITCH_IDE_HEADERS CONFIGURE_DEPENDS
        ${CMAKE_SOURCE_DIR}/examples/fs/src/include/*.h)
file(GLOB_RECURSE FREESWITCH_IDE_SOURCES CONFIGURE_DEPENDS
        ${CMAKE_SOURCE_DIR}/examples/fs/src/*.c)
file(GLOB_RECURSE FREESWITCH_LIBS_IDE_HEADERS CONFIGURE_DEPENDS
        ${CMAKE_SOURCE_DIR}/examples/fs/libs/*.h)
file(GLOB_RECURSE FREESWITCH_LIBS_IDE_SOURCES CONFIGURE_DEPENDS
        ${CMAKE_SOURCE_DIR}/examples/fs/libs/*.c)
file(GLOB FREESWITCH_LIBS_DIRS LIST_DIRECTORIES true
        ${CMAKE_SOURCE_DIR}/examples/fs/libs/*)

set(FREESWITCH_LIBS_IDE_INCLUDE_DIRS "")
foreach(FREESWITCH_LIB_DIR ${FREESWITCH_LIBS_DIRS})
    if (IS_DIRECTORY "${FREESWITCH_LIB_DIR}/include")
        list(APPEND FREESWITCH_LIBS_IDE_INCLUDE_DIRS "${FREESWITCH_LIB_DIR}/include")
    endif()
    if (IS_DIRECTORY "${FREESWITCH_LIB_DIR}/src")
        list(APPEND FREESWITCH_LIBS_IDE_INCLUDE_DIRS "${FREESWITCH_LIB_DIR}/src")
    endif()
    if (IS_DIRECTORY "${FREESWITCH_LIB_DIR}/src/include")
        list(APPEND FREESWITCH_LIBS_IDE_INCLUDE_DIRS "${FREESWITCH_LIB_DIR}/src/include")
    endif()
endforeach()
list(REMOVE_DUPLICATES FREESWITCH_LIBS_IDE_INCLUDE_DIRS)

add_library(freeswitch_ide STATIC EXCLUDE_FROM_ALL
        ${FREESWITCH_IDE_HEADERS}
        ${FREESWITCH_IDE_SOURCES})
target_sources(freeswitch_ide PRIVATE
        ${FREESWITCH_LIBS_IDE_HEADERS}
        ${FREESWITCH_LIBS_IDE_SOURCES})
target_include_directories(freeswitch_ide PRIVATE
        ${CMAKE_SOURCE_DIR}/examples/fs/src/include
        ${SW_INCLUDE_DIRS}
        ${SOFIA_INCLUDE_DIRS}
        ${SPANDSP_INCLUDE_DIRS}
        ${FREESWITCH_LIBS_IDE_INCLUDE_DIRS})
target_compile_options(freeswitch_ide PRIVATE
        ${SW_CFLAGS}
        ${SOFIA_CFLAGS}
        ${SPANDSP_CFLAGS})

configure_file(tests/config.h.in tests/config.h)
