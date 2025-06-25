#pragma once  
#include <string>  
#include <vector>  
#include <stack>
#include "json.hpp"
#include "user.hpp"
using nlohmann::json;

enum class Priority { Low, Medium, High };  

struct Task {
    int id;
    std::string description;
    Priority priority;
    std::string dueDate;
    bool completed;

    static Task from_json(const nlohmann::json& j) {
        Task t;
        t.id = j.at("id").get<int>();
        t.description = j.at("description").get<std::string>();
        t.priority = static_cast<Priority>(j.at("priority").get<int>());
        t.dueDate = j.at("dueDate").get<std::string>();
        t.completed = j.at("completed").get<bool>();
        return t;
    }

    nlohmann::json to_json() const {
        return {
            {"id", id},
            {"description", description},
            {"priority", static_cast<int>(priority)},
            {"dueDate", dueDate},
            {"completed", completed}
        };
    }
};

class TaskManager {  
public:  
   TaskManager();
   void loadFromFile(const std::string& filename);
   void saveToFile(const std::string& filename) const; 

   void editTask(int id, const std::string& newDescription); 
   void addTask(const std::string& description, Priority priority, const std::string& dueDate);
   void listTasks() const;  
   void completeTask(int id);  
   void deleteTask(int id);

   void sortByPriority();
   void listTasksByPriority(Priority priority) const;
   void sortByDueDate();
   void listTasksByDueDate(const std::string& dueDate) const;
   void listTasksByDateRange(const std::string& startDate, const std::string& endDate) const;

   void searchTasks(const std::string& keyword) const;

   void saveStateForUndo();

   void undo();
   void redo();


   bool registerUser(const std::string& username, const std::string& password);
   bool loginUser(const std::string& username, const std::string& password);
   std::string getCurrentUser() const;

private:  
    std::vector<User> users;
    std::string currentUser;

   std::vector<Task> tasks;  
   int nextId = 1;  
   std::stack<std::vector<Task>> undoStack;
   std::stack<std::vector<Task>> redoStack;
   int lastId = 0; // <-- Add this line
};
