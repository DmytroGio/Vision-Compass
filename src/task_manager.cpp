#include "task_manager.hpp"
#include <fstream>
#include <iostream>

void TaskManager::loadFromFile(const std::string& filename)
{
	tasks.clear();
	std::ifstream file(filename);
	if (!file.is_open()) return;

	Task task;
    int priorityInt;
    while (file >> task.id >> task.completed >> priorityInt) {
        task.priority = static_cast<Priority>(priorityInt);
        file.ignore();
        std::getline(file, task.description);
        tasks.push_back(task);
        nextId = std::max(nextId, task.id + 1);
    }
}

void TaskManager::saveToFile(const std::string& filename)
{
	std::ofstream file(filename);
	for (const auto& task : tasks) {
        file << task.id << " " << task.completed << " " << static_cast<int>(task.priority) << " " << task.description << "\n";
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

void TaskManager::addTask(const std::string& description, Priority priority = Priority::Medium)
{
    tasks.push_back({ nextId++, description, false, priority });
}

void TaskManager::listTasks() const
{
    auto priorityToString = [](Priority p) {
        switch (p) {
            case Priority::Low: return "Low";
            case Priority::Medium: return "Medium";
            case Priority::High: return "High";
            default: return "Unknown";
        }
    };

    for (const auto& task : tasks) {
        std::cout << "[" << (task.completed ? "x" : " ") << "] "
                  << task.id << ": " << task.description
                  << " (Priority: " << priorityToString(task.priority) << ")\n";
    }
}

void TaskManager::completeTask(int id)
{
	for (auto& task : tasks) {
		if (task.id == id) {
			task.completed = true;
			break;
		}
	}
}

void TaskManager::deleteTask(int id)
{
	tasks.erase(std::remove_if(tasks.begin(), tasks.end(),
		[id](const Task& task) { return task.id == id; }), tasks.end());
}
