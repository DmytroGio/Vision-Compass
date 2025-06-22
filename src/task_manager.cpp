#include "task_manager.hpp"
#include <fstream>
#include <iostream>
#include <algorithm>
#include <json.hpp>
#include <string>
#include <functional>
using json = nlohmann::json;

// Define the simpleHash function
std::string simpleHash(const std::string& input) {
    std::hash<std::string> hasher;
    return std::to_string(hasher(input));
}

TaskManager::TaskManager() : lastId(0) {}

void TaskManager::loadFromFile(const std::string& filename) {
    std::ifstream in(filename);
    if (!in.is_open()) return;

    json j;
    in >> j;

    // Handle migration from old format (array)
    if (j.is_array()) {
        tasks.clear();
        for (const auto& item : j) {
            Task t = Task::from_json(item);
            tasks.push_back(t);
            if (t.id > lastId) lastId = t.id;
        }
        users.clear();
    }
    else {
        lastId = j.value("last_id", 0);
        tasks.clear();
        for (const auto& item : j["tasks"]) {
            Task t = Task::from_json(item);
            tasks.push_back(t);
        }
        users.clear();
        if (j.contains("users")) {
            for (const auto& item : j["users"]) {
                users.push_back(User::from_json(item));
            }
        }
    }
}

void TaskManager::saveToFile(const std::string& filename) const {
    json j;
    j["last_id"] = lastId;
    j["tasks"] = json::array();
    for (const auto& t : tasks) {
        j["tasks"].push_back(t.to_json());
    }
    j["users"] = json::array();
    for (const auto& u : users) {
        j["users"].push_back(u.to_json());
    }
    std::ofstream out(filename);
    out << j.dump(4);
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
    lastId++; // Increment persistent ID
    Task t;
    t.id = lastId;
    t.description = description;
    t.priority = priority;
    t.dueDate = dueDate;
    t.completed = false;
    tasks.push_back(t);
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

bool TaskManager::registerUser(const std::string& username, const std::string& password) {
    for (const auto& user : users) {
        if (user.username == username) return false; // Already exists
    }
    User u;
    u.username = username;
    u.passwordHash = simpleHash(password);
    users.push_back(u);
    return true;
}

bool TaskManager::loginUser(const std::string& username, const std::string& password) {
    for (const auto& user : users) {
        if (user.username == username && user.passwordHash == simpleHash(password)) {
            currentUser = username;
            return true;
        }
    }
    return false;
}

std::string TaskManager::getCurrentUser() const {
    return currentUser;
}

