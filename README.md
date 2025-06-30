# 🤖 Appel AI Integration (Gemini Chat Assistant)

This branch introduces an intelligent chatbot assistant into **Appel**, powered by Google's **Gemini API** and integrated with **GetX** for state management.

> _"L'appel du futur."_ – The roll call of the future.

---

## 🔍 Overview

The AI Assistant acts as a smart interface between educators and the attendance system. It allows conversational interactions for querying attendance data, summarizing student performance, and (soon) performing attendance actions.

---

## 🚀 Stack Overview

- 🧠 **Gemini API** – for generating AI responses
- 📱 **Flutter** – UI framework
- ⚙️ **GetX** – manages chat state and logic
- 🔗 **Supabase** – handles student, batch, and attendance data

---

## ✨ AI Assistant Features

- 💬 **Natural Language Queries**
  - “Which students were absent yesterday?”
  - “Show Batch B2’s attendance for this week”

- ⚙️ **Smart Actions**
  - Create batches or register students via chat (planned)
  - Mark attendance (planned)

- 📊 **Insights & Summaries**
  - Batch attendance summaries
  - Spot irregular or low-attendance patterns

- 🧠 **Contextual Guidance**
  - The AI explains how to use app features
  - Suggests next steps and corrections

---

## 🧪 In Progress / Planned

- ✍️ Gemini-powered data creation (batches, students)
- ✅ Confirmable attendance marking via AI
- 🔒 Secure Supabase write-actions through validation and roles
- 🧼 Cleaner markdown rendering for chat responses

---

## ⚠️ Note

All AI actions that modify data are behind confirmation prompts to prevent unwanted writes. Data control stays in the user’s hands.

---

## 📄 License

[MIT License](../LICENSE)

---

## ✨ Purpose-Driven AI

Appel AI Assistant was built to enhance—not replace—educators.  
A tool with clarity, elegance, and intention, just like the classroom.

