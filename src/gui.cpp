#include <SFML/Graphics.hpp>
#include <SFML/Window.hpp>
#include <SFML/System.hpp> // Ensure SFML System is included for font loading
#include <vector>
#include <string>
#include <json.hpp> // Include nlohmann/json for JSON serialization

enum class Priority {
    Low,
    Medium,
    High
};

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
        t.dueDate = j.at("dueDate").get<std::string>();
        t.completed = j.at("completed").get<bool>();
        return t;
    }
    nlohmann::json to_json() const {
        nlohmann::json j;
        j["id"] = id;
        j["description"] = description;
        j["dueDate"] = dueDate;
        j["completed"] = completed;
        return j;
    }
};

int run_gui() {
    {
        sf::RenderWindow window(sf::VideoMode({ 200, 200 }), "SFML works!");
        sf::CircleShape shape(100.f);
        shape.setFillColor(sf::Color::Green);

        while (window.isOpen())
        {
            while (const std::optional event = window.pollEvent())
            {
                if (event->is<sf::Event::Closed>())
                    window.close();
            }

            window.clear();
            window.draw(shape);
            window.display();
        }
    }
    return 0;
}
