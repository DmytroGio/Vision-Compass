# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles\\task-manager_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\task-manager_autogen.dir\\ParseCache.txt"
  "task-manager_autogen"
  )
endif()
