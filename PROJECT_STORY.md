# CoachFlow: Democratizing High-Performance AI Coaching

## About the project

CoachFlow is a minimalist mobile application designed to make personal coaching accessible, instant, and effective for everyone. Inspired by the idea that "coaching is one of the highest returns on investment you can make with your time" (Simon, Better Creating), this project bridges the gap between expensive human coaching and the potential of advanced Artificial Intelligence.

### Inspiration

The core inspiration was the realization that while AI is becoming powerful, the user experience around it often feels overly technical or generalized. We wanted to build a "beautiful minimal app" where users can simply pick a persona (a "Coach") and start a focused conversation, removing the friction of prompting and setup.

We envisioned a productivity formula where:
$$ Productivity = \frac{Guidance \times Context}{Friction} $$

By maximizing guidance through discrete AI personas and minimizing friction with a clean UI, we aim to maximize user productivity.

### What it does

CoachFlow allows users to:
1.  **Create Custom AI Coaches**: Define a name, avatar, and a specific "System Prompt" that gives the AI its personality and expertise (e.g., "Productivity Expert", "Fitness Coach", "Stoic Philosopher").
2.  **Chat with Advanced AI**: Engage in seamless conversations powered by **Llama 3.1 405B** (via Bytez API) for state-of-the-art reasoning.
3.  **Hear Your Coach**: Integrated Text-to-Speech (TTS) using OpenAI's TTS-1 model brings coaches to life with natural voices.
4.  **Secure Cloud Sync**: User profiles and shared conversations are securely stored and synced via **Supabase**.
5.  **Share Wisdom**: Export and share entire conversation threads with friends or colleagues via unique links.
6.  **Full Internationalization**: Complete support for English 🇬🇧 and French 🇫🇷, adapting the interface and AI responses dynamically.

### How we built it

The project was built using **Flutter** for a high-performance, cross-platform experience. We focused on a clean, maintainable, and scalable architecture:

*   **State Management**: We used **Riverpod** ($ \mathcal{O}(1) $ read access) for robust dependency injection and state management, separating business logic from UI.
*   **Backend & Auth**: **Supabase** handles authentication (Email + Biometric Login) and real-time database needs for user profiles and shared content.
*   **AI Integration**: We integrated **Bytez API** to access top-tier LLMs like Llama 3.1 405B and audio models for diverse capabilities.
*   **Local Persistence**: **Hive** is used for caching local chat history and settings to ensure blazing-fast offline access and instant app loading.
    $$ T_{read} \approx 0 \quad (\text{Direct memory access}) $$
*   **Navigation**: **GoRouter** handles complex navigation flows, including deep linking for shared conversations.
*   **UI/Design**: A "Minimalist Premium" design system with `flutter_animate` for subtle engagement, supporting both Light and Dark modes.

### Challenges we ran into

1.  **Hybrid Data Sync**: orchestrating a seamless experience between local storage (Hive) for speed and remote storage (Supabase) for reliability was critical. We implemented a robust repository pattern to handle this.
2.  **Dynamic i18n**: Implementing a language switcher that not only changes the UI text but also instructs the AI to respond in the selected language required deep integration into the chat service layer.
3.  **Biometric Security**: Securely integrating platform-specific biometric authentication (FaceID/TouchID) with Supabase session management.

### Accomplishments that we're proud of

*   Delivering a fully polished, production-ready app with a premium UI/UX.
*   The "smoothness" of the UI interactions, particularly the chat bubbles, animations, and transitions.
*   Successfully integrating a powerful open-source model (Llama 3.1) to rival proprietary solutions.
*   The modular architecture which allows us to swap AI providers or backend services with minimal friction.

### What we learned

Building CoachFlow reinforced the importance of **Clean Architecture**. By separating our Data Layer (Repositories) from our Domain Layer (Models) and Presentation Layer (Widgets & Notifiers), we created a codebase that is easy to test, extend, and maintain.

We also learned that:
$$ \lim_{{complexity} \to \infty} \text{User Retention} = 0 $$
Keeping the app simple was the hardest part, but the most rewarding.

### What's next for CoachFlow

*   **Coach Marketplace**: A community-driven platform to share and download coach personas.
*   **Voice Control**: Full voice-to-voice conversation mode.
*   **Advanced Context**: Allowing users to define deeper "User Context" (goals, values) that persists across all coaches for hyper-personalized advice.
