cmake_minimum_required(VERSION 3.10)
project(TaskManagerCLI)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Automatically include all .cpp files in src/
file(GLOB SOURCES "src/*.cpp")

# Define the executable target FIRST
add_executable(TaskManagerCLI ${SOURCES})

# Now that the target is defined, we can specify its properties:
# Add include directory for SFML headers (manual path)
target_include_directories(TaskManagerCLI PRIVATE
    ${CMAKE_SOURCE_DIR}/external/SFML-3.0.0/include
    ${CMAKE_SOURCE_DIR}/include # For your own headers
)

# Add SFML library directory (manual path)
target_link_directories(TaskManagerCLI PRIVATE
    ${CMAKE_SOURCE_DIR}/external/SFML-3.0.0/lib
)

# Define SFML_STATIC for static linking
target_compile_definitions(TaskManagerCLI PRIVATE SFML_STATIC)

# Link SFML libraries (using manual names, compatible with SFML 3.x pre-built binaries)
target_link_libraries(TaskManagerCLI PRIVATE
    sfml-graphics-s-d # For Debug/Static linking, if you use static SFML.
    sfml-window-s-d
    sfml-system-s-d
    opengl32
    freetype
    winmm
    gdi32
    user32
    advapi32
)

# (Optional) Set output directory for DLLs for easier debugging
# This makes sure the executable and SFML DLLs are in the same folder.
set_target_properties(TaskManagerCLI PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
)

# Important: If you download SFML 3.x pre-built binaries, check the naming convention for .lib files.
# They might be sfml-graphics-s-d.lib (static debug), sfml-graphics-d.lib (dynamic debug), etc.
# Adjust target_link_libraries accordingly.
