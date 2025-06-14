cmake_minimum_required(VERSION 3.10)
project(TaskManagerCLI)

set(CMAKE_CXX_STANDARD 17)


include_directories(include)


add_executable(TaskManagerCLI
    src/main.cpp
    src/task_manager.cpp
)
