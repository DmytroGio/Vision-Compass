#pragma once
#include <string>
#include <json.hpp>
using nlohmann::json;

struct User {
    std::string username;
    std::string passwordHash;

    static User from_json(const json& j) {
        User u;
        u.username = j.at("username").get<std::string>();
        u.passwordHash = j.at("passwordHash").get<std::string>();
        return u;
    }

    json to_json() const {
        return {
            {"username", username},
            {"passwordHash", passwordHash}
        };
    }

    // Simple hash function for demonstration (replace with a real hash in production)
    static std::string hashPassword(const std::string& password) {
        std::hash<std::string> hasher;
        return std::to_string(hasher(password));
    }
};