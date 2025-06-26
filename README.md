# 📝 Task Manager (Qt + C++)

A simple cross-platform **task manager** written in C++ with a Qt-based graphical interface.

---

## ✨ Features

- ✅ Add tasks with description, priority, and due date
- 📋 View all tasks in a convenient list
- 📝 Mark tasks as completed
- 🗑️ Delete tasks (planned)
- 💾 Save/load tasks to/from `tasks.json`
- 👤 User authentication (login & registration, planned for future UI)
- 🖥️ Intuitive graphical user interface (Qt 6)

---

## 🛠️ Build Instructions

### 🔧 With CMake (cross-platform)

```bash
git clone https://github.com/DdmytroGio/task-manager-cli.git
cd task-manager-cli
mkdir build && cd build
cmake ..
cmake --build .
```

### 🧱 With Qt Creator (recommended)

1. Open the `task-manager-cli.pro` or `CMakeLists.txt` in **Qt Creator** (Qt 6.9+ recommended)
2. Click **Configure Project**
3. Click **Build** and then **Run**

---

## 🚀 Usage

- Start the application.  
- Add tasks using the UI form (description, due date, priority).
- Tasks are displayed in the list below the form.
- Tasks are saved automatically in `tasks.json` (in the app directory).

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 🗒️ Notes

- CLI mode is now deprecated; all management happens via the Qt UI.
- For development or issues, please open an [issue](https://github.com/DdmytroGio/task-manager-cli/issues).