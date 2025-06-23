#include <SFML/Graphics.hpp>
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
    static Task from_json(const nlohmann::json& j);
    nlohmann::json to_json() const;
};

int run_gui() {
    sf::RenderWindow window(sf::VideoMode(600, 400), "Task Manager GUI (SFML)");
    sf::Font font;
    if (!font.loadFromFile("arial.ttf")) { // Ensure this font file is available
        return -1; // Exit if the font file cannot be loaded
    }

    std::vector<Task> tasks = {
        {1, "Buy groceries", Priority::Medium, "2023-09-01", false},
        {2, "Finish project", Priority::High, "2023-08-15", false},
        {3, "Call Alice", Priority::Low, "2023-08-10", true}
    };

    while (window.isOpen()) {
        sf::Event event;
        while (window.pollEvent(event)) {
            if (event.type == sf::Event::Closed) {
                window.close();
            }
        }
        window.clear(sf::Color::White);

        float y = 20.f;
        for (const auto& task : tasks) {
            sf::Text text;
            text.setFont(font);
            text.setString(std::to_string(task.id) + ": " + task.description);
            text.setCharacterSize(20);
            text.setFillColor(sf::Color::Black);
            text.setPosition(20.f, y);
            window.draw(text);
            y += 30.f;
        }

        window.display();
    }
    return 0;
}