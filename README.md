# Tackle4Loss

This repository contains the Flutter frontend application for Tackle4Loss, an American Football news application built for iOS, Android, and Web platforms.

## Table of Contents

1.  [Overview](#overview)
2.  [Prerequisites](#prerequisites)
3.  [Contributing](#contributing)
4.  [Getting Started](#getting-started)
5.  [Project Structure](#project-structure)
6.  [Core Technologies & Packages](#core-technologies--packages)
7.  [Architecture & Key Concepts](#architecture--key-concepts)
    *   [State Management (Riverpod)](#state-management-riverpod)
    *   [Backend Integration (Supabase)](#backend-integration-supabase)
    *   [Navigation (Adaptive)](#navigation-adaptive)
    *   [Theming & Styling](#theming--styling)
    *   [Data Fetching & Services](#data-fetching--services)
    *   [Localization](#localization)
    *   [Local Persistence](#local-persistence)
    *   [Responsiveness](#responsiveness)
8.  [Implemented Features](#implemented-features)
9.  [Running the App](#running-the-app)
10. [Backend Notes](#backend-notes)
11. [Potential Next Steps](#potential-next-steps)

## Overview

Tackle4Loss aims to provide users with up-to-date American Football news currated from different NFL Source News Sites like NFL.com or ESPN.com. 
This Flutter application serves as the user interface, interacting with a Supabase backend for data storage, retrieval (via Edge Functions), and potentially authentication and real-time updates. The app is designed to be responsive, adapting its layout for mobile, tablet, and web screens.

## Prerequisites

*   **Flutter SDK:** Version 3.x.x or later (check `flutter --version`). Install from [Flutter official site](https://docs.flutter.dev/get-started/install).
*   **VS Code:** Recommended IDE. Install from [VS Code official site](https://code.visualstudio.com/).
*   **VS Code Flutter Extension:** Install from the VS Code Marketplace (includes Dart extension).
*   **Platform SDKs:**
    *   **Android:** Android Studio (for SDK, command-line tools, emulator).
    *   **iOS (macOS only):** Xcode (from Mac App Store).
    *   **Web:** Google Chrome (recommended for debugging).
*   **Run `flutter doctor -v`:** Ensure your environment is set up correctly for your target platforms.
*   **Git:** For cloning the repository.

## Getting Started

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/BigSlikTobi/tackle_4_loss.git
    cd tackle_4_loss 

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Configure Supabase Credentials:**
    *   Create a file named `.env` in the root directory of the project.
    *   Add your Supabase **URL** and **Anon Key** (the public key):
        ```plaintext
        # .env
        SUPABASE_URL=https://your-project-ref.supabase.co
        SUPABASE_ANON_KEY=your-public-anon-key
        ```
    *   **IMPORTANT:** Ensure `.env` is listed in your `.gitignore` file to avoid committing credentials.
4.  **Run the App:** (See [Running the App](#running-the-app) section below).

## Contributing

Contributions are welcome! Whether it's fixing bugs, improving documentation, adding features, or suggesting ideas, please feel free to contribute.

**How to Contribute:**

1.  **Fork the repository.**
2.  **Create a new branch** for your feature or bug fix:
    ```bash
    git checkout -b feature/your-feature-name
    # or
    git checkout -b fix/your-bug-fix-name
    ```
3.  **Make your changes** and commit them with clear messages.
4.  **Push your changes** to your forked repository.
5.  **Open a Pull Request** against the `main` (or `develop`) branch of the original repository.
6.  **Describe your changes** clearly in the Pull Request description.

**Issues:**

*   Feel free to **open an issue** if you find a bug or want to suggest a new feature.
*   Check the existing issues to see if your idea or problem has already been discussed.

Known issues and required clean_ups can be found [here](ToDos.md)

We appreciate your help in making Tackle4Loss better!

## Project Structure

The project follows a **Feature-First** architecture within the `lib` directory:

*   `lib/`
    *   `app.dart`: Root `MyApp` widget, `MaterialApp` setup.
    *   `main.dart`: App entry point, Supabase/DotEnv initialization.
    *   `core/`: Shared code across features.
        *   `constants/`: App-wide constants (e.g., `team_constants.dart`).
        *   `models/`: Shared data models (if any).
        *   `navigation/`: Navigation setup (`NavItem`, `MainNavigationWrapper`).
        *   `providers/`: Shared Riverpod providers (e.g., `locale_provider.dart`, `navigation_provider.dart`).
        *   `services/`: Shared services (e.g., `preference_service.dart`).
        *   `theme/`: Global theme data (`app_colors.dart`, `app_theme.dart`).
        *   `utils/`: Utility functions.
        *   `widgets/`: Common reusable widgets (e.g., `GlobalAppBar`, `LoadingIndicator`).
    *   `features/`: Feature modules.
        *   `news_feed/`
            *   `data/`: Models (`ArticlePreview`), Services (`NewsFeedService`).
            *   `logic/`: Riverpod Providers (`news_feed_provider.dart`).
            *   `ui/`: Screens (`NewsFeedScreen`), Widgets (`ArticleListItem`, `HeadlineStoryCard`).
        *   `my_team/`
            *   `ui/`: Screens (`MyTeamScreen`), Widgets (`UpcomingGamesCard`, `InjuryReportCard`, `TeamHuddleSection`, `TeamSelectionDropdown`).
        *   `article_detail/`: Placeholder for future implementation.
            *   `ui/`: Screens (`ArticleDetailScreen`).
        *   `schedule/`: Placeholder.
            *   `ui/`: Screens (`ScheduleScreen`).
        *   `more/`: Placeholder.
            *   `ui/`: Screens (`MoreScreen`).
    *   `models/`: (Alternative location for ALL models if preferred over feature folders).

## Core Technologies & Packages

*   **Flutter:** Cross-platform UI toolkit.
*   **Dart:** Programming language for Flutter.
*   **Supabase:** Backend-as-a-Service:
    *   **Database:** PostgreSQL for data storage.
    *   **Edge Functions:** Deno runtime for serverless backend logic (used for data fetching).
    *   **Auth (Setup for):** Supabase Auth for user management (not fully implemented in UI yet).
    *   **Storage:** For storing images (used by backend Python scripts).
    *   **Realtime (Setup for):** For potential live updates.
*   **Riverpod (`flutter_riverpod`):** State management and dependency injection. Chosen for its robustness, testability, and excellent handling of async operations.
*   **Supabase Flutter (`supabase_flutter`):** Official Supabase client library for Flutter.
*   **Shared Preferences (`shared_preferences`):** Local key-value storage for persisting non-critical user preferences (selected team, language) without requiring login.
*   **Cached Network Image (`cached_network_image`):** Efficiently loads and caches network images.
*   **intl (`intl`):** Used for date formatting and potentially future localization strings.
*   **Flutter DotEnv (`flutter_dotenv`):** Loads environment variables from a `.env` file for secure credential management.

## Architecture & Key Concepts

### State Management (Riverpod)

*   Uses `ProviderScope` at the root (`main.dart`).
*   Widgets that need to read or interact with state use `ConsumerWidget` or `ConsumerStatefulWidget`.
*   **Providers Used:**
    *   `Provider`: For simple dependency injection (e.g., `newsFeedServiceProvider`, `preferenceServiceProvider`).
    *   `StateProvider`: For simple synchronous state that needs to be mutated (e.g., `selectedNavIndexProvider`, `newsFeedDisplayModeProvider`, `isSidebarExtendedProvider` - though last was removed).
    *   `FutureProvider`: For one-off async operations, automatically handling loading/error states (e.g., initial version of `articlePreviewsProvider`, `selectedTeamProvider`).
    *   `StateNotifierProvider`/`AsyncNotifierProvider`: For more complex state involving asynchronous operations, user actions, and managing loading/error states robustly (e.g., `localeNotifierProvider`, `selectedTeamNotifierProvider`, `paginatedArticlesProvider`).

### Backend Integration (Supabase)

*   Flutter app interacts with Supabase primarily through **Edge Functions**.
*   Edge Functions (`articlePreviews`, etc.) are responsible for querying the database and returning structured data (often lean/preview data).
*   **Security (RLS):**
    *   Row Level Security (RLS) is **ENABLED** on relevant database tables (`NewsArticles`, `TeamNewsArticles`, `Rosters`, etc.).
    *   Public read policies (`SELECT` for `public` role) are defined based on data status (e.g., `status = 'PUBLISHED'`).
    *   Edge Functions called by the Flutter app **use the client's authentication context** (via the `SUPABASE_ANON_KEY` and the `Authorization` header) to ensure RLS policies are enforced.
    *   Backend Python scripts use the `SUPABASE_SERVICE_ROLE_KEY` to bypass RLS for administrative tasks (data ingestion, processing, updates).

### Navigation (Adaptive)

*   A central `MainNavigationWrapper` widget handles the primary app navigation structure.
*   It adapts based on screen width (`kMobileLayoutBreakpoint`):
    *   **Mobile (< 720px):** Displays a `BottomNavigationBar`.
    *   **Desktop/Tablet (>= 720px):** Displays a `Drawer` accessible via a menu icon in the `GlobalAppBar`.
*   `selectedNavIndexProvider` (StateProvider) tracks the active screen.
*   `IndexedStack` preserves the state of each main screen when switching tabs/drawer items.

### Theming & Styling

*   A global theme is defined in `lib/core/theme/app_theme.dart` using `ThemeData`.
*   Colors are centralized in `lib/core/theme/app_colors.dart` based on the provided style sheet.
*   A custom `GlobalAppBar` (`lib/core/widgets/global_app_bar.dart`) provides a consistent header across screens, styled according to the theme.
*   Widgets aim to use `Theme.of(context)` to access styles for consistency.

### Data Fetching & Services

*   Network calls to Supabase Edge Functions are encapsulated within **Service classes** (e.g., `NewsFeedService`) located in the `data` folder of relevant features.
*   Riverpod providers (`newsFeedServiceProvider`) are used to provide instances of these services.
*   Widgets interact with providers, which in turn call services to fetch or manipulate data.

### Localization

*   Basic localization setup using `flutter_localizations` is configured in `MaterialApp`.
*   Supported locales are English (`en`) and German (`de`).
*   `localeNotifierProvider` (StateNotifierProvider) manages the current app locale.
*   It detects the initial device locale if no preference is saved.
*   User selection is saved using `shared_preferences`.
*   Widgets watch the provider to display content (e.g., headlines) in the appropriate language.

### Local Persistence

*   `shared_preferences` is used to store:
    *   User's selected language override.
    *   User's selected favorite team ID (allowing personalization without login).
*   A `PreferenceService` (`lib/core/services/preference_service.dart`) wraps `shared_preferences` calls.

### Responsiveness

*   **Layout Adaptation:** `MainNavigationWrapper` switches between bottom navigation and a drawer based on screen width.
*   **Content Constraint:** On wider screens, the main content area is centered and constrained to a maximum width (`kMaxContentWidth`) using `Center` and `ConstrainedBox`.
*   **Widget Adaptation:** Specific widgets (like the `TeamHuddleSection`'s sub-cards) adjust their internal layout (e.g., `Row` vs. `Column`) based on screen width.

## Implemented Features

*   **Core Setup:** Flutter project targeting iOS, Android, Web with VS Code integration.
*   **Supabase Integration:** Initialization with secure credential loading (`.env`).
*   **Global Theme:** Consistent app styling based on the provided style sheet.
*   **Adaptive Navigation:** Bottom navigation bar (mobile) / Drawer (desktop/web).
*   **Language Selection:** Global language picker (EN/DE) with device locale detection and preference persistence.
*   **News Feed (`NewsFeedScreen`):**
    *   Displays a list of news articles fetched from the `articlePreviews` Edge Function.
    *   Includes Pull-to-Refresh.
    *   Implements "Load Older" functionality (switches from 'NEW' only to 'All').
    *   Includes infinite scrolling pagination when viewing 'All' articles.
    *   Displays a prominent headline story (overall latest or team-specific latest).
    *   Conditionally displays a "Team Huddle" section if a team is selected.
*   **Team Huddle Section:**
    *   Shows team logo and "Team Huddle" title.
    *   Includes the team-specific headline story.
    *   Includes expandable placeholder cards for "Upcoming Games" and "Injury Report".
*   **My Team (`MyTeamScreen`):**
    *   Allows users to select a favorite team via a dropdown.
    *   Selection is saved locally using `shared_preferences`.
    *   Displays articles filtered for the selected team (currently using the same preview service, needs dedicated data/service later).
*   **Placeholder Screens:** Basic screens for Schedule and More.

## Running the App

1.  Ensure you have completed the [Getting Started](#getting-started) steps.
2.  Select your target device/platform in VS Code (bottom-right status bar) or list devices using `flutter devices`.
3.  Start debugging:
    *   Press `F5` in VS Code.
    *   Or run `flutter run -d <device_id>` in the terminal (e.g., `flutter run -d chrome`, `flutter run -d macos`, `flutter run -d <your_emulator_id>`).

## Backend Notes

*   This Flutter app relies on a **Supabase backend**.
*   Data fetching primarily uses **Edge Functions** written in TypeScript/Deno. These functions *must* be deployed and accessible.
*   **RLS policies** are configured in Supabase to control data access based on user roles (`public`, `authenticated`). Edge functions respect these via the client's Authorization header.
*   **Python scripts** handle backend data processing (scraping, cleaning, embedding, classification, etc.) and use the **Service Role Key** to interact with Supabase, bypassing RLS. These scripts run separately from the Flutter app.

## Potential Next Steps

*   Implement the `ArticleDetailScreen` to fetch and display full article content.
*   Implement the `Schedule` and `More` screens.
*   Implement real-time updates using Supabase Realtime.
*   Connect `UpcomingGamesCard` and `InjuryReportCard` to real data sources/Edge Functions.
*   Refine error handling and user feedback.
*   Implement unit and widget tests.
*   Optimize performance (e.g., image loading, build times).
*   Add dark mode theme.
*   Refactor `teamLogoMap` and `teamFullNameMap` into a more robust data source (e.g., fetched from `Teams` table).