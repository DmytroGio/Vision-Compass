#pragma once
#include <string>
#include <vector>
#include "json.hpp"
using nlohmann::json;

// Main goal structure
struct Goal {
    int id;
    std::string description;
    std::string targetDate;
    static Goal from_json(const nlohmann::json&);
    nlohmann::json to_json() const;
};

// SubGoal structure (was Milestone)
struct SubGoal {
    int id;
    std::string description;
    std::string startDate;
    std::string endDate;
    int goalId;
    static SubGoal from_json(const nlohmann::json&);
    nlohmann::json to_json() const;
};

// Task structure WITHOUT priority field
struct Task {
    int id;
    std::string description;
    std::string dueDate;
    bool completed;
    int subGoalId; // renamed from milestoneId
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

    // SubGoals
    void addSubGoal(const SubGoal& sg);
    void editSubGoal(int id, const SubGoal& sg);
    std::vector<SubGoal> getSubGoals() const;
    SubGoal getSubGoalById(int id) const;

    // Tasks
    void addTask(const std::string& description, const std::string& dueDate, int subGoalId);
    void editTask(int id, const std::string& newDescription, const std::string& dueDate, int subGoalId);
    void completeTask(int id);
    void deleteTask(int id);
    std::vector<Task> getTasks() const;
    std::vector<Task> getTasksForSubGoal(int subGoalId) const;

private:
    int lastGoalId;
    int lastSubGoalId;
    int lastTaskId;

    Goal goal;
    std::vector<SubGoal> subGoals;
    std::vector<Task> tasks;
};
