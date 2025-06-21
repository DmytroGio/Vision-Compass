#include "task_manager.hpp"
#include <fstream>
#include <iostream>
#include <algorithm>
#include <json.hpp>
using nlohmann::json;

void TaskManager::loadFromFile(const std::string& filename)
{
    tasks.clear();
    std::ifstream file(filename);
    if (!file.is_open()) {
        std::cerr << "Warning: Could not open file '" << filename << "' for reading. Starting with an empty task list.\n";
        return;
    }

    try {
        json j;
        file >> j;
        tasks = j.get<std::vector<Task>>();
        // Update nextId to ensure unique IDs
        for (const auto& task : tasks)
            nextId = std::max(nextId, task.id + 1);
    } catch (const json::parse_error& e) {
        std::cerr << "Error: Failed to parse JSON in '" << filename << "': " << e.what() << "\n";
        tasks.clear();
    } catch (const std::exception& e) {
        std::cerr << "Error: Exception while loading tasks: " << e.what() << "\n";
        tasks.clear();
    }
}

void TaskManager::saveToFile(const std::string& filename)
{
    std::ofstream file(filename);
    if (!file.is_open()) {
        std::cerr << "Error: Could not open file '" << filename << "' for writing.\n";
        return;
    }

    try {
        json j = tasks;
        file << j.dump(4); // pretty print with 4 spaces
    } catch (const std::exception& e) {
        std::cerr << "Error: Exception while saving tasks: " << e.what() << "\n";
    }
}

void TaskManager::editTask(int id, const std::string& newDescription)
{
    for (auto& task : tasks) {
        if (task.id == id) {
            task.description = newDescription;
            break;
        }
    }
}

void TaskManager::addTask(const std::string& description, Priority priority, const std::string& dueDate)
{
    saveStateForUndo();
    tasks.push_back({ nextId++, description, false, priority, dueDate });
}

void TaskManager::listTasks() const
{
    for (const auto& task : tasks) {
        std::cout << "[" << (task.completed ? "x" : " ") << "] "
                  << task.id << ": " << task.description
                  << " (Priority: ";
        switch (task.priority) {
            case Priority::Low: std::cout << "Low"; break;
            case Priority::Medium: std::cout << "Medium"; break;
            case Priority::High: std::cout << "High"; break;
        }
        std::cout << ", Due: " << task.dueDate << ")\n";
    }
}

void TaskManager::completeTask(int id)
{
    saveStateForUndo();
	for (auto& task : tasks) {
		if (task.id == id) {
			task.completed = true;
			break;
		}
	}
}

void TaskManager::deleteTask(int id)
{
    saveStateForUndo();
	tasks.erase(std::remove_if(tasks.begin(), tasks.end(),
		[id](const Task& task) { return task.id == id; }), tasks.end());
}

void TaskManager::sortByPriority()
{
    std::sort(tasks.begin(), tasks.end(), [](const Task& a, const Task& b) {
        return static_cast<int>(a.priority) > static_cast<int>(b.priority);
    });
}

void TaskManager::listTasksByPriority(Priority priority) const
{
    for (const auto& task : tasks) {
        if (task.priority == priority) {
            std::cout << "[" << (task.completed ? "x" : " ") << "] "
                      << task.id << ": " << task.description
                      << " (Priority: ";
            switch (task.priority) {
                case Priority::Low: std::cout << "Low"; break;
                case Priority::Medium: std::cout << "Medium"; break;
                case Priority::High: std::cout << "High"; break;
            }
            std::cout << ")\n";
        }
    }
}

void TaskManager::sortByDueDate()
{
    std::sort(tasks.begin(), tasks.end(), [](const Task& a, const Task& b) {
        return a.dueDate < b.dueDate;
    });
}

void TaskManager::listTasksByDueDate(const std::string& dueDate) const
{
    for (const auto& task : tasks) {
        if (task.dueDate == dueDate) {
            std::cout << "[" << (task.completed ? "x" : " ") << "] "
                      << task.id << ": " << task.description
                      << " (Priority: ";
            switch (task.priority) {
                case Priority::Low: std::cout << "Low"; break;
                case Priority::Medium: std::cout << "Medium"; break;
                case Priority::High: std::cout << "High"; break;
            }
            std::cout << ", Due: " << task.dueDate << ")\n";
        }
    }
}

void TaskManager::listTasksByDateRange(const std::string& startDate, const std::string& endDate) const
{
    for (const auto& task : tasks) {
        if (task.dueDate >= startDate && task.dueDate <= endDate) {
            std::cout << "[" << (task.completed ? "x" : " ") << "] "
                      << task.id << ": " << task.description
                      << " (Priority: ";
            switch (task.priority) {
                case Priority::Low: std::cout << "Low"; break;
                case Priority::Medium: std::cout << "Medium"; break;
                case Priority::High: std::cout << "High"; break;
            }
            std::cout << ", Due: " << task.dueDate << ")\n";
        }
    }
}

void TaskManager::searchTasks(const std::string& keyword) const
{
    for (const auto& task : tasks) {
        if (task.description.find(keyword) != std::string::npos) {
            std::cout << "[" << (task.completed ? "x" : " ") << "] "
                      << task.id << ": " << task.description
                      << " (Priority: ";
            switch (task.priority) {
                case Priority::Low: std::cout << "Low"; break;
                case Priority::Medium: std::cout << "Medium"; break;
                case Priority::High: std::cout << "High"; break;
            }
            std::cout << ", Due: " << task.dueDate << ")\n";
        }
    }
}

void TaskManager::saveStateForUndo() {
    undoStack.push(tasks);
    // Clear redo stack on new action
    while (!redoStack.empty()) redoStack.pop();
}

void TaskManager::undo() {
    if (undoStack.empty()) {
        std::cout << "Nothing to undo.\n";
        return;
    }
    redoStack.push(tasks);
    tasks = undoStack.top();
    undoStack.pop();
}

void TaskManager::redo() {
    if (redoStack.empty()) {
        std::cout << "Nothing to redo.\n";
        return;
    }
    undoStack.push(tasks);
    tasks = redoStack.top();
    redoStack.pop();
}

