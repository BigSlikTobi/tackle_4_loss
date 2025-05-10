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
    *   [Navigation (State-Driven Detail & Pushed Routes)](#navigation-state-driven-detail--pushed-routes) 
    *   [Push Notifications (Firebase + Supabase)](#push-notifications-firebase--supabase)
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
11. [Potential Next Steps (See ToDos.md)](#potential-next-steps-see-todosmd)

## Overview

Tackle4Loss aims to provide users with up-to-date American Football news. The main news feed is structured into three distinct sections: a horizontally scrollable "NFL Headlines" (Source 1 news), a "Story Lines" section displaying curated cluster stories in a horizontally scrollable paged grid, and an "Other News" section listing articles from other sources with explicit pagination. Users can select their favorite team and receive push notifications for new, relevant articles. The app also allows users to browse team information, including rosters and injury reports.

This Flutter application serves as the user interface, interacting with a Supabase backend for data storage, retrieval (via Edge Functions), and push notification triggering (via Database Webhooks and Edge Functions). The app is designed to be responsive, adapting its layout for mobile, tablet, and web screens, supports push notifications on iOS, Android, and Web, and provides user settings for customization.

## Prerequisites

*   **Flutter SDK:** Version 3.x.x or later (check `flutter --version`). Install from [Flutter official site](https://docs.flutter.dev/get-started/install).
*   **Firebase CLI:** For configuring Firebase (`dart pub global activate flutterfire_cli`, `firebase login`).
*   **Supabase CLI:** For managing Edge Functions and secrets (`supabase login`, `supabase link`, `supabase functions deploy`, `supabase secrets set`).
*   **VS Code:** Recommended IDE. Install from [VS Code official site](https://code.visualstudio.com/).
*   **VS Code Flutter Extension:** Install from the VS Code Marketplace (includes Dart extension).
*   **Platform SDKs:**
    *   **Android:** Android Studio (for SDK, command-line tools, emulator **with Google Play Services**). Ensure NDK version compatibility (see `android/app/build.gradle.kts`).
    *   **iOS (macOS only):** Xcode (from Mac App Store), active Apple Developer account (for APNs setup). Requires a physical device for push notification testing.
    *   **Web:** Google Chrome (recommended for debugging).
*   **Run `flutter doctor -v`:** Ensure your environment is set up correctly for your target platforms.
*   **Git:** For cloning the repository.
*   **Firebase Project:** A Firebase project set up with Android, iOS, and Web apps registered.
*   **APNs Configuration:** APNs Auth Key or Certificate uploaded to Firebase Project Settings -> Cloud Messaging for iOS push notifications.
*   **(Backend) Supabase Account & Project:** Set up with necessary tables (`NewsArticles`, `Teams`, `DeviceToken`, `Rosters`, `Injuries`, `Player`, `clusters`, `cluster_images`, `cluster_summary`, `cluster_summary_int`). Ensure relationships and RLS policies are correctly configured. 

## Getting Started

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/BigSlikTobi/tackle_4_loss.git
    cd tackle_4_loss
    ```
2.  **Configure Firebase:**
    *   Ensure you have a Firebase project set up and have registered your iOS, Android, and Web apps.
    *   Make sure an **APNs Auth Key** is configured in your Firebase project settings for iOS notifications (Project Settings -> Cloud Messaging -> Apple app configuration).
    *   Run `firebase login` if needed.
    *   Run `flutterfire configure` in the project root to link your Flutter app to your Firebase project and generate `lib/firebase_options.dart`.
    *   Place the downloaded `google-services.json` in `android/app/`.
    *   Place the downloaded `GoogleService-Info.plist` in `ios/Runner/` using Xcode (ensure "Copy items if needed" is checked).
    *   Create `web/firebase-messaging-sw.js` and populate it with your Firebase web config values found in `lib/firebase_options.dart`.
3.  **Configure Supabase Credentials & Secrets:**
    *   Create a file named `.env` in the root directory of the project.
    *   Add your Supabase **URL** and **Anon Key**:
        ```plaintext
        # .env
        SUPABASE_URL=https://your-project-ref.supabase.co
        SUPABASE_ANON_KEY=your-public-anon-key
        ```
    *   **IMPORTANT:** Ensure `.env` is listed in your `.gitignore`.
    *   **Firebase Service Account Key:** Download the service account key JSON from Firebase Project Settings -> Service accounts -> Generate new private key.
    *   **Set Supabase Secrets:** Link your project (`supabase link --project-ref <ref>`) and set the following secrets using the Supabase CLI:
        ```bash
        supabase secrets set FIREBASE_PROJECT_ID=<YOUR_FIREBASE_PROJECT_ID>
        supabase secrets set FCM_SERVICE_ACCOUNT_KEY_JSON='<PASTE_ENTIRE_JSON_CONTENT_HERE>'
        # Set Supabase URL and Anon key if needed by functions accessing Supabase directly
        supabase secrets set SUPABASE_URL=<YOUR_SUPABASE_URL>
        supabase secrets set SUPABASE_ANON_KEY=<YOUR_SUPABASE_ANON_KEY>
        ```
4.  **Deploy Supabase Edge Functions:**
    *   Navigate to the `supabase/functions` directory if needed.
    *   Deploy the notification function: `supabase functions deploy sendPushNotification --no-verify-jwt`
    *   Deploy the data functions: `supabase functions deploy NFL_news`, `supabase functions deploy cluster_infos`, `supabase functions deploy articlePreviews`, `supabase functions deploy articleDetail`, `supabase functions deploy teams`, `supabase functions deploy roster`, `supabase functions deploy injuries` (or deploy all using `supabase functions deploy`). 
5.  **Configure Supabase Database Webhook:**
    *   Set up a Database Webhook in the Supabase Dashboard:
        *   **Name:** `notifyOnNewArticle` (or similar)
        *   **Table:** `NewsArticles`
        *   **Events:** `INSERT`
        *   **Type:** `Supabase Edge Functions`
        *   **Function:** `sendPushNotification`
        *   **Headers:** Add `Authorization: Bearer <YOUR_SUPABASE_SERVICE_ROLE_KEY>`, `Content-Type: application/json`, `apikey: <YOUR_SUPABASE_ANON_KEY>`.
6.  **Install Flutter dependencies:**
    ```bash
    flutter pub get
    ```
7.  **(Android Specific)** Ensure NDK version compatibility: Check `android/app/build.gradle.kts` (or `.gradle`) and add `ndkVersion = "..."` inside the `android` block if prompted by build errors.
8.  **Run the App:** (See [Running the App](#running-the-app) section below).

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
    *   `main.dart`: App entry point, Firebase/Supabase/DotEnv initialization, background notification handler setup.
    *   `firebase_options.dart`: Auto-generated Firebase configuration.
    *   `core/`: Shared code across features.
        *   `constants/`: App-wide constants (e.g., `team_constants.dart`, `layout_constants.dart`, `source_constants.dart`).
        *   `models/`: Shared data models.
        *   `navigation/`: Navigation setup (`NavItem`, `MainNavigationWrapper`, `app_navigation.dart`).
        *   `providers/`: Shared Riverpod providers (e.g., `locale_provider.dart`, `navigation_provider.dart`, `preference_provider.dart`, `notification_provider.dart`, `realtime_provider.dart`).
        *   `services/`: Shared services (e.g., `preference_service.dart`, `notification_service.dart`, `realtime_service.dart`).
        *   `theme/`: Global theme data (`app_colors.dart`, `app_theme.dart`).
        *   `utils/`: Utility functions.
        *   `widgets/`: Common reusable widgets (e.g., `GlobalAppBar`, `LoadingIndicator`, `ErrorMessageWidget`).
    *   `features/`: Feature modules.
        *   `news_feed/`
            *   `data/`: Models (`ArticlePreview`, `ClusterInfo`), Services (`NewsFeedService`).
            *   `logic/`: Riverpod Providers (`nflHeadlinesProvider`, `clusterInfosProvider`, `paginatedArticlesProvider` - Family Provider for general news, `otherNewsCurrentPageProvider`, `news_feed_state.dart`).
            *   `ui/`: Screens (`NewsFeedScreen`), Widgets (`NflHeadlineItemCard`, `ClusterInfoGridItem`, `OtherNewsListItem`).
        *   `my_team/` 
            *   `data/`: (If models/services specific to this feature are added)
            *   `logic/`: Providers (`selectedTeamNotifierProvider`).
            *   `ui/`: Screens (`MyTeamScreen`), Widgets (`UpcomingGamesCard`, `InjuryReportCard`, `TeamHuddleSection`, `TeamSelectionDropdown`, `TeamArticleList`).
        *   `article_detail/`
            *   `data/`: Models (`ArticleDetail`), Services (`ArticleDetailService`).
            *   `logic/`: Riverpod Providers (`article_detail_provider.dart`).
            *   `ui/`: Screens (`ArticleDetailScreen`).
        *   `all_news/`
            *   `ui/`: Screens (`AllNewsScreen` - Displays unfiltered news with team filter).
        *   `settings/`
            *   `ui/`: Screens (`SettingsScreen` - Contains team/language settings).
        *   `teams/`
            *   `data/`: Models (`TeamInfo`, `PlayerInfo`, `PlayerInjury`), Services (`TeamService`, `RosterService`, `InjuryService`).
            *   `logic/`: Riverpod Providers (`teams_provider.dart`, `roster_provider.dart`, `injury_provider.dart`, `position_groups.dart`).
            *   `ui/`: Screens (`TeamsScreen`, `TeamDetailScreen`), Widgets (`PlayerListItem`, `InjuryListItem`, `RosterTabContent`, `GameDayTabContent`, `TeamNewsTabContent`, `PlaceholderContent`).
        *   `schedule/`: Placeholder.
            *   `ui/`: Screens (`ScheduleScreen`).
        *   `more/`
            *   `ui/`: Widgets (`MoreOptionsSheetContent.dart` - Content for the bottom sheet overlay).
    *   `models/`: (Alternative location for ALL models if preferred over feature folders).
*   `supabase/`: Supabase backend configuration.
    *   `functions/`: Edge Functions (`NFL_news`, `cluster_infos`, `articlePreviews`, `articleDetail`, `sendPushNotification`, `teams`, `roster`, `injuries`). 
        *   `_shared/`: Shared code for functions (e.g., `cors.ts`).
*   `web/`: Web platform specific files.
    *   `firebase-messaging-sw.js`: **Required** Service worker for background web push notifications.

## Core Technologies & Packages

*   **Flutter:** Cross-platform UI toolkit.
*   **Dart:** Programming language for Flutter.
*   **Supabase:** Backend-as-a-Service:
    *   **Database:** PostgreSQL for data storage (`NewsArticles`, `DeviceToken`, `Teams`, `Rosters`, `Injuries`, `Player`, `clusters`, etc.). 
    *   **Edge Functions:** Deno runtime for serverless backend logic (`NFL_news` - fetches Source 1 headlines, `cluster_infos` - fetches paginated cluster stories, `articlePreviews` - supports team filtering/pagination/source exclusion, `articleDetail`, `sendPushNotification`, `teams`, `roster`, `injuries`).
    *   **Database Webhooks:** Triggers the `sendPushNotification` function on new `NewsArticles` inserts.
    *   **Realtime:** Can be used for real-time UI updates (separate from push notifications).
    *   **Auth (Setup for):** Supabase Auth for user management (not fully implemented in UI yet).
    *   **Storage:** For storing images. 
*   **Firebase:** Platform services:
    *   **Firebase Core (`firebase_core`):** For initializing Firebase connection.
    *   **Firebase Cloud Messaging (FCM) (`firebase_messaging`):** For handling push notifications.
*   **FlutterFire:** Flutter plugins for Firebase.
*   **Riverpod (`flutter_riverpod`):** State management and dependency injection.
*   **Supabase Flutter (`supabase_flutter`):** Official Supabase client library for Flutter.
*   **Shared Preferences (`shared_preferences`):** Local key-value storage.
*   **Cached Network Image (`cached_network_image`):** Efficiently loads and caches network images.
*   **intl (`intl`):** Used for date formatting and localization support.
*   **Flutter DotEnv (`flutter_dotenv`):** Loads environment variables from a `.env` file.
*   **Flutter HTML (`flutter_html`):** Renders HTML content.
*   **URL Launcher (`url_launcher`):** Launches URLs.
*   **Share Plus (`share_plus`):** Invokes native platform sharing UI.
*   **collection (`collection`):** Provides utilities like `groupBy`.
*   **Smooth Page Indicator (`smooth_page_indicator`):** For visually indicating pages in `PageView`.
*   **jose (`jose` via esm.sh):** Used within the `sendPushNotification` Edge Function for JWT signing.

## Architecture & Key Concepts

### State Management (Riverpod)

*   Uses `ProviderScope` at the root. Widgets use `ConsumerWidget` or `ConsumerStatefulWidget`.
*   **Providers Used:** 
    *   `FutureProvider`: For one-time async data fetches (e.g., `nflHeadlinesProvider`).
    *   `AsyncNotifierProvider`: For complex async state with pagination/updates (e.g., `clusterInfosProvider`).
    *   `AsyncNotifierProvider.family`: For paginated data lists with parameters (e.g., `paginatedArticlesProvider` used for "Other News" and team-specific news).
    *   `StateProvider`: For simple state like filters or current page index (e.g., `otherNewsCurrentPageProvider`, `nflHeadlinesPageIndexProvider`, `storyLinesPageIndexProvider`).
    *   `StateNotifierProvider`: For preferences and locale (`selectedTeamNotifierProvider`, `localeNotifierProvider`).

### Backend Integration (Supabase)

*   Flutter app interacts with Supabase Edge Functions for data:
    *   `NFL_news`: Fetches all headlines for Source 1.
    *   `cluster_infos`: Fetches paginated cluster stories.
    *   `articlePreviews`: Fetches paginated articles, supports `teamId` filtering and `excludeSourceId` (used for "Other News" and team-specific news).
    *   Other functions: `articleDetail`, `teams`, `roster`, `injuries`.
*   Push notifications are backend-driven.
*   **Security (RLS):** Enabled on tables.

### Navigation (State-Driven Detail & Pushed Routes) 

*   `MainNavigationWrapper` handles adaptive layout and persistent `GlobalAppBar`.
*   `currentDetailArticleIdProvider` controls inline `ArticleDetailScreen` display.
*   "More" tab uses a modal bottom sheet (`MoreOptionsSheetContent`).
*   Other screens like "Settings", "Teams" are pushed using `Navigator.push`.

### Push Notifications (Firebase + Supabase)

*   *(Flow remains the same)*

### Theming & Styling

*   Global theme (`AppTheme`), colors (`AppColors`), consistent `GlobalAppBar`.

### Data Fetching & Services

*   Network calls encapsulated in Service classes (`NewsFeedService`, `ArticleDetailService`, etc.).
*   `NewsFeedService` methods:
    *   `getNflHeadlines()`: Fetches articles for the top "NFL Headlines" section.
    *   `getClusterInfos()`: Fetches paginated `ClusterInfo` objects for the "Story Lines" section.
    *   `getArticlePreviews()`: Fetches paginated `ArticlePreview` objects, used for "Other News" (with `excludeSourceId: 1` and no `teamId`) and team-specific news (with `teamId`).
*   Riverpod providers manage service instances and data states (e.g., `nflHeadlinesProvider`, `clusterInfosProvider`, `paginatedArticlesProvider.family(null)` for "Other News").

### Localization

*   Basic setup (`flutter_localizations`, `intl`). EN/DE supported.

### Local Persistence

*   `shared_preferences` for language and selected team.

### Responsiveness

*   Layout adapts via `MainNavigationWrapper`. Content constrained via `kMaxContentWidth`.

### HTML Content Rendering

*   `flutter_html` used in `ArticleDetailScreen`.

### Sharing

*   `share_plus` used in `ArticleDetailScreen`.

## Implemented Features

*   **Core Setup:** Flutter project targeting iOS, Android, Web.
*   **Supabase & Firebase Integration:** Setup for data, auth, and push notifications.
*   **Push Notifications:** Backend-triggered notifications for team-specific news.
*   **Global Theme & AppBar.**
*   **Adaptive Navigation.**
*   **News Feed (`NewsFeedScreen`):**
    *   Redesigned three-part layout:
        1.  **NFL Headlines:** Horizontally scrollable `PageView` displaying articles from Source 1 (`NFL_news` EF), with page indicator.
        2.  **Story Lines:** Horizontally scrollable `PageView`, where each page is a 2x2 grid of `ClusterInfo` objects (`cluster_infos` EF), with page indicator. Pagination loads more clusters as user swipes.
        3.  **Other News:** Vertically listed articles from sources other than Source 1 (`articlePreviews` EF with source exclusion), with explicit page number navigation (e.g., "Page 1 of 5", Next/Prev buttons).
    *   Pull-to-refresh for all sections.
*   **All News (`AllNewsScreen`):** Unfiltered news feed, pagination, team filter FAB.
*   **More Options (`MoreOptionsSheetContent`):** Modal bottom sheet for navigation.
*   **Teams (`TeamsScreen`) & Team Detail (`TeamDetailScreen`):** Display team info, roster, game day (injuries), team-specific news.
*   **Settings (`SettingsScreen`):** Favorite team and language selection.
*   **My Team (`MyTeamScreen`):** Displays team-specific information and news.
*   **Article Detail (`ArticleDetailScreen`):** Displays full article content.

## Running the App

1.  Ensure you have completed the [Getting Started](#getting-started) steps.
2.  Ensure an Android Emulator or a physical device is running/connected, or use Chrome for web.
3.  For iOS physical devices, ensure Apple Developer account in Xcode.
4.  Select target device/platform.
5.  Start debugging (`F5` in VS Code or `flutter run`).
6.  Grant Notification Permissions.

## Backend Notes

*   Relies on a **Supabase backend** with:
    *   Tables: `NewsArticles`, `Teams`, `DeviceToken`, `Rosters`, `Injuries`, `Player`, `clusters`, `cluster_images`, `cluster_summary`, `cluster_summary_int`.
    *   Edge Functions: 
        *   `NFL_news`: Fetches all articles for Source 1.
        *   `cluster_infos`: Fetches paginated cluster story data.
        *   `articlePreviews`: Fetches paginated articles, supports `teamId` filter and `excludeSourceId` parameter. Expected to exclude Source 1 when fetching for "Other News".
        *   `articleDetail`, `sendPushNotification`, `teams`, `roster`, `injuries`.
    *   Database Webhook for push notifications.
    *   Secrets for Firebase and Supabase.
*   **RLS policies** control data access.
*   Relies on **Firebase Cloud Messaging (FCM)**.
*   Python scripts (run separately) handle backend data processing/scraping.

## Potential Next Steps (See ToDos.md)

Refer to the [ToDos.md](ToDos.md) file for a detailed list of potential improvements and next features.