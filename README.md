### Project Scope

Build a functional Flutter application with the following requirements:

### Assessment Task: "Task Manager App"

#### Scenario:
Build a Task Manager App with the following features:

1. **User Authentication:**
   - Use a mock API or Firebase for user sign-up and login functionality.
   - Allow social login (Google).

2. **Task Management:**
   - CRUD operations (Create, Read, Update, Delete) for tasks.
   - Categorization of tasks into Work, Personal, and Others.
   - Implement due date and priority for tasks.

3. **UI/UX:**
   - Build a responsive UI supporting both light and dark themes.
   - Show a home screen with a task list organized by categories and priorities.
   - Use custom widgets for task cards and lists.

4. **Search and Filtering:**
   - Implement search functionality for tasks.
   - Allow filtering by category and priority.

5. **API Integration:**
   - Use a mock API (like JSONPlaceholder or a custom one via Node.js/Express or Firebase).
   - Include error handling for API calls.

6. **State Management:**
   - Use Provider, Riverpod, or Bloc for state management.

7. **Local Storage:**
   - Implement local data storage using Hive or SharedPreferences to cache task data for offline use.

8. **Testing:**
   - Include at least two unit tests and one widget test for critical components.

9. **Bonus Points:**
   - Add animations (e.g., using Hero, AnimatedContainer).
   - Include a "Reminders" feature with local notifications.

Project Details
This project is built using Flutter 3.22.1 and Dart 3.4.1. It supports Android devices with a minimum SDK version of 23 and can run on devices up to API level 34. The project leverages Firebase for backend services, including user authentication and Firestore for data storage. Local data storage is handled using the sqflite package for SQLite database operations. The app also includes state management using the Provider package and supports both light and dark themes