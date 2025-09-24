# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Release")
  file(REMOVE_RECURSE
  "CMakeFiles\\VisionCompass-qml_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\VisionCompass-qml_autogen.dir\\ParseCache.txt"
  "CMakeFiles\\VisionCompass-qmlplugin_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\VisionCompass-qmlplugin_autogen.dir\\ParseCache.txt"
  "CMakeFiles\\VisionCompass_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\VisionCompass_autogen.dir\\ParseCache.txt"
  "VisionCompass-qml_autogen"
  "VisionCompass-qmlplugin_autogen"
  "VisionCompass_autogen"
  )
endif()
