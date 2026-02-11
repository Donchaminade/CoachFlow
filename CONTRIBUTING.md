# Contributing to CoachFlow 🤝

First off, thanks for taking the time to contribute! 🎉

CoachFlow is built on the belief that code should be as clean and accessible as the coaching it provides. We welcome contributions from everyone, whether you're fixing a typo, adding a new feature, or refactoring legacy code.

## 🏗 Architecture & Code Style

We follow a **Feature-First Layered Architecture**. Before writing code, please understand the structure:

`lib/features/<feature_name>/`
- **data/**: Repositories, Data Sources, DTOs (Data Transfer Objects).
- **domain/**: Entities (Pure Dart classes), Failures.
- **ui/**: Widgets, Screens.
- **providers/**: Riverpod providers (`StateNotifierProvider`, `FutureProvider`, etc.).

### Key Rules
1.  **Riverpod**: We use `flutter_riverpod` with code generation (`@riverpod`) where possible. Avoid `StatefulWidget` for global state.
2.  **Immutability**: Use `freezed` or `equatable` for state classes and models.
3.  **No Logic in UI**: Widgets should only call methods on Controllers/Notifiers.
4.  **Linting**: Ensure `flutter analyze` passes before pushing.

## 🛠 Getting Started

1.  **Fork the repo** and clone it locally.
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Setup environment**:
    Copy `.env.example` to `.env` and fill in your Supabase credentials.
4.  **Run the generator** (keep this running in background):
    ```bash
    dart run build_runner watch --delete-conflicting-outputs
    ```

## 🐛 Found a Bug?

*   **Ensure the bug was not already reported** by searching on GitHub under [Issues](https://github.com/Donchaminade/CoachFlow/issues).
*   If you're unable to find an open issue addressing the problem, open a new one. Be sure to include a **title and clear description**, as well as as much relevant information as possible.

## 💡 Submitting a Pull Request (PR)

1.  **Create a Branch**: `git checkout -b feature/my-amazing-feature` or `fix/annoying-bug`.
2.  **Commit with Context**: We prefer [Conventional Commits](https://www.conventionalcommits.org/) (e.g., `feat: add biometric login`, `fix: logout drawer bug`).
3.  **Push and Open PR**: Describe your changes, screenshot UI updates, and reference related issues.
4.  **Review**: Wait for a maintainer to review your code. We may ask for changes—this is normal!

## 🌍 Internationalization (i18n)

If you add text to the UI:
1.  Add the key/value to `lib/core/l10n/app_en.arb` (English).
2.  Add the translation to `lib/core/l10n/app_fr.arb` (French).
3.  Run `flutter gen-l10n`.
4.  Use `AppLocalizations.of(context).myKey` in widgets.

---

**Happy Coding!** 🚀
