cmake_minimum_required(VERSION 3.10)
project(TaskManagerCLI)

set(CMAKE_CXX_STANDARD 17)

# Automatically include all .cpp files in src/
file(GLOB SOURCES "src/*.cpp")

add_executable(TaskManagerCLI ${SOURCES})

# Add include directory for headers
target_include_directories(TaskManagerCLI PRIVATE
    ${CMAKE_SOURCE_DIR}/external/SFML-3.0.0/include
    ${CMAKE_SOURCE_DIR}/include
)

# Add SFML library directory
target_link_directories(TaskManagerCLI PRIVATE
    ${CMAKE_SOURCE_DIR}/external/SFML-3.0.0/lib
)

# Link libraries to the target
target_link_libraries(TaskManagerCLI
    sfml-graphics
    sfml-window
    sfml-system
)