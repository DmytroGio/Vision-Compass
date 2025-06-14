#pragma once
#include <string>
#include <vector>

struct Task {
	int id;
	std::string description;
	bool completed;
};

class TaskManager {
public:
	void loadFromFile(const std::string& filename);
	void saveToFile(const std::string& filename);

	void addTask(const std::string& description);
	void listTasks() const;
	void completeTask(int id);
	void deleteTask(int id);

private:
	std::vector<Task> tasks;
	int nextId = 1;

};