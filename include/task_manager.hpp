#pragma once  
#include <string>  
#include <vector>  

enum class Priority { Low, Medium, High };  

struct Task {  
   int id = 0;  
   std::string description;  
   bool completed = false;
   Priority priority = Priority::Low;
};  

class TaskManager {  
public:  
   void loadFromFile(const std::string& filename);  
   void saveToFile(const std::string& filename);  

   void editTask(int id, const std::string& newDescription);  
   void addTask(const std::string& description, Priority priority);  
   void listTasks() const;  
   void completeTask(int id);  
   void deleteTask(int id);  

private:  
   std::vector<Task> tasks;  
   int nextId = 1;  
};