#include "task_manager.hpp"
#include <fstream>
#include <algorithm>
using json = nlohmann::json;

// --- Goal ---
Goal Goal::from_json(const json& j) {
    Goal g;
    g.id = j.value("id", 0);
    g.description = j.value("description", "");
    g.targetDate = j.value("targetDate", "");
    return g;
}
json Goal::to_json() const {
    return { {"id", id}, {"description", description}, {"targetDate", targetDate} };
}

// --- SubGoal ---
SubGoal SubGoal::from_json(const json& j) {
    SubGoal sg;
    sg.id = j.value("id", 0);
    sg.description = j.value("description", "");
    sg.startDate = j.value("startDate", "");
    sg.endDate = j.value("endDate", "");
    sg.goalId = j.value("goalId", 0);
    return sg;
}
json SubGoal::to_json() const {
    return { {"id", id}, {"description", description}, {"startDate", startDate}, {"endDate", endDate}, {"goalId", goalId} };
}

// --- Task ---
Task Task::from_json(const json& j) {
    Task t;
    t.id = j.value("id", 0);
    t.description = j.value("description", "");
    t.dueDate = j.value("dueDate", "");
    t.completed = j.value("completed", false);
    t.subGoalId = j.value("subGoalId", 0);
    return t;
}
json Task::to_json() const {
    return {
        {"id", id},
        {"description", description},
        {"dueDate", dueDate},
        {"completed", completed},
        {"subGoalId", subGoalId}
    };
}

// --- TaskManager ---
TaskManager::TaskManager()
    : lastGoalId(0), lastSubGoalId(0), lastTaskId(0)
{
    goal = {0, "", ""};
}

void TaskManager::loadFromFile(const std::string& filename) {
    std::ifstream in(filename);
    if (!in.is_open()) return;

    json j;
    in >> j;

    lastGoalId = j.value("lastGoalId", 0);
    lastSubGoalId = j.value("lastSubGoalId", 0);
    lastTaskId = j.value("lastTaskId", 0);

    // Goal
    if (j.contains("goal")) {
        goal = Goal::from_json(j["goal"]);
    } else {
        goal = {0, "", ""};
    }

    // SubGoals
    subGoals.clear();
    for (const auto& sg : j["subGoals"]) {
        subGoals.push_back(SubGoal::from_json(sg));
    }
    // Tasks
    tasks.clear();
    for (const auto& t : j["tasks"]) {
        tasks.push_back(Task::from_json(t));
    }
}

void TaskManager::saveToFile(const std::string& filename) const {
    json j;
    j["lastGoalId"] = lastGoalId;
    j["lastSubGoalId"] = lastSubGoalId;
    j["lastTaskId"] = lastTaskId;
    j["goal"] = goal.to_json();
    j["subGoals"] = json::array();
    for (const auto& sg : subGoals) j["subGoals"].push_back(sg.to_json());
    j["tasks"] = json::array();
    for (const auto& t : tasks) j["tasks"].push_back(t.to_json());
    std::ofstream out(filename);
    out << j.dump(4);
}

// --- Goal ---
void TaskManager::setGoal(const Goal& g) {
    goal = g;
    if (goal.id == 0) {
        lastGoalId++;
        goal.id = lastGoalId;
    }
}
Goal TaskManager::getGoal() const {
    return goal;
}

// --- SubGoal ---
void TaskManager::addSubGoal(const SubGoal& sg) {
    SubGoal s = sg;
    lastSubGoalId++;
    s.id = lastSubGoalId;
    s.goalId = goal.id;
    subGoals.push_back(s);
}

void TaskManager::editSubGoal(int id, const SubGoal& sg) {
    for (auto& s : subGoals) {
        if (s.id == id) {
            s.description = sg.description;
            s.startDate = sg.startDate;
            s.endDate = sg.endDate;
            break;
        }
    }
}

void TaskManager::deleteSubGoal(int id) {
    // Remove the subgoal
    subGoals.erase(
        std::remove_if(subGoals.begin(), subGoals.end(),
                       [id](const SubGoal& sg){ return sg.id == id; }),
        subGoals.end()
        );

    // Remove all tasks associated with this subgoal
    tasks.erase(
        std::remove_if(tasks.begin(), tasks.end(),
                       [id](const Task& t){ return t.subGoalId == id; }),
        tasks.end()
        );
}

std::vector<SubGoal> TaskManager::getSubGoals() const {
    return subGoals;
}

SubGoal TaskManager::getSubGoalById(int id) const {
    for (const auto& s : subGoals)
        if (s.id == id) return s;
    return {0, "", "", "", 0};
}

// --- Task ---
void TaskManager::addTask(const std::string& description, const std::string& dueDate, int subGoalId) {
    lastTaskId++;
    Task t;
    t.id = lastTaskId;
    t.description = description;
    t.dueDate = dueDate;
    t.completed = false;
    t.subGoalId = subGoalId;
    tasks.push_back(t);
}

void TaskManager::editTask(int id, const std::string& newDescription, const std::string& dueDate, int subGoalId) {
    for (auto& t : tasks) {
        if (t.id == id) {
            t.description = newDescription;
            t.dueDate = dueDate;
            t.subGoalId = subGoalId;
            break;
        }
    }
}

void TaskManager::completeTask(int id) {
    for (auto& t : tasks)
        if (t.id == id) {
            t.completed = true;
            break;
        }
}

void TaskManager::deleteTask(int id) {
    tasks.erase(std::remove_if(tasks.begin(), tasks.end(),
                               [id](const Task& t){ return t.id == id; }), tasks.end());
}

std::vector<Task> TaskManager::getTasks() const {
    return tasks;
}

std::vector<Task> TaskManager::getTasksForSubGoal(int subGoalId) const {
    std::vector<Task> result;
    for (const auto& t : tasks)
        if (t.subGoalId == subGoalId) result.push_back(t);
    return result;
}
