# CoachFlow: Democratizing High-Performance AI Coaching

## About the project

CoachFlow is a minimalist mobile application designed to make personal coaching accessible, instant, and effective for everyone. Inspired by the idea that "coaching is one of the highest returns on investment you can make with your time" (Simon, Better Creating), this project bridges the gap between expensive human coaching and the potential of advanced Artificial Intelligence.

### Inspiration & Agile Evolution

The core inspiration was the realization that while AI is becoming powerful, the user experience around it often feels overly technical or generalized. We wanted to build a "beautiful minimal app" where users can simply pick a persona (a "Coach") and start a focused conversation, removing the friction of prompting and setup.

We adopted an **Agile & Iterative** approach, constantly refining the product based on real-time feedback. This allowed us to pivot from a simple chat app to a comprehensive "Coaching System" with features like:
*   **User Context**: A centralized storage of user goals and values that all AI coaches automatically understand.
*   **Direct Network**: A seamless way to share heavy context and wisdom with trusted peers.

We envisioned a productivity formula where:
$$ Productivity = \frac{Guidance \times Context}{Friction} $$

By maximizing guidance through discrete AI personas and minimizing friction with a clean, **Premium UI**, we aim to maximize user productivity.

### What it does

CoachFlow allows users to:
1.  **Create Custom AI Coaches**: Define a name, avatar, and a specific "System Prompt" that gives the AI its personality and expertise. We added a **Real-time Preview** and **Prompt Templates** to make this effortless.
2.  **Define "My Context"**: Users input their nickname, goals, values, and constraints ONCE. All coaches then automatically adapt their advice to this context.
3.  **Chat with Advanced AI**: Engage in seamless conversations powered by **Llama 3.1 405B** (via Bytez API) for state-of-the-art reasoning.
4.  **Manage a Network**: Add contacts and share entire conversion threads with a single click, allowing for "Direct Context Sharing".
5.  **Secure Authentication**: Full support for Email/Password and **Biometric Login** (FaceID/TouchID) for quick, secure access.
6.  **Full Internationalization**: Complete support for English 🇬🇧 and French 🇫🇷, adapting the interface and AI responses dynamically.

### How we built it

The project was built using **Flutter** for a high-performance, cross-platform experience. We focused on a clean, maintainable, and scalable architecture:

*   **State Management**: We used **Riverpod** ($ \mathcal{O}(1) $ read access) for robust dependency injection and state management, separating business logic from UI.
*   **Backend & Auth**: **Supabase** handles authentication (Email + Biometric Login + RLS Policies) and real-time database needs for user profiles and shared content.
*   **AI Integration**: We integrated **Bytez API** to access top-tier LLMs like Llama 3.1 405B and audio models for diverse capabilities.
*   **Local Persistence**: **Hive** is used for caching local chat history and settings to ensure blazing-fast offline access and instant app loading.
    $$ T_{read} \approx 0 \quad (\text{Direct memory access}) $$
*   **Navigation**: **GoRouter** handles complex navigation flows, including deep linking for shared conversations and valid redirects (e.g., auth guards).
*   **UI/Design**: A "Minimalist Premium" design system. We obsessed over details:
    *   Glassmorphism and subtle gradients.
    *   `flutter_animate` for engaging entry animations.
    *   Dark Mode optimization (OLED blacks, specific contrast adjustments).
    *   Custom "Burger Menu" logic for seamless navigation.

### Challenges we ran into

1.  **Drawer Navigation Context**: One tricky bug involved the "Logout" button in the Burger Menu closing the drawer (unmounting the widget) before the async logout logic completed. We solved this by decoupling the navigation logic from the widget tree using `ref.read(routerProvider)`.
2.  **Hybrid Data Sync**: orchestrating a seamless experience between local storage (Hive) for speed and remote storage (Supabase) for reliability was critical. We implemented a robust repository pattern to handle this.
3.  **Dynamic i18n & Context**: Implementing a language switcher and "User Context" that not only changes the UI text but also instructs the AI to respond in the selected language/context required deep integration into the chat service layer.

### Accomplishments that we're proud of

*   Delivering a fully polished, production-ready app with a **Premium UI/UX**.
*   The "smoothness" of the UI interactions, particularly the real-time card previews and biometric animations.
*   Successfully integrating a powerful open-source model (Llama 3.1) to rival proprietary solutions.
*   The modular architecture which allows us to swap AI providers or backend services with minimal friction.

### What we learned

Building CoachFlow reinforced the importance of **Clean Architecture** and **User-Centric Design**. By separating our Data Layer from our Presentation Layer, we could iterate on the UI (e.g., completely revamping the "Create Coach" screen) without breaking logic.

We also learned that:
$$ \lim_{{complexity} \to \infty} \text{User Retention} = 0 $$
Keeping the app simple was the hardest part, but the most rewarding.

### What's next for CoachFlow

*   **Coach Marketplace**: A community-driven platform to share and download coach personas.
*   **Voice Control**: Full voice-to-voice conversation mode.
*   **Advanced Analytics**: Visualizing progress towards the goals defined in "My Context".
