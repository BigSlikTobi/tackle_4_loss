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
    *   [Navigation (State-Driven Inline Detail View)](#navigation-state-driven-inline-detail-view)
    *   [Theming & Styling](#theming--styling)
    *   [Data Fetching & Services](#data-fetching--services)
    *   [Localization](#localization)
    *   [Local Persistence](#local-persistence)
    *   [Responsiveness](#responsiveness)
    *   [HTML Content Rendering](#html-content-rendering)
    *   [Sharing](#sharing)
8.  [Implemented Features](#implemented-features)
9.  [Running the App](#running-the-app)
10. [Backend Notes](#backend-notes)
11. [Potential Next Steps](#potential-next-steps)

## Overview

Tackle4Loss aims to provide users with up-to-date American Football news curated from different NFL Source News Sites like NFL.com or ESPN.com.
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
    ```
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
        *   `navigation/`: Navigation setup (`NavItem`, `MainNavigationWrapper`, `app_navigation.dart`).
        *   `providers/`: Shared Riverpod providers (e.g., `locale_provider.dart`, `navigation_provider.dart`, `preference_provider.dart`).
        *   `services/`: Shared services (e.g., `preference_service.dart`).
        *   `theme/`: Global theme data (`app_colors.dart`, `app_theme.dart`).
        *   `utils/`: Utility functions.
        *   `widgets/`: Common reusable widgets (e.g., `GlobalAppBar`, `LoadingIndicator`, `ErrorMessageWidget`).
    *   `features/`: Feature modules.
        *   `news_feed/`
            *   `data/`: Models (`ArticlePreview`), Services (`NewsFeedService`).
            *   `logic/`: Riverpod Providers (`news_feed_provider.dart`, `news_feed_state.dart`).
            *   `ui/`: Screens (`NewsFeedScreen`), Widgets (`ArticleListItem`, `HeadlineStoryCard`).
        *   `my_team/`
            *   `data/`: (If models/services specific to this feature are added)
            *   `logic/`: (If providers specific to this feature are added)
            *   `ui/`: Screens (`MyTeamScreen`), Widgets (`UpcomingGamesCard`, `InjuryReportCard`, `TeamHuddleSection`, `TeamSelectionDropdown`).
        *   `article_detail/`
            *   `data/`: Models (`ArticleDetail`), Services (`ArticleDetailService`).
            *   `logic/`: Riverpod Providers (`article_detail_provider.dart`).
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
    *   **Edge Functions:** Deno runtime for serverless backend logic (used for `articlePreviews`, `articleDetail`).
    *   **Auth (Setup for):** Supabase Auth for user management (not fully implemented in UI yet).
    *   **Storage:** For storing images (used by backend Python scripts).
    *   **Realtime (Setup for):** For potential live updates.
*   **Riverpod (`flutter_riverpod`):** State management and dependency injection. Chosen for its robustness, testability, and excellent handling of async operations.
*   **Supabase Flutter (`supabase_flutter`):** Official Supabase client library for Flutter.
*   **Shared Preferences (`shared_preferences`):** Local key-value storage for persisting non-critical user preferences (selected team, language).
*   **Cached Network Image (`cached_network_image`):** Efficiently loads and caches network images.
*   **intl (`intl`):** Used for date formatting and localization support.
*   **Flutter DotEnv (`flutter_dotenv`):** Loads environment variables from a `.env` file for secure credential management.
*   **Flutter HTML (`flutter_html`):** Renders HTML content within Flutter widgets, used for article bodies.
*   **URL Launcher (`url_launcher`):** Launches URLs in the default browser (used for source links in articles).
*   **Share Plus (`share_plus`):** Invokes the native platform sharing UI.

## Architecture & Key Concepts

### State Management (Riverpod)

*   Uses `ProviderScope` at the root (`main.dart`).
*   Widgets that need to read or interact with state use `ConsumerWidget` or `ConsumerStatefulWidget`.
*   **Providers Used:**
    *   `Provider`: For simple dependency injection (e.g., `newsFeedServiceProvider`, `articleDetailServiceProvider`, `preferenceServiceProvider`).
    *   `StateProvider`: For simple synchronous state (e.g., `selectedNavIndexProvider`, `newsFeedDisplayModeProvider`, `currentDetailArticleIdProvider`).
    *   `FutureProvider`: Used previously, potentially useful for one-off async reads.
    *   `FutureProvider.family`: For fetching async data based on a parameter (e.g., `articleDetailProvider(articleId)`).
    *   `StateNotifierProvider`/`AsyncNotifierProvider`: For more complex state involving async operations, pagination, user actions, and robust loading/error management (e.g., `localeNotifierProvider`, `selectedTeamNotifierProvider`, `paginatedArticlesProvider`).

### Backend Integration (Supabase)

*   Flutter app interacts with Supabase primarily through **Edge Functions** (e.g., `articlePreviews`, `articleDetail`).
*   Edge Functions are responsible for querying the database and returning structured data.
*   **Security (RLS):**
    *   Row Level Security (RLS) is **ENABLED** on relevant database tables.
    *   Public read policies (`SELECT` for `public` role) are defined based on data status (e.g., `status = 'PUBLISHED'`).
    *   Edge Functions called by the Flutter app **use the client's authentication context** (via the `SUPABASE_ANON_KEY` and the `Authorization` header) to ensure RLS policies are enforced.
    *   Backend Python scripts use the `SUPABASE_SERVICE_ROLE_KEY` to bypass RLS for administrative tasks.

### Navigation (State-Driven Inline Detail View)

*   A central `MainNavigationWrapper` widget handles the primary app structure and the persistent `GlobalAppBar`.
*   It adapts the *base* navigation elements based on screen width (`kMobileLayoutBreakpoint`):
    *   **Mobile (< 720px):** Displays a `BottomNavigationBar` *only* when not viewing article details.
    *   **Desktop/Tablet (>= 720px):** Displays a persistent `Drawer` accessible via the menu icon in the `GlobalAppBar`.
*   The main body content is controlled by the `currentDetailArticleIdProvider` (StateProvider):
    *   If `null`, the `IndexedStack` containing the main screens (`NewsFeedScreen`, `MyTeamScreen`, etc., selected via `selectedNavIndexProvider`) is shown.
    *   If an `articleId` is set, the `ArticleDetailScreen` (without its own Scaffold/AppBar) is displayed directly in the body.
*   Navigation *to* the detail screen occurs by setting the `currentDetailArticleIdProvider` state.
*   Navigation *back* from the detail screen occurs via an inline back button within `ArticleDetailScreen` that resets the `currentDetailArticleIdProvider` state to `null`.
*   This approach keeps the `GlobalAppBar` (with logo, title, potential menu/share/refresh actions) constant across views.

### Theming & Styling

*   A global theme is defined in `lib/core/theme/app_theme.dart` using `ThemeData`.
*   Colors are centralized in `lib/core/theme/app_colors.dart`.
*   A custom `GlobalAppBar` (`lib/core/widgets/global_app_bar.dart`) provides a consistent header. Actions (like share/refresh) are conditionally added within `MainNavigationWrapper`.
*   Widgets aim to use `Theme.of(context)` for consistency.
*   `flutter_html` uses `Style` objects to apply theme styles to rendered HTML content.

### Data Fetching & Services

*   Network calls to Supabase Edge Functions are encapsulated within **Service classes** (e.g., `NewsFeedService`, `ArticleDetailService`) located in the `data` folder of relevant features.
*   Riverpod providers (`newsFeedServiceProvider`, `articleDetailServiceProvider`) provide service instances.
*   Widgets interact with providers (`paginatedArticlesProvider`, `articleDetailProvider`), which handle async states and call services.

### Localization

*   Basic setup using `flutter_localizations` and `intl` for date formatting.
*   Supported locales: English (`en`), German (`de`).
*   `localeNotifierProvider` manages the current app locale, persisted via `shared_preferences`.
*   Widgets (like `ArticleListItem`, `HeadlineStoryCard`, `ArticleDetailScreen`) use the current locale to display appropriate text (headlines, content, dates).

### Local Persistence

*   `shared_preferences` is used via `PreferenceService` to store:
    *   User's selected language override.
    *   User's selected favorite team ID.

### Responsiveness

*   **Layout Adaptation:** `MainNavigationWrapper` switches between bottom navigation and a drawer based on screen width.
*   **Content Constraint:** On wider screens, the main content area (including the `ArticleDetailScreen` content) is centered and constrained to a maximum width (`kMaxContentWidth`).
*   **Widget Adaptation:** Specific widgets might adjust internally (e.g., `TeamHuddleSection`).

### HTML Content Rendering

*   The `flutter_html` package is used within `ArticleDetailScreen` to render article content strings containing HTML tags (`<p>`, `<div>`, `<a>`, etc.).
*   Styling is applied via the `Html` widget's `style` parameter to match the app's theme.
*   Links within the HTML content are made tappable using `onLinkTap` and `url_launcher`.

### Sharing

*   The `share_plus` package is used to trigger the native OS sharing UI.
*   A share action button is conditionally displayed in the `GlobalAppBar` (managed by `MainNavigationWrapper`) when viewing an article detail.
*   The button reads the current article's data (headline, URL) and uses `Share.share()` to initiate the sharing process.

## Implemented Features

*   **Core Setup:** Flutter project targeting iOS, Android, Web.
*   **Supabase Integration:** Initialization, secure credential loading, Edge Function interaction via Services.
*   **Global Theme:** Consistent app styling.
*   **Adaptive Navigation (State-Driven):**
    *   Persistent `GlobalAppBar`.
    *   Bottom navigation bar (mobile) / Drawer (desktop/web) for main sections.
    *   Article detail view shown *inline* within the main layout, controlled by Riverpod state.
    *   Inline back button for detail view navigation.
*   **Language Selection:** Global language picker (EN/DE) with persistence.
*   **News Feed (`NewsFeedScreen`):**
    *   Displays list of news article previews from `articlePreviews` Edge Function.
    *   Pull-to-Refresh.
    *   "Load Older" functionality & infinite scrolling pagination.
    *   Prominent headline story (overall or team-specific).
    *   Conditional "Team Huddle" section.
*   **Team Huddle Section:** Displays team logo, team headline, placeholders for games/injuries.
*   **My Team (`MyTeamScreen`):** Allows selection and persistence of a favorite team.
*   **Article Detail (`ArticleDetailScreen`):**
    *   Fetches full article data from `articleDetail` Edge Function based on ID.
    *   Displays image (with fallback: Image1 > Image2 > Image3), headline, source, date.
    *   Renders HTML content using `flutter_html` with theme styling.
    *   Provides a tappable link to the original source article using `url_launcher`.
    *   Includes Refresh and Share actions in the persistent `GlobalAppBar`.
    *   Handles loading and error states gracefully.
*   **Placeholder Screens:** Basic screens for Schedule and More.

## Running the App

1.  Ensure you have completed the [Getting Started](#getting-started) steps.
2.  Select your target device/platform in VS Code or using `flutter devices`.
3.  Start debugging:
    *   Press `F5` in VS Code.
    *   Or run `flutter run -d <device_id>` (e.g., `flutter run -d chrome`).

## Backend Notes

*   Relies on a **Supabase backend** with deployed **Edge Functions** (`articlePreviews`, `articleDetail`).
*   **RLS policies** in Supabase control data access.
*   **Python scripts** (run separately) handle backend data processing using the Service Role Key.

## Potential Next Steps

*   Implement the `Schedule` and `More` screens.
*   Implement real user authentication (Supabase Auth) and integrate it with RLS/providers.
*   Connect `UpcomingGamesCard` and `InjuryReportCard` to real data.
*   Refine error handling and user feedback across the app.
*   Add unit, widget, and integration tests.
*   Optimize performance further (image caching, build times, minimize widget rebuilds).
*   Implement a dark mode theme.
*   Refactor `teamLogoMap` and `teamFullNameMap` into a more robust data source (e.g., fetched from a `Teams` table in Supabase).
*   Complete platform-specific sharing logic if needed (e.g., providing different formats).
