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

Tackle4Loss aims to provide users with up-to-date American Football news. The main news feed is structured into three distinct sections: a horizontally scrollable "NFL Headlines" (Source 1 news), a "Story Lines" section displaying curated cluster stories as a paginated list (showing 4 items per UI page with a larger backend fetch buffer), and an "Other News" section listing the top 8 articles from other sources with a link to an "All News" screen. Users can select their favorite team and receive push notifications for new, relevant articles. The app also allows users to browse team information, including rosters and injury reports, and dive deep into "Story Lines" with a dedicated detail screen.

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
*   **(Backend) Supabase Account & Project:** Set up with necessary tables (`NewsArticles`, `Teams`, `DeviceToken`, `Rosters`, `Injuries`, `Player`, `clusters`, `cluster_images`, `cluster_summary`, `cluster_summary_int`, `timelines`, `SourceArticles`, `Source`). Ensure relationships and RLS policies are correctly configured. 

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
    *   Deploy all functions: `supabase functions deploy`. Ensure functions like `sendPushNotification`, `NFL_news`, `cluster_infos`, `articlePreviews`, `other_news`, `articleDetail`, `teams`, `roster`, `injuries`, `cluster_timeline`, `cluster_summary_by_id`, `coach_view_by_id`, `player_view_by_id`, `franchise_view_by_id`, `team_view_by_id`, and `dynamic_view_by_id` are successfully deployed.
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
        *   `constants/`: App-wide constants.
        *   `models/`: Shared data models.
        *   `navigation/`: Navigation setup.
        *   `providers/`: Shared Riverpod providers.
        *   `services/`: Shared services.
        *   `theme/`: Global theme data.
        *   `utils/`: Utility functions.
        *   `widgets/`: Common reusable widgets.
    *   `features/`: Feature modules.
        *   `news_feed/`
            *   `data/`: Models (`ArticlePreview`, `ClusterInfo`), Service (`NewsFeedService`). (*`news_feed_service_simplified.dart` removed*).
            *   `logic/`: Riverpod Providers (`nflHeadlinesProvider`, `paginatedArticlesProvider`, `paginatedClusterInfosProvider`). (*`news_feed_provider_simplified.dart` removed*).
            *   `ui/`: Screen (`NewsFeedScreen`), Widgets (`NflHeadlineItemCard`, `ClusterInfoListItem`, `OtherNewsListItem`, etc.).
        *   `my_team/` 
            *   `data/`, `logic/`, `ui/`
        *   `article_detail/`
            *   `data/`, `logic/`, `ui/`
        *   `cluster_detail/`
            *   `data/`: Models (`ClusterTimelineEntry`, `ClusterSummaryData`, `SingleViewData`, `DynamicViewsResponse`), Service (`ClusterDetailService`).
            *   `logic/`: Riverpod Providers (`clusterTimelineProvider`, `selectedTimelineEntryProvider`, `clusterSummaryProvider`, `coachViewProvider`, etc., `selectedAdditionalViewProvider`).
            *   `ui/`: Screens (`ClusterDetailScreen`), Widgets (`ClusterTimelineWidget`, `TimelineEntryDialogContent`, `ClusterSummaryWidget`, `AdditionalViewsTabsWidget`, `ViewContentSheet`).
        *   `all_news/`
            *   `ui/`
        *   `settings/`
            *   `ui/`
        *   `teams/`
            *   `data/`, `logic/`, `ui/`
        *   `schedule/`: Placeholder.
            *   `ui/`
        *   `more/`
            *   `ui/`
    *   `models/`: (Alternative location for ALL models).
*   `supabase/`: Supabase backend configuration.
    *   `functions/`: Edge Functions (including `cluster_timeline`, `cluster_summary_by_id`, `coach_view_by_id`, etc.).
        *   `_shared/`: Shared code for functions.
*   `web/`: Web platform specific files.
    *   `firebase-messaging-sw.js`: Service worker for background web push notifications.

## Core Technologies & Packages
*   **Flutter & Dart**
*   **Riverpod:** State management.
*   **Supabase Flutter (`supabase_flutter`):** Supabase client, authentication, Edge Function calls.
*   **Firebase Core & Messaging (`firebase_core`, `firebase_messaging`):** Push notifications.
*   **Shared Preferences (`shared_preferences`):** Local persistence for user preferences (locale, favorite team).
*   **Flutter DotEnv (`flutter_dotenv`):** Managing environment variables (Supabase keys).
*   **Cached Network Image (`cached_network_image`):** Efficient image loading and caching.
*   **URL Launcher (`url_launcher`):** Opening external links.
*   **Smooth Page Indicator (`smooth_page_indicator`):** Visual indicator for `PageView`.
*   **Intl (`intl`):** Internationalization and localization (date formatting).
*   **Flutter HTML (`flutter_html`):** Renders HTML content.
*   **Share Plus (`share_plus`):** Sharing content.
*   **Collection (`collection`):** Utility functions for collections (e.g., `groupBy`).

## Architecture & Key Concepts

*   **State Management (Riverpod):**
    *   Uses `Provider`, `FutureProvider`, `StateProvider`, `StateNotifierProvider`, and `AsyncNotifierProvider` (often with `.family` modifier) for managing application state.
    *   Providers encapsulate data fetching logic and expose data streams/states to the UI.
    *   Dependency injection is handled by Riverpod.

*   **Backend Integration (Supabase):**
    *   Data is fetched from Supabase Edge Functions (e.g., `NFL_news`, `cluster_infos`, `articlePreviews`, `other_news`, `articleDetail`, etc.).
    *   `NewsFeedService`, `ArticleDetailService`, etc., encapsulate these function calls.
    *   Realtime updates (currently for logging, UI updates are a TODO) via Supabase Realtime.

*   **Navigation (State-Driven Detail & Pushed Routes):**
    *   `MainNavigationWrapper` handles primary bottom/side navigation.
    *   `currentDetailArticleIdProvider` (StateProvider) controls showing `ArticleDetailScreen` overlaying the main content for articles from the news feed.
    *   Direct `Navigator.push` is used for other screens like `AllNewsScreen`, `SettingsScreen`, `TeamsScreen`, `TeamDetailScreen`, and `ClusterDetailScreen`.

*   **Push Notifications (Firebase + Supabase):**
    *   FCM tokens are registered with Supabase (`DeviceToken` table), including the user's selected team.
    *   A Supabase Database Webhook on `NewsArticles` (INSERT) triggers an Edge Function (`sendPushNotification`).
    *   The Edge Function uses the Firebase Admin SDK (via secrets) to send targeted push notifications to devices subscribed to the relevant team.
    *   Background and foreground message handling is implemented in the Flutter app.

*   **Theming & Styling:**
    *   `AppTheme` defines light (and potentially dark) themes.
    *   `AppColors` centralizes color definitions.
    *   `GlobalAppBar` provides a consistent app bar, defaulting to an app logo unless a specific title widget is provided.

*   **Data Fetching & Services:**
    *   Dedicated service classes (e.g., `NewsFeedService`, `TeamService`, `RosterService`, `InjuryService`, `ClusterDetailService`) interact with Supabase Edge Functions.
    *   Providers use these services to fetch and manage data.
    *   **NFL Headlines:** Fetched via `getNflHeadlines` and displayed in a `PageView`.
    *   **Story Lines (Clusters):** Fetched via `paginatedClusterInfosProvider` which uses `NewsFeedService.getClusterInfos`. This provider fetches a larger buffer of items (e.g., 12) from the backend at a time to improve perceived performance for the UI's 4-item-per-page display.
    *   **Other News (NewsFeedScreen):** The top 8 articles are fetched from the `other_news` Edge Function via `NewsFeedService.getOtherNews` and displayed directly. A "See all News" link navigates to `AllNewsScreen`.
    *   **All News Screen:** Uses `paginatedArticlesProvider` with a team filter (or null for all teams) to display a fully paginated list of articles from the `articlePreviews` Edge Function.

*   **Localization:**
    *   Supports English ('en') and German ('de').
    *   `LocaleProvider` manages the current locale, persisted using `shared_preferences`.
    *   Uses `GlobalMaterialLocalizations`, `GlobalWidgetsLocalizations`, `GlobalCupertinoLocalizations`.

*   **Local Persistence:**
    *   `shared_preferences` is used by `PreferenceService` to store the user's selected favorite team ID and by `LocaleProvider` to store the selected language.

*   **Responsiveness:**
    *   `MainNavigationWrapper` adapts between `BottomNavigationBar` (mobile) and `Drawer` (desktop/tablet) based on `kMobileLayoutBreakpoint`.
    *   `GlobalAppBar` and other UI elements are designed to be responsive.
    *   `kMaxContentWidth` constrains content width on larger screens.

