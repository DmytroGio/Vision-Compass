#include "task_manager.hpp"
#include <fstream>
#include <iostream>
#include <algorithm>

void TaskManager::loadFromFile(const std::string& filename)
{
	tasks.clear();
	std::ifstream file(filename);
	if (!file.is_open()) return;

	Task task;
    int priorityInt;
    while (file >> task.id >> task.completed >> priorityInt >> task.dueDate) {
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
        file << task.id << " " << task.completed << " " << static_cast<int>(task.priority)
             << " " << task.dueDate << " " << task.description << "\n";
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

