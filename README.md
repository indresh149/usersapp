# Flutter User Management App

## Project Overview

This Flutter application demonstrates a user management system built with clean code practices and robust state management. Users can browse a list of users, view their details (including posts and todos), search for specific users, and create new posts locally. The app features infinite scrolling, pagination, pull-to-refresh, offline caching, and theme switching (light/dark). It integrates with the DummyJSON API for fetching user data.

## Architecture Explanation

The application follows a clean architecture approach, loosely based on MVVM principles, with a strong emphasis on separation of concerns:

* **Presentation Layer:**
    * **UI (Screens/Widgets):** Flutter widgets responsible for rendering the UI and capturing user input.
    * **BLoC (Business Logic Component):** Manages the state of the UI and handles user interactions by processing events and emitting states. `flutter_bloc` is used for this. Each feature (user list, user detail, create post) has its own BLoC.
* **Data Layer:**
    * **Repositories:** Abstract the data sources (API, local cache) from the BLoCs. They provide a clean API for data access.
    * **DataSources:**
        * **Remote:** Handles communication with the DummyJSON API using `dio`.
        * **Local:** Manages offline caching using `hive` for users, posts, and todos.
    * **Models:** Define the data structures (User, Post, Todo).
* **Core Layer:**
    * **API Client:** Centralized HTTP client setup.
    * **Constants:** Application-wide constants.
    * **Theme Management:** Handles dynamic theme switching (light/dark) using `flutter_bloc` and `shared_preferences`.
    * **Dependency Injection:** `get_it` is used for service location, making it easy to provide and access dependencies like repositories and BLoCs.
    * **Utils:** Helper functions and utilities (e.g., logger).

**Key Principles:**
* **Single Responsibility Principle:** Each class/module has a specific responsibility.
* **Dependency Inversion:** BLoCs depend on abstractions (Repository interfaces) rather than concrete implementations.
* **State Management:** `flutter_bloc` is used for predictable state management, handling loading, success, and error states effectively.

## Setup Instructions

1.  **Prerequisites:**
    * Flutter SDK (version 3.x.x or later recommended).
    * Dart SDK (comes with Flutter).
    * An IDE like VS Code or Android Studio with Flutter plugins.

2.  **Clone the Repository:**
    ```bash
    git clone <your-repository-url>
    cd <your-project-directory>
    ```

3.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

4.  **Generate Hive Adapters (if not already generated or after model changes):**
    * Hive models (`user_model.dart`, `post_model.dart`, `todo_model.dart`) require generated part files. If you modify these models, you'll need to run:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

5.  **Run the Application:**
    * Connect a device or start an emulator/simulator.
    * Execute the following command in your project's root directory:
    ```bash
    flutter run
    ```

---

This app demonstrates best practices in Flutter development, including robust state management with BLoC, API integration, local caching for offline support, and a well-organized, maintainable codebase.




Screenshots

<img width="323" alt="Screenshot 2025-06-03 at 8 39 03 PM" src="https://github.com/user-attachments/assets/37b33450-7523-41fe-baff-12d825740038" />
<img width="323" alt="Screenshot 2025-06-03 at 8 38 51 PM" src="https://github.com/user-attachments/assets/624e23d2-f60d-4151-895f-d9313cafe4b2" />
<img width="323" alt="Screenshot 2025-06-03 at 8 38 41 PM" src="https://github.com/user-attachments/assets/2f3ecea5-57a9-44af-9776-a822f10150fb" />
<img width="323" alt="Screenshot 2025-06-03 at 8 38 32 PM" src="https://github.com/user-attachments/assets/249cd3ea-c5b4-4435-a6a7-5eb7cbf37ed4" />
<img width="323" alt="Screenshot 2025-06-03 at 8 38 14 PM" src="https://github.com/user-attachments/assets/4eb92584-95c4-4a94-8abf-c3f8bb2fff9c" />
<img width="323" alt="Screenshot 2025-06-03 at 8 38 08 PM" src="https://github.com/user-attachments/assets/c97eb3c8-7538-4b82-966e-805938d619ac" />

Video

https://github.com/user-attachments/assets/97adb9b6-c737-4ba2-a4a1-a7990de9f468



