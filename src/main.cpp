#include "task_manager.hpp"
#include <iostream>

void printHelp() {
    std::cout << "Commands:\n"
        << " add <description> /p <priority> /d <YYYY-MM-DD>    Add a task (priority: Low, Medium, High)\n"
        << " edit <id> <description>                            Edit a task\n"
        << " list                                               Show tasks sorted by priority\n"
        << " listp <priority>                                   List tasks by priority (Low, Medium, High)\n"
        << " listd                                              Show tasks sorted by due date\n"
        << " listdate <YYYY-MM-DD>                              List tasks by due date\n"
        << " listrange <start> <end>                            List tasks by date range\n"
        << " done <id>                                          Mark task as done\n"
        << " del <id>                                           Delete task\n"
        << " search <keyword>                                   Search tasks by keyword\n"
        << " undo                                               Undo last action <-\n"
        << " redo                                               Redo last undone action ->\n"
        << " help                                               Show help\n"
        << " exit                                               Exit program\n";

}

bool isValidDateFormat(const std::string& date) {
    if (date.size() != 10) return false;
    if (date[4] != '-' || date[7] != '-') return false;
    for (size_t i = 0; i < date.size(); ++i) {
        if (i == 4 || i == 7) continue;
        if (!isdigit(date[i])) return false;
    }

    int month = std::stoi(date.substr(5, 2));
    int day = std::stoi(date.substr(8, 2));
    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;
    return true;
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
            size_t dueDatePos = command.find(" /d ");
            if (priorityPos != std::string::npos && dueDatePos != std::string::npos) {
                std::string description = command.substr(4, priorityPos - 4);
                std::string priorityStr = command.substr(priorityPos + 4, dueDatePos - (priorityPos + 4));
                std::string dueDate = command.substr(dueDatePos + 4);

                if (!isValidDateFormat(dueDate)) {
                    std::cout << "Invalid date format. Use YYYY-MM-DD.\n";
                    continue;
                }

                Priority priority;
                if (priorityStr == "Low") priority = Priority::Low;
                else if (priorityStr == "Medium") priority = Priority::Medium;
                else if (priorityStr == "High") priority = Priority::High;
                else {
                    std::cout << "Invalid priority. Use: Low, Medium, or High.\n";
                    continue;
                }

                manager.addTask(description, priority, dueDate);
            } else {
                std::cout << "Invalid add command format. Use: add <description> /p <priority> /d <YYYY-MM-DD>\n";
            }
        }
        else if (command == "list") {
            manager.sortByPriority();
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
        else if (command._Starts_with("listp ")) {
            std::string priorityStr = command.substr(6);
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
            manager.listTasksByPriority(priority);
        }
        else if (command == "listd") {
            manager.sortByDueDate();
            manager.listTasks();
        }
        else if (command._Starts_with("listdate ")) {
            std::string dueDate = command.substr(9);
            manager.listTasksByDueDate(dueDate);
        }
        else if (command._Starts_with("listrange ")) {
            size_t spacePos = command.find(' ', 10);
            if (spacePos != std::string::npos) {
                std::string startDate = command.substr(10, spacePos - 10);
                std::string endDate = command.substr(spacePos + 1);
                manager.listTasksByDateRange(startDate, endDate);
            } else {
                std::cout << "Invalid listrange command format. Use: listrange <start> <end>\n";
            }
        }
        else if (command._Starts_with("search ")) {
            std::string keyword = command.substr(7);
            if (keyword.empty()) {
                std::cout << "Please provide a keyword to search for.\n";
                continue;
            }
            manager.searchTasks(keyword);
        }
        else if (command == "undo") {
            manager.undo();
        }
        else if (command == "redo") {
            manager.redo();
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
