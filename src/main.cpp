#include "task_manager.hpp"
#include <iostream>

void printHelp() {
    std::cout << "Commands:\n"
              << " add <description> /p <priority>  Add a task (priority: Low, Medium, High)\n"
		      << " edit <id> <description>          Edit a task\n"
              << " list                             Show tasks\n"
              << " done <id>                        Mark task as done\n"
              << " del <id>                         Delete task\n"
              << " help                             Show help\n"
              << " exit                             Exit program\n";
}

int main()
{
    TaskManager manager;
    const std::string filename = "tasks.txt";
    manager.loadFromFile(filename);

    std::string command;
    printHelp();

    while (true) {
        std::cout << "> ";
        std::getline(std::cin, command);

        if (command._Starts_with("add ")) {
            size_t priorityPos = command.find(" /p ");
            if (priorityPos != std::string::npos) {
                std::string description = command.substr(4, priorityPos - 4);
                std::string priorityStr = command.substr(priorityPos + 4);

                Priority priority;
                if (priorityStr == "Low") {
                    priority = Priority::Low;
                } else if (priorityStr == "Medium") {
                    priority = Priority::Medium;
                } else if (priorityStr == "High") {
                    priority = Priority::High;
                } else {
                    std::cout << "Invalid priority. Use: Low, Medium, or High.\n";
                    continue;
                }

                manager.addTask(description, priority);
            } else {
                std::cout << "Invalid add command format. Use: add <description> /p <priority>\n";
            }
        }
        else if (command == "list") {
            manager.listTasks();
		}
		else if (command._Starts_with("edit ")) {
			size_t spacePos = command.find(' ', 5);
			if (spacePos != std::string::npos) {
				int id = std::stoi(command.substr(5, spacePos - 5));
				std::string newDescription = command.substr(spacePos + 1);
				manager.editTask(id, newDescription);
			}
			else {
				std::cout << "Invalid edit command format. Use: edit <id> <description>\n";
			}
		}
        else if (command._Starts_with("done ")) {
            manager.completeTask(std::stoi(command.substr(5)));
        }
        else if (command._Starts_with("del ")) {
            manager.deleteTask(std::stoi(command.substr(4)));
        }
        else if (command == "help") {
            printHelp();
        }
        else if (command == "exit") {
            break;
        }
        else {
            std::cout << "Unknown command\n";
        }
    }

    manager.saveToFile(filename);
    return 0;
}
