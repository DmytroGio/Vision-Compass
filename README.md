# 🧭 Vision Compass (Qt + C++)

A minimalist, cross-platform **goal and task navigation tool** built with C++ and Qt.

**Vision Compass** helps you align your daily actions with long-term visions and core values. It’s more than a task manager — it’s your personal clarity dashboard.

---

## ✨ Features

- 🌟 Set your main long-term goal and edit it at any time
- 🗂️ Organize medium-term milestones (no progress bar) under your main goal
- 📋 Add tasks linked to specific milestones
- 📅 Specify due dates and priorities for each task
- ✅ Mark tasks as completed (planned)
- 🧭 View your main goal, milestones, and related tasks in a clean, focused layout
- 💾 All data saved/loaded from `tasks.json`
- 🖥️ Fully English interface and codebase
- 🔐 (Planned) User authentication (login & registration)

---

## 🛠️ Build Instructions

### 🔧 With CMake (cross-platform)

```bash
git clone https://github.com/DdmytroGio/vision-compass.git
cd vision-compass
mkdir build && cd build
cmake ..
cmake --build .
```

### 🧱 With Qt Creator (recommended)

1. Open `vision-compass.pro` or `CMakeLists.txt` in **Qt Creator** (Qt 6.9+ recommended)
2. Click **Configure Project**
3. Click **Build** and then **Run**

---

## 🚀 Usage

- Launch the application.
- Set your main goal with a description and target date.
- Add milestones (medium-term stages) under your goal.
- Select a milestone to view and add tasks related to it (with description, due date, and priority).
- All data is saved automatically in `tasks.json` in the app directory.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 🗒️ Notes

- The CLI mode is deprecated. All planning and task management happens via the Qt interface.
- The UI and codebase are now fully in English.
- Contributions and suggestions welcome — please open an [issue](https://github.com/DdmytroGio/vision-compass/issues).

---

> “A goal properly set is halfway reached.” – Zig Ziglar