#include "task_manager.hpp"
#include <fstream>
#include <iostream>

void TaskManager::loadFromFile(const std::string& filename)
{
	tasks.clear();
	std::ifstream file(filename);
	if (!file.is_open()) return;

	Task task;
	while (file >> task.id >> task.completed) {
		file.ignore(); //space
		std::getline(file, task.description);
		tasks.push_back(task);
		nextId = std::max(nextId, task.id + 1);
	}
}

void TaskManager::saveToFile(const std::string& filename)
{
	std::ofstream file(filename);
	for (const auto& task : tasks) {
		file << task.id << " " << task.completed << " " << task.description << "\n";
	}
}

void TaskManager::addTask(const std::string& description)
{
	tasks.push_back({ nextId++, description, false });
}

void TaskManager::listTasks() const
{
	for (const auto& task : tasks) {
		std::cout << "[" << (task.completed ? "x" : " ") << "] "
			<< task.id << ": " << task.description << "\n";
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
