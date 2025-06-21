#pragma once  
#include <string>  
#include <vector>  
#include <stack>
#include <json.hpp>
using nlohmann::json;

enum class Priority { Low, Medium, High };  

struct Task {  
   int id = 0;  
   std::string description;  
   bool completed = false;
   Priority priority = Priority::Low;
   std::string dueDate;

   // JSON serialization
   friend void to_json(json& j, const Task& t) {
       j = json{
           {"id", t.id},
           {"description", t.description},
           {"completed", t.completed},
           {"priority", static_cast<int>(t.priority)},
           {"dueDate", t.dueDate}
       };
   }
   friend void from_json(const json& j, Task& t) {
       j.at("id").get_to(t.id);
       j.at("description").get_to(t.description);
       j.at("completed").get_to(t.completed);
       int p;
       j.at("priority").get_to(p);
       t.priority = static_cast<Priority>(p);
       j.at("dueDate").get_to(t.dueDate);
   }
};  

class TaskManager {  
public:  
   void loadFromFile(const std::string& filename);  
   void saveToFile(const std::string& filename);  

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

private:  
   std::vector<Task> tasks;  
   int nextId = 1;  
   std::stack<std::vector<Task>> undoStack;
   std::stack<std::vector<Task>> redoStack;
};