## 2025-06-20
### Future features ⸜(｡˃ ᵕ ˂)⸝♡
- Integration of Json format, place txt [done]
- Persistent Unique IDs? Ensure that task IDs are unique and not reused, even after deletions.
- Auto-create file.
- File encoding.
- Maybe in the future make a usable UI via SFML or something similar.
- Login via password?

## 2025-06-27
### My Next steps (with Qt)
- Intuitive UI Improvements
- Convenience Features
- Robustness & Bug Prevention
- User Management Enhancements
- Code Quality & Maintenance
- Polish & Quality-of-Life

## 2025-06-28
### Redesign UI for new Concept
- Change program name to Compass
- I'm redesigning the UI in terms of 3 forms of planning - long term, medium term, short term.
To see the global goals of life and plan according to them.
- In the process of framing the new concept and design

## 2025-06-30
### New GUI in figma
- Simplifying the overall design to minimalism
- Preparing the design for integration

## 2025-07-05
### The process of integrating a beautiful design
- Create simple options to modify objectives and sub-objectives
- Connecting backend with frontend

## 2025-07-06
### Weekly Task: The process of integrating a beautiful design
- Create a simple UI to modify objectives and sub-objectives
- Design clean layout with inline editing and basic actions (add/edit/delete)
- Implement reordering options (drag & drop or buttons)
- Style interface for clarity and minimalism
- Handle edge cases (empty fields, quick edits)

## 2025-07-13
### Weekly Task: Core Features & Bug Fixing 🛠️
- Fix SubGoal deletion: Ensure cascading deletion of associated Tasks. [done]
- Implement deletion confirmation dialog for SubGoals (and Tasks). [done]
- Mark Tasks as completed ( connect logic to the interface). [done]
- Improve design elements (create new ones in style) - top bar of the app and popups, scrollbars (now they are system-native).
- Handle initial app launch: Prompt user to set Main Goal if none exists.
- Enhance UI for selected SubGoal: Clearly highlight the active SubGoal.
- Add input validation: Prevent creation of empty SubGoals and Tasks.

## Weekly possible Tasks (July 21 - July 27) 📝 🎨
### Dialog Unification (Mon-Thu)
- Develop a reusable CustomDialog.qml component for all application dialogs (add, edit, confirm).[done]
- Integrate CustomDialog for the main goal editing dialog (editGoalDialog).[done]
- Apply CustomDialog to SubGoal and Task add/edit dialogs.
- Implement CustomDialog for SubGoal and Task deletion confirmation dialogs.
### Progress Visualization & Refinement (Fri-Sun)
- Add a simple "completed/total" task count display for each SubGoal in the QML interface, retrieved from C++.
- Conduct a comprehensive review and testing of all updated dialogs and the new progress indicator. Ensure proper AppViewModel integration.
- Future planning and analysis for the next phase of UI/UX improvements.

## 2025-07-24
- Make SubGoal permanently selected. A SubGoal must always be selected—by default, the first one when the program is launched. Without "No SubGoal Selected" [done]
- Make shortcuts for the first 9 Subgoals (numbers from 1 to 9) [done]

## 2025-07-26
- Scrollbar offset for selected shortcut Subgoal [done]

## 2025-07-30
- Change the color of the Main Task when hovering over it [done]

## 2025-08-5
- Info panel - description of the application's philosophy and hotkeys [done]
- Export, Import, Delete list [done]

## 2025-08-07
- Change the import and export settings icon [done]

## 2025-08-07
- Incorrect position offset (scrollbar moves to the top of the list or list is refreshed) after changing the status of a task at the bottom of the list to “completed/not completed.” [done]

## 2025-08-08
- The width of the scrollbar changes depending on the number of items in the list (adaptive width). [done]

## 2025-08-09
- Changes to the visual state of the Subgoal cell (possibly adding a green stroke) if all tasks in the task list have been completed. [done]

## 2025-08-17
- Fix the size of elements (task rows, yellow circle) [done]
- Raise the yellow buttons (add subgoal, info, export) [done]
- Centering buttons and descriptions [done]
- Limit the scrollbar for Tasks to the bottom window - it goes down. Fix task list container height to prevent cutoff at bottom of window [done]
- The edit and delete buttons only appear when hovering over a task [done]

- Redesign confirmation and editing windows to make them simpler and more concise  [done]

## 2025-08-21
- Does not highlight the necessary Subgoal on the LCM [done]
- Redesign of pop-ups (confirmations, additions, edits) - more stylish minimalist design. Correct markup for tooltips and input text [done]
- Shading of the program window during pop-ups - currently everything turns light white. [done]
- Fix hints in lines [done]

- Refine export correctly - file name, location. (Add a key so that we can import only our files)  [done]
- Import with file specification - Import and export have been simplified for user convenience.   [done]


- Description window more minimalistic and taking into account the new design of pop-ups.   [done]


- Adjust font sizes (main goal, subgoals smaller, titles)  [done]


## 2025-09-01
- Updated design in Figma and shortcuts written [done]
- Create shortcuts [done]
- Add shortcuts to the Info pop-up or highlight them in another convenient way. [done]

- Prepare export and presentation for Github

## 2025-09-09
- correct the layout of auxiliary dialogs (add, delete, edit, data, info)
- to formalize the presentation and ideology of the project

## 2025-09-14
- Preparation of program ideology - in the context of design and presentation

## 2025-09-16
- During the presentation design process - Figma design

## 2025-09-18
- During the presentation design process 02 - Figma design

## 2025-09-21
- During the presentation design process 03 - Figma design

## 2025-09-22
- Discussing the design and testing on other devices. Processing feedback.

## 2025-09-27
- Preparation and formatting of the release version. Finalization of the presentation design.

## 2025-09-30
- Work on portfolio presentation and design development. Publication on additional platforms.