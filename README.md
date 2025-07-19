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
    * Add your Supabase URL and Anon Key:
        ```env
        SUPABASE_URL=YOUR_SUPABASE_URL
        SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
        ```
5.  **Run the app**
    ```sh
    flutter run -d chrome
    ```

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
## 🚧 Work in Progress & Planned Features

* 🔐 **Authentication System**
    * Secure login.
      
* 🤖 **AI Assistant (Gemini-Powered)**
    * **Current:** Query student and batch information using natural language (e.g., "Show me students with less than 75% attendance").
    * **Planned:** Get smart insights and generate reports.

* 📊 **Dashboard & Analytics**
    * A visual dashboard with charts for attendance trends, batch performance, and overall student engagement.

---
## 🤝 Contributing

Contributions, feedback, and suggestions are always welcome. Feel free to open an issue or submit a pull request.

---
## 📄 License

This project is licensed under the **MIT License**. See the `LICENSE` file for details.
