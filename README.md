# CoachFlow 🧠

CoachFlow is a minimalist, high-performance mobile application built with Flutter that democratizes access to personal coaching through AI. It allows users to create, customize, and chat with AI-powered coaches tailored to their specific needs.

## ✨ Features

- **Custom AI Coaches**: Create unique personas with custom names, avatars, and system prompts (e.g., "Fitness Coach", "Productivity Expert").
- **Instant Chat**: Seamless, real-time messaging interface with your AI coaches.
- **Local Privacy**: All data (coaches and messages) is stored locally on your device using Hive.
- **Minimalist Design**: A clean, distraction-free UI designed for focus and clarity.
- **Mock AI Integration**: Currently simulates AI responses for testing (ready for OpenAI/Anthropic integration).

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management**: [Riverpod](https://riverpod.dev/) (v2 with code generation)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
- **Local Database**: [Hive](https://docs.hivedb.dev/) (NoSQL, fast, offline-first)
- **UI/Animations**: `flutter_animate`, `google_fonts`

## 🏗 Architecture

The project follows a **Feature-First Layered Architecture**:

```
lib/
├── core/                   # Global utilities, theme, router, extensions
├── features/
│   ├── chat/               # Chat feature (UI, Logic, Data)
│   ├── coach/              # Coach management (UI, Logic, Data)
│   └── home/               # Home screen
└── main.dart               # Entry point
```

Each feature is self-contained with its own:
- **Data Layer**: Repositories for data access (Hive).
- **Domain Layer**: Models (Entities).
- **Presentation Layer**: UI (Widgets) and State Management (Providers).

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
- An IDE (VS Code, Android Studio) with Flutter extensions.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/coachflow.git
    cd coachflow
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Generate code (for Hive adapters and Riverpod):**
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **Run the app:**
    ```bash
    flutter run
    ```

## 🧪 Current Status

- **MVP Phase**: The application is functional with local storage and a Mock AI service.
- **Next Steps**:
    - integrate real AI API (OpenAI/Anthropic).
    - Add user context settings.
    - Implement export/import functionality.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