*   **HTML Content Rendering:**
    *   `flutter_html` package is used to render HTML content in `ArticleDetailScreen` and `ClusterDetailScreen` views.

*   **Sharing:**
    *   `share_plus` package allows sharing article links from `ArticleDetailScreen`.

## Implemented Features

*   **Core Setup:** Flutter project targeting iOS, Android, Web.
*   **Supabase & Firebase Integration:** Setup for data, auth, and push notifications.
*   **Push Notifications:** Backend-triggered notifications for team-specific news.
*   **Global Theme & AppBar.**
*   **Adaptive Navigation.**
*   **News Feed (`NewsFeedScreen`):**
    *   Redesigned three-part layout:
        1.  **NFL Headlines:** Horizontally scrollable `PageView` displaying articles from Source 1.
        2.  **Story Lines:** Displays `ClusterInfo` objects in a vertically scrollable list, paginated with 4 items per UI page. Fetches a larger buffer of items from the backend to enhance scrolling performance. Tapping a story navigates to `ClusterDetailScreen`.
        3.  **Other News:** Vertically lists the top 8 articles from the `other_news` Edge Function. Includes a "See all News" link that navigates to the `AllNewsScreen`.
    *   Pull-to-refresh for all sections.
*   **Cluster Detail Screen (`ClusterDetailScreen`):** 
    *   Displays detailed information for a selected "Story Line" (cluster).
    *   **Cluster Summary:** Shows a main headline, image (if available), and descriptive content (HTML rendered) for the cluster.
    *   **Interactive Timeline:**
        *   A horizontal, non-scrolling timeline with a glassmorphism background, positioned below the summary.
        *   Each dot represents a chronological event/update within the story.
        *   Tapping a dot opens a dialog overlay displaying the event's headline, date, and list of related source articles.
    *   **Additional Views Tabs:**
        *   A bottom tab bar with icons for different perspectives on the story (Coach, Player, Franchise, Team, and up to two Dynamic views).
        *   Tapping a tab icon fetches data for that specific view from a dedicated Edge Function.
        *   The fetched content (headline and HTML description) is displayed in a modal bottom sheet.
        *   Dynamic tabs adapt their labels based on `available_views` from the backend.
*   **All News (`AllNewsScreen`):** Fully paginated news feed with a team filter FAB, fetching from the `articlePreviews` Edge Function.
*   **More Options (`MoreOptionsSheetContent`):** Modal bottom sheet for navigation.
*   **Teams (`TeamsScreen`) & Team Detail (`TeamDetailScreen`):** Display team info, roster, game day (injuries), team-specific news. Roster and Injury tabs are paginated.
*   **Settings (`SettingsScreen`):** Favorite team and language selection.
*   **My Team (`MyTeamScreen`):** Displays team-specific information and news (news is paginated).
*   **Article Detail (`ArticleDetailScreen`):** Displays full article content.

## Running the App
*(No changes here)*

## Backend Notes

*   Relies on a **Supabase backend** with:
    *   Tables: `NewsArticles`, `Teams`, `DeviceToken`, `Rosters`, `Injuries`, `Player`, `clusters`, `cluster_images`, `cluster_summary`, `cluster_summary_int`, `timelines`, `SourceArticles`, `Source`.
    *   Edge Functions: 
        *   `NFL_news`, `cluster_infos` (supports pagination), `articlePreviews` (supports pagination and team filtering), `other_news` (supports pagination), `articleDetail`, `sendPushNotification`, `teams`, `roster`, `injuries`.
        *   **For Cluster Detail:** `cluster_timeline` (fetches chronological events for a cluster), `cluster_summary_by_id` (fetches main summary for a cluster), `coach_view_by_id`, `player_view_by_id`, `franchise_view_by_id`, `team_view_by_id`, `dynamic_view_by_id` (provide different perspectives on the cluster story).
    *   Database Webhook for push notifications.
    *   Secrets for Firebase and Supabase.
*   **RLS policies** control data access.
*   Relies on **Firebase Cloud Messaging (FCM)**.
*   Python scripts (run separately) handle backend data processing/scraping.

## Potential Next Steps (See ToDos.md)

Refer to the [ToDos.md](ToDos.md) file for a detailed list of potential improvements and next features.