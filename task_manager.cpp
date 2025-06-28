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

// --- Milestone ---
Milestone Milestone::from_json(const json& j) {
    Milestone m;
    m.id = j.value("id", 0);
    m.description = j.value("description", "");
    m.startDate = j.value("startDate", "");
    m.endDate = j.value("endDate", "");
    m.goalId = j.value("goalId", 0);
    return m;
}
json Milestone::to_json() const {
    return { {"id", id}, {"description", description}, {"startDate", startDate}, {"endDate", endDate}, {"goalId", goalId} };
}

// --- Task ---
Task Task::from_json(const json& j) {
    Task t;
    t.id = j.value("id", 0);
    t.description = j.value("description", "");
    t.priority = static_cast<Priority>(j.value("priority", 0));
    t.dueDate = j.value("dueDate", "");
    t.completed = j.value("completed", false);
    t.milestoneId = j.value("milestoneId", 0);
    return t;
}
json Task::to_json() const {
    return {
        {"id", id},
        {"description", description},
        {"priority", static_cast<int>(priority)},
        {"dueDate", dueDate},
        {"completed", completed},
        {"milestoneId", milestoneId}
    };
}

// --- TaskManager ---
TaskManager::TaskManager()
    : lastGoalId(0), lastMilestoneId(0), lastTaskId(0)
{
    goal = {0, "", ""};
}

void TaskManager::loadFromFile(const std::string& filename) {
    std::ifstream in(filename);
    if (!in.is_open()) return;

    json j;
    in >> j;

    lastGoalId = j.value("lastGoalId", 0);
    lastMilestoneId = j.value("lastMilestoneId", 0);
    lastTaskId = j.value("lastTaskId", 0);

    // Goal
    if (j.contains("goal")) {
        goal = Goal::from_json(j["goal"]);
    } else {
        goal = {0, "", ""};
    }

    // Milestones
    milestones.clear();
    for (const auto& m : j["milestones"]) {
        milestones.push_back(Milestone::from_json(m));
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
    j["lastMilestoneId"] = lastMilestoneId;
    j["lastTaskId"] = lastTaskId;
    j["goal"] = goal.to_json();
    j["milestones"] = json::array();
    for (const auto& m : milestones) j["milestones"].push_back(m.to_json());
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

// --- Milestone ---
void TaskManager::addMilestone(const Milestone& m) {
    Milestone ms = m;
    lastMilestoneId++;
    ms.id = lastMilestoneId;
    ms.goalId = goal.id;
    milestones.push_back(ms);
}
void TaskManager::editMilestone(int id, const Milestone& m) {
    for (auto& ms : milestones) {
        if (ms.id == id) {
            ms.description = m.description;
            ms.startDate = m.startDate;
            ms.endDate = m.endDate;
            break;
        }
    }
}
std::vector<Milestone> TaskManager::getMilestones() const {
    return milestones;
}
Milestone TaskManager::getMilestoneById(int id) const {
    for (const auto& m : milestones)
        if (m.id == id) return m;
    return {0, "", "", "", 0};
}

// --- Task ---
void TaskManager::addTask(const std::string& description, Priority priority, const std::string& dueDate, int milestoneId) {
    lastTaskId++;
    Task t;
    t.id = lastTaskId;
    t.description = description;
    t.priority = priority;
    t.dueDate = dueDate;
    t.completed = false;
    t.milestoneId = milestoneId;
    tasks.push_back(t);
}
void TaskManager::editTask(int id, const std::string& newDescription, Priority prio, const std::string& dueDate, int milestoneId) {
    for (auto& t : tasks) {
        if (t.id == id) {
            t.description = newDescription;
            t.priority = prio;
            t.dueDate = dueDate;
            t.milestoneId = milestoneId;
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
std::vector<Task> TaskManager::getTasksForMilestone(int milestoneId) const {
    std::vector<Task> result;
    for (const auto& t : tasks)
        if (t.milestoneId == milestoneId) result.push_back(t);
    return result;
}
