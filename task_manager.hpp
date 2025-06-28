#pragma once
#include <string>
#include <vector>
//#include <stack>
#include "json.hpp"
//#include "user.hpp"
using nlohmann::json;

enum class Priority { Low, Medium, High };

struct Goal {
    int id;
    std::string description;
    std::string targetDate;
    static Goal from_json(const nlohmann::json&);
    nlohmann::json to_json() const;
};

struct Milestone {
    int id;
    std::string description;
    std::string startDate;
    std::string endDate;
    int goalId;
    static Milestone from_json(const nlohmann::json&);
    nlohmann::json to_json() const;
};

struct Task {
    int id;
    std::string description;
    Priority priority;
    std::string dueDate;
    bool completed;
    int milestoneId;
    static Task from_json(const nlohmann::json&);
    nlohmann::json to_json() const;
};

class TaskManager {
public:
    TaskManager();

    void loadFromFile(const std::string& filename);
    void saveToFile(const std::string& filename) const;

    // Goal
    void setGoal(const Goal& g);
    Goal getGoal() const;

    // Milestones
    void addMilestone(const Milestone& m);
    void editMilestone(int id, const Milestone& m);
    std::vector<Milestone> getMilestones() const;
    Milestone getMilestoneById(int id) const;

    // Tasks
    void addTask(const std::string& description, Priority priority, const std::string& dueDate, int milestoneId);
    void editTask(int id, const std::string& newDescription, Priority prio, const std::string& dueDate, int milestoneId);
    void completeTask(int id);
    void deleteTask(int id);
    std::vector<Task> getTasks() const;
    std::vector<Task> getTasksForMilestone(int milestoneId) const;

private:
    int lastGoalId;
    int lastMilestoneId;
    int lastTaskId;

    Goal goal;
    std::vector<Milestone> milestones;
    std::vector<Task> tasks;
};
