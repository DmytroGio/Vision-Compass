# 🧭 Vision Compass (Qt + C++)

A minimalist, cross-platform **goal and task navigation tool** built with C++ and Qt.

**Vision Compass** helps you align your daily actions with long-term visions and core values. It’s more than a task manager — it’s your personal clarity dashboard.

---

## ✨ Features

Based on the project's current state, Vision Compass offers the following capabilities:

* **Main Goal Management**:
    * Set and edit your primary long-term goal with a description and a target date.
    * View your current main goal prominently displayed in the UI.
* **Sub-Goal Organization (formerly Milestones)**:
    * Organize medium-term sub-goals under your main goal.
    * Add new sub-goals via a dedicated dialog.
    * Edit existing sub-goals (rename).
    * Delete sub-goals with a confirmation prompt.
    * Select a sub-goal to view its associated tasks.
    * Sub-goals are displayed in a horizontal scrollable list with visual indicators for selection.
* **Task Management**:
    * Add new tasks to the currently selected sub-goal.
    * Edit existing tasks (update description).
    * Delete tasks.
    * Mark tasks as completed.
    * Tasks are displayed in a list, showing their completion status.
* **Data Persistence**: All goals, sub-goals, and tasks are automatically saved to and loaded from a `tasks.json` file, ensuring your data is persistent across sessions.
* **User Interface**:
    * Built with Qt/QML for a modern, cross-platform graphical user interface.
    * Features a clean, minimalist design focused on clarity, including a visual "compass" element.
    * Interactive elements for editing goals, and managing sub-goals and tasks.
* **Core Logic**: Implemented in C++ using a `TaskManager` for data handling and an `AppViewModel` to expose data and methods to the QML frontend.
* **Language**: Fully English interface and codebase.

---

## 🛠️ Build Instructions

### 🔧 With CMake (cross-platform)

```bash
git clone [https://github.com/DmytroGio/vision-compass.git](https://github.com/DmytroGio/vision-compass.git)
cd vision-compass
mkdir build && cd build
cmake ..
cmake --build .
The project uses CMake for building. It requires Qt6 or Qt5 components including Widgets, Qml, Quick, and QuickControls2. It compiles main.cpp, appviewmodel.cpp, appviewmodel.h, task_manager.cpp, task_manager.hpp, user.hpp, json.hpp, and resources.qrc. A QML module task-manager-qml is created with URI VisionCompass and VERSION 1.0, including Main.qml and Screen01.qml.

🧱 With Qt Creator (recommended)
Open vision-compass.pro or CMakeLists.txt in Qt Creator (Qt 6.9+ recommended)

Click Configure Project

Click Build and then Run

🚀 Usage
Launch the application.

Set your main goal with a description and target date.

Add sub-goals (medium-term stages) under your main goal.

Select a sub-goal to view and add tasks related to it (with description and due date).

Mark tasks as completed.

All data is saved automatically in tasks.json in the application directory.

📄 License
This project is licensed under the MIT License.

🗒️ Notes
The CLI mode is deprecated. All planning and task management happens via the Qt interface.

The UI and codebase are now fully in English.

Contributions and suggestions welcome — please open an issue or submit a pull request.