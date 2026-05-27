# CoachFlow: High-Performance AI Coaching 🧠

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![State Management](https://img.shields.io/badge/Riverpod-2.x-blue)
![Database](https://img.shields.io/badge/Supabase-Backend-green)
![License](https://img.shields.io/badge/License-MIT-purple)

**CoachFlow** is a premium, minimalist mobile application that democratizes access to personal coaching. By combining **Advanced AI (Llama 3.1 405B)** with a frictionless user experience, it allows anyone to create, customize, and converse with expert personas tailored to their specific goals.

> *"Productivity = (Guidance × Context) / Friction"*

---

## ✨ Key Features

### 🤖 Intelligent Personas
*   **Custom Coaches**: Create unique AI personas with specific expertise (e.g., *Marcus Aurelius for Stoicism*, *Steve Jobs for Product Design*).
*   **Real-time Preview**: See your coach come to life as you design them.
*   **System Prompts**: Define the exact personality and behavioral constraints of your AI.

### 🧠 My Context (The Memory Core)
*   **Universal Context**: Define your goals, values, and constraints **once**.
*   **Adaptive Advice**: All coaches automatically understand who you are (e.g., *"I know you value sustainability, so here is an eco-friendly solution..."*).

### 💬 Premium Chat Experience
*   **Llama 3.1 405B Integration**: Powered by Bytez API for reasoning capabilities that rival top-tier proprietary models.
*   **Voice-to-Voice (TTS)**: Listen to your coaches with natural, neural voices.
*   **Rich Text Support**: Markdown rendering for structured advice (lists, code blocks, bold text).

### 🤝 Social & Network (Direct Share)
*   **Share Wisdom**: Export entire conversation threads to friends using a unique link.
*   **Network Management**: Build your contact list and share insights directly within the app.

### 🛡️ Security & Performance
*   **Biometric Login**: Secure access via FaceID/TouchID.
*   **Offline-First**: Powered by **Hive** for instant load times and offline history access.
*   **Supabase Backend**: Robust real-time syncing and Row-Level Security (RLS) for data protection.

---

## 🛠 Tech Stack & Architecture

CoachFlow is built with a focus on **Clean Architecture**, Scalability, and Performance.

| Layer | Technology | Description |
| :--- | :--- | :--- |
| **Framework** | **Flutter** (Dart) | Cross-platform high-performance UI. |
| **State** | **Riverpod** | Compile-time safe dependency injection and caching. |
| **Navigation** | **GoRouter** | Declarative routing with deep linking support. |
| **Backend** | **Supabase** | Auth, Database (PostgreSQL), and Real-time subscriptions. |
| **AI Data** | **Bytez API** | Access to Open Source models (Llama 3.1, Gemma, Mistral). |
| **Local DB** | **Hive** | NoSQL local storage for $\mathcal{O}(1)$ read access. |
| **UI/UX** | **Flutter Animate** | fluid, engagement-driven micro-interactions. |

---

## 🚀 Getting Started

### Prerequisites
*   [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest stable)
*   Supabase Account & Project

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Donchaminade/CoachFlow.git
    cd CoachFlow
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Environment Setup:**
    Copy `.env.example` to `.env` and fill in your keys, or update `lib/core/config/supabase_config.dart`:
    ```bash
    cp .env.example .env
    ```

4.  **Run the app:**
    ```bash
    flutter run
    ```

---

## 🔮 Roadmap

- [x] **MVP**: Core Chat, Local Storage, Mock AI.
- [x] **V1.0**: Real AI (Bytez), Biometrics, User Context, Supabase Sync.
- [x] **V1.1**: Direct Share (in-app contact sharing), message deletion, clear history, settings links, i18n polish.
- [ ] **V1.2**: Voice Mode (Full duplex conversation).
- [ ] **V2.0**: Coach Marketplace (Community extensions).

---

## 🏆 GitHub Finish-Up-A-Thon (DEV Challenge)

This project is being submitted to the **[GitHub Finish-Up-A-Thon](https://dev.to/challenges/finishupathon)** — reviving an abandoned side project with a clear **before/after** story and **GitHub Copilot** assistance.

| Resource | Link |
|----------|------|
| Submission article (draft) | [docs/FINISH_UP_A_THON_SUBMISSION.md](docs/FINISH_UP_A_THON_SUBMISSION.md) |
| Before snapshot (git) | `git checkout 941d27b` |
| V1.1 release tag | `v1.1.0-finishathon` _(create after final push)_ |

**Quick demo path:** Create coach → Chat → Share to contact → View in Shared tab → Continue conversation.

---

## 🤝 Contributing

Contributions are welcome! Please read our [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*Built with ❤️ by the CoachFlow Team.*
