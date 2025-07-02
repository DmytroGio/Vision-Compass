# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Release")
  file(REMOVE_RECURSE
  "CMakeFiles\\task-manager-qml_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\task-manager-qml_autogen.dir\\ParseCache.txt"
  "CMakeFiles\\task-manager-qmlplugin_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\task-manager-qmlplugin_autogen.dir\\ParseCache.txt"
  "CMakeFiles\\task-manager_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\task-manager_autogen.dir\\ParseCache.txt"
  "task-manager-qml_autogen"
  "task-manager-qmlplugin_autogen"
  "task-manager_autogen"
  )
endif()
