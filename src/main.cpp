#include "task_manager.hpp"
#include <iostream>

void printHelp() {
    std::cout << "Commands:\n"
              << " add <description>        Add a task\n"
              << " list                     Show tasks\n"
              << " done <id>                Mark task as done\n"
              << " del <id>                 Delete task\n"
              << " help                     Show help\n"
              << " exit                     Exit program\n";
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

        if (command._Starts_with("add ")){
            manager.addTask(command.substr(4));
        }
        else if (command == "list") {
            manager.listTasks();
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
