cmake_minimum_required(VERSION 3.16)

project(task-manager VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Widgets Qml Quick QuickControls2)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Widgets Qml Quick QuickControls2)

set(PROJECT_SOURCES
        main.cpp
        mainwindow.cpp
        mainwindow.h
        appviewmodel.cpp
        appviewmodel.h
        task_manager.cpp
        task_manager.hpp
        user.hpp
        json.hpp
        resources.qrc
)

# Create a resource file for QML
set(CMAKE_AUTORCC ON)
qt_add_qml_module(task-manager-qml
    URI VisionCompass
    VERSION 1.0
    QML_FILES Main.qml Screen01.qml
    # Add other QML files here if needed
)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(task-manager
        MANUAL_FINALIZATION
        ${PROJECT_SOURCES}
    )
# Define target properties for Android with Qt 6 as:
#    set_property(TARGET task-manager APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
#                 ${CMAKE_CURRENT_SOURCE_DIR}/android)
# For more information, see https://doc.qt.io/qt-6/qt-add-executable.html#target-creation
else()
    if(ANDROID)
        add_library(task-manager SHARED
            ${PROJECT_SOURCES}
        )
# Define properties for Android with Qt 5 after find_package() calls as:
#    set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
    else()
        add_executable(task-manager
            ${PROJECT_SOURCES}
        )
    endif()
endif()

target_link_libraries(task-manager PRIVATE Qt${QT_VERSION_MAJOR}::Widgets Qt${QT_VERSION_MAJOR}::Qml Qt${QT_VERSION_MAJOR}::Quick Qt${QT_VERSION_MAJOR}::QuickControls2 task-manager-qml)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
if(${QT_VERSION} VERSION_LESS 6.1.0)
  set(BUNDLE_ID_OPTION MACOSX_BUNDLE_GUI_IDENTIFIER com.example.task-manager)
endif()
set_target_properties(task-manager PROPERTIES
    ${BUNDLE_ID_OPTION}
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

include(GNUInstallDirs)
install(TARGETS task-manager
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

if(QT_VERSION_MAJOR EQUAL 6)
    qt_finalize_executable(task-manager)
endif()
