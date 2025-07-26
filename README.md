# 📘 Appel

[![Made with Flutter](https://img.shields.io/badge/Made%20with-Flutter-blue)](https://flutter.dev/)
[![Powered by Supabase](https://img.shields.io/badge/Backend-Supabase-green)](https://supabase.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Status: In Development](https://img.shields.io/badge/Status-In%20Development-orange)]()

**Appel** is a modern Flutter web app for streamlined student and attendance management, powered by a Supabase backend. It's designed to be a clean, intuitive, and powerful tool for educators, inspired by the French academic tradition of _l’appel_ (the roll call).

---
## ✨ Features

* **🎓 Student & Batch Management**
    * Create, edit, and view detailed student profiles.
    * Organize students into batches with custom names and schedules.
    * Easily assign or unassign students from batches.

* **📅 Dynamic Attendance System**
    * Mark attendance for entire batches or individual students.
    * Navigate an interactive calendar to view or modify records for any date—past or present.

* **⚡ Real-time & Responsive**
    * Instantly syncs all data with Supabase, ensuring your information is always up-to-date.
    * A fully responsive UI that works seamlessly on both desktop and mobile web browsers.

---
## 🛠️ Tech Stack

* **Frontend**: Flutter
* **Backend**: Supabase
    * **Database**: PostgreSQL
    * **Realtime**: For live data synchronization.
* **State Management**: GetX

---
## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

* Flutter SDK installed.
* A Supabase account and project.
* A Google AI API key for Gemini.

### Installation

1.  **Clone the repo**
    ```sh
    git clone https://github.com/SacredNightmare99/Appel-Attendance-Management-.git
    ```
2.  **Navigate to the project directory**
    ```sh
    cd Appel-Attendance-Management-
    ```
3.  **Install dependencies**
    ```sh
    flutter pub get
    ```
4.  **Set up your environment variables**
    * Create a `.env` file in the root directory.
    * Add your Supabase and Gemini credentials:
        ```env
        SupabaseURL=YOUR_SUPABASE_URL
        SupabaseAPI=YOUR_SUPABASE_ANON_KEY
        GeminiAPI=YOUR_GEMINI_API_KEY
        ```
5.  **Run the app**
    ```sh
    flutter run -d chrome
    ```

---
## 📂 Project Structure

The project follows a standard Flutter structure. The core logic is organized within the `lib` directory:

-   `lib/`
    -   `main.dart`: The entry point of the application.
    -   `AI/`: Contains the Gemini-powered AI assistant logic.
    -   `backend/`: Data models and Supabase service interactions.
    -   `controllers/`: GetX controllers for state management.
    -   `pages/`: UI screens for different features.
    -   `utils/`: Helper functions, color constants, and image paths.
    -   `widgets/`: Reusable UI components used across the app.

---
## 🏛️ Database Structure

The backend is built on three core tables and two SQL functions to handle atomic updates.

### Tables

| Table      | Columns                                                | Description                                    |
| :--------- | :----------------------------------------------------- | :--------------------------------------------- |
| `students` | `uid`, `name`, `batch_id`, `batch_name`, `classes`, `classes_present` | Stores individual student profiles and stats.  |
| `batches`  | `batch_uid`, `day`, `name`, `start_time`, `end_time`   | Defines the schedule and name for each batch.  |
| `attendance`| `uid`, `date`, `student_uid`, `present`, `student_name`| Logs a record for each student's attendance.   |

### Functions

* **`increment_classes_present(student_id, increment_value)`**
    * Safely increments or decrements the `classes_present` count for a student. Used when an attendance record's status is toggled.

* **`decrement_student_attendance(student_id, was_present)`**
    * Atomically decrements the total `classes` and, if `was_present` is true, also decrements `classes_present`. Used when an attendance record is deleted.

---
## 🚀 Future Roadmap

My vision for Appel extends beyond its current capabilities. Here are some of the key features and improvements on my roadmap:

*   🔐 **Multi-Tenant Authentication**
    *   Implement a robust user registration and login system.
    *   Allow multiple users (educators, institutions) to create and manage their own private sets of students, batches, and attendance data.

*   🤖 **Enhanced AI Assistant**
    *   Move beyond simple queries to proactive insights and report generation.
    *   Enable the AI to identify at-risk students based on attendance trends.

*   📊 **Advanced Analytics Dashboard**
    *   Develop a comprehensive dashboard with visual charts for:
        *   Attendance trends over time.
        *   Batch performance comparisons.
        *   Overall student engagement metrics.

*   ☁️ **Cloud Deployment & Hosting**
    *   Provide a fully hosted version of the application, removing the need for users to self-deploy.

---
## 🤝 Contributing & Feedback

As a solo developer, I welcome any feedback, suggestions, or contributions from the community. If you have ideas for improvement or want to report a bug, please feel free to open an issue. Pull requests are also appreciated!

---
## 📄 License

This project is licensed under the **MIT License**.

