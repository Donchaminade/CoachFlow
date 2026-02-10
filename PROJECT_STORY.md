# Project CoachFlow: Democratizing AI Coaching

## About the project

CoachFlow is a minimalist mobile application designed to make personal coaching accessible, instant, and effective for everyone. Inspired by the idea that "coaching is one of the highest returns on investment you can make with your time" (Simon, Better Creating), this project aims to bridge the gap between expensive human coaching and the potential of Artificial Intelligence.

### Inspiration

The core inspiration was the realization that while AI is becoming powerful, the user experience around it often feels overly technical or generalized. We wanted to build a "beautiful minimal app" where users can simply pick a persona (a "Coach") and start a focused conversation, removing the friction of prompting and setup.

We envisioned a productivity formula where:
$$ Productivity = \frac{Guidance \times Context}{Friction} $$

By maximizing guidance through discrete AI personas and minimizing friction with a clean UI, we aim to maximize user productivity.

### What it does

CoachFlow allows users to:
1.  **Create Custom AI Coaches**: Define a name, avatar, and a specific "System Prompt" that gives the AI its personality and expertise (e.g., "Productivity Expert", "Fitness Coach").
2.  **Chat Instantly**: Engage in a seamless, text-based conversation with these coaches.
3.  **Local Privacy**: All data (coaches and messages) is stored fast and locally on the device using Hive.

### How we built it

The project was built using **Flutter** for a high-performance, cross-platform experience. We focused on a clean, maintainable architecture:

*   **State Management**: We used **Riverpod** ($ \mathcal{O}(1) $ read access) for robust dependency injection and state management, separating business logic from UI.
*   **Local Persistence**: To ensure the app works offline and is blazing fast, we implemented **Hive**. The complexity of reading data can be described as:
    $$ T_{read} \approx 0 \quad (\text{Direct memory access}) $$
*   **Navigation**: **GoRouter** was used to handle deep linking and smooth transitions between the Home, Creation, and Chat screens.
*   **UI/Design**: We adhered to a "Minimalist" design system, utilizing `flutter_animate` for subtle engagement without clutter.

### Challenges we ran into

1.  **State Synchronization**: Keeping the list of coaches updated across different screens required careful provider invalidation in Riverpod. We had to ensure that when a coach was added or deleted, the UI reflected this state immediately without a full rebuild.
    
    $$ S_{new} = S_{old} \cup \{ \text{NewCoach} \} $$

2.  **Asynchronous Initialization**: Initializing Hive boxes before the app start (`main.dart`) while ensuring the splash screen didn't hang indefinitely was a key implementation detail we had to get right.

3.  **Mocking the AI**: For the initial MVP, we had to simulate a realistic AI response delay and context awareness without a live API backend, creating a `MockChatService` that mimics network latency.

### Accomplishments that we're proud of

*   Delivering a fully functional MVP with local storage in a very short timeframe.
*   The "smoothness" of the UI interactions, particularly the chat bubbles and the coach creation flow.
*   The modular architecture which allows us to swap the `MockChatService` with a real `OpenAIChatService` in just a few lines of code.

### What we learned

Building CoachFlow reinforced the importance of **Clean Architecture**. By separating our Data Layer (Hive repositories) from our Domain Layer (Models) and Presentation Layer (Widgets), we created a codebase that is easy to test and extend.

We also learned that:
$$ \lim_{{complexity} \to \infty} \text{User Retention} = 0 $$
Keeping the app simple was the hardest part, but the most rewarding.

### What's next for CoachFlow

*   **Real AI Integration**: Connecting to OpenAI's GPT-4 API.
*   **User Context Module**: Allowing users to define global values that all coaches are aware of.
*   **Marketplace**: A feature to share and download coach personas.
