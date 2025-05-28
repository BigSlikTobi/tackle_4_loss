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
    *   [Navigation (GoRouter)](#navigation-gorouter)
    *   [Push Notifications (Firebase + Supabase)](#push-notifications-firebase--supabase)
    *   [Theming & Styling](#theming--styling)
    *   [Data Fetching & Services](#data-fetching--services)
    *   [Localization](#localization)
    *   [Local Persistence](#local-persistence)
    *   [Responsiveness](#responsiveness)
    *   [HTML Content Rendering](#html-content-rendering)
    *   [Sharing](#sharing)
    *   [SEO](#seo)
8.  [Implemented Features](#implemented-features)
9.  [Running the App](#running-the-app)
10. [Backend Notes](#backend-notes)
11. [Potential Next Steps (See ToDos.md)](#potential-next-steps-see-todosmd)

## Overview

Tackle4Loss aims to provide users with up-to-date American Football news. The main news feed is structured into distinct sections:
1.  **Featured Cluster Stories:** A horizontally scrollable `PageView` displaying curated cluster articles.
2.  **Story Lines:** A paginated section (4 items per UI page for mobile, horizontal scroll on web) showcasing condensed story narratives, leading to detailed views.
3.  **Other News:** A list of the latest articles from various sources, with a link to an "All News" screen for comprehensive browsing.

Users can select their favorite team to personalize their experience, including receiving targeted push notifications for new, relevant articles. The app also allows users to browse detailed team information (rosters, game day info, news), view league schedules and standings, and dive deep into "Story Lines" with a dedicated detail screen.

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
*   **(Backend) Supabase Account & Project:** Set up with necessary tables (`NewsArticles`, `Teams`, `DeviceToken`, `Rosters`, `Injuries`, `Player`, `clusters`, `cluster_images`, `cluster_summary`, `cluster_summary_int`, `timelines`, `SourceArticles`, `Source`, `StoryLineViews`, `Schedule`, `Standings`). Ensure relationships and RLS policies are correctly configured.

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
        supabase secrets set SUPABASE_URL=<YOUR_SUPABASE_URL>
        supabase secrets set SUPABASE_ANON_KEY=<YOUR_SUPABASE_ANON_KEY>
        ```
4.  **Deploy Supabase Edge Functions:**
    *   Navigate to the `supabase/functions` directory if needed.
    *   Deploy all functions: `supabase functions deploy`. Ensure functions like `sendPushNotification`, `NFL_news`, `cluster_infos`, `articlePreviews`, `other_news`, `articleDetail`, `teams`, `roster`, `injuries`, `schedule`, `standings`, `cluster_articles`, `story_lines`, `story_lines_by_id`, `story_line_view_by_id`, `timeline_by_cluster_id`, `cluster_summary_by_id`, `coach_view_by_id`, `player_view_by_id`, `franchise_view_by_id`, `team_view_by_id`, and `dynamic_view_by_id` are successfully deployed.
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
    *   `app.dart`: Root `MyApp` widget, `MaterialApp` setup including `GoRouter`.
    *   `main.dart`: App entry point, Firebase/Supabase/DotEnv initialization, background notification handler setup.
    *   `firebase_options.dart`: Auto-generated Firebase configuration.
    *   `core/`: Shared code across features.
        *   `config/`: Environment configuration (`EnvironmentConfig`).
        *   `constants/`: App-wide constants (`layout_constants.dart`, `source_constants.dart`, `team_constants.dart`).
        *   `extensions/`: Dart extensions (e.g., `ColorSchemeExtension`).
        *   `navigation/`: Navigation setup (`app_navigation.dart` for nav items, `app_router.dart` for GoRouter config, `main_navigation_wrapper.dart`, `nav_item.dart`).
        *   `providers/`: Shared Riverpod providers (`locale_provider.dart`, `navigation_provider.dart`, `preference_provider.dart`, `realtime_provider.dart`, `beta_banner_provider.dart`).
        *   `services/`: Shared services (`notification_service.dart`, `preference_service.dart`, `realtime_service.dart`).
        *   `theme/`: Global theme data (`app_colors.dart`, `app_theme.dart`).
        *   `widgets/`: Common reusable widgets (`error_message.dart`, `global_app_bar.dart`, `loading_indicator.dart`, `beta_banner.dart`, `web_detail_wrapper.dart`).
    *   `features/`: Feature modules.
        *   `news_feed/`
            *   `data/`: Models (`ArticlePreview`, `ClusterArticle`, `ClusterInfo`, `StoryLineItem`), Services (`NewsFeedService`, `StoryLinesService`).
            *   `logic/`: Riverpod Providers (`news_feed_provider.dart`, `featured_cluster_provider.dart`, `story_lines_provider.dart`).
            *   `ui/`: Screen (`NewsFeedScreen`), Widgets (`NflHeadlineItemCard`, `StoryLineGridItem`, `OtherNewsListItem`, `HeadlineStoryCard`, `ClusterInfoListItem`, `ArticleGridItem`).
        *   `my_team/`
            *   `ui/`: Screen (`MyTeamScreen`), Widgets (`TeamSelectionDropdown`, `TeamHuddleSection`, `UpcomingGamesCard`, `InjuryReportCard`).
        *   `article_detail/`
            *   `data/`: Model (`ArticleDetail`), Service (`ArticleDetailService`).
            *   `logic/`: Provider (`article_detail_provider.dart`).
            *   `ui/`: Screen (`ArticleDetailScreen`).
        *   `cluster_detail/`
            *   `data/`: Models (`ClusterSummaryData`, `SingleViewData`, `DynamicViewsResponse`, `StoryLineTimelineEntry`, `StoryLineTimelineResponse`, `StoryLineViewData`), Services (`ClusterDetailService`, `StoryLineTimelineService`, `StoryLineViewService`).
            *   `logic/`: Providers (`cluster_detail_provider.dart`, `story_line_timeline_provider.dart`, `story_line_view_provider.dart`).
            *   `ui/`: Screen (`ClusterDetailScreen`), Widgets (`ClusterSummaryWidget`, `AdditionalViewsTabsWidget`, `StoryLineTimelineWidget`).
        *   `all_news/`
            *   `ui/`: Screen (`AllNewsScreen`).
        *   `settings/`
            *   `ui/`: Screen (`SettingsScreen`).
        *   `teams/`
            *   `data/`: Models (`TeamInfo`, `PlayerInfo`, `PlayerInjury`, `ScheduleGameInfo`), Services (`TeamService`, `RosterService`, `InjuryService`, `ScheduleService` for team-specific schedule).
            *   `logic/`: Providers (`teams_provider.dart`, `roster_provider.dart`, `injury_provider.dart`, `schedule_provider.dart` for team-specific schedule, `position_groups.dart`).
            *   `ui/`: Screens (`TeamsScreen`, `TeamDetailScreen`), Widgets (`TeamNewsTabContent`, `GameDayTabContent`, `RosterTabContent`, `PlayerGroupList`, `PlayerListItem`, `InjuryListItem`, `UpcomingGamesTabContent`).
        *   `schedule/` (League-wide schedule)
            *   `data/`: Models (`ScheduleGame`), Service (`ScheduleService` for league schedule).
            *   `logic/`: Providers (`schedule_providers.dart`).
            *   `ui/`: Screen (`ScheduleScreen`), Widgets (`GameCard`).
        *   `standings/`
            *   `data/`: Models (`TeamStanding`), Service (`StandingsService`).
            *   `logic/`: Providers (`standings_provider.dart`).
            *   `ui/`: Screen (`StandingsScreen`), Widgets (`StandingsTable`, `StandingsViewSelector`).
        *   `more/`
            *   `ui/`: Widget (`MoreOptionsSheetContent`).
        *   `terms_privacy/`
            *   `ui/`: Screen (`TermsPrivacyScreen`).
*   `supabase/`: Supabase backend configuration.
    *   `functions/`: Edge Functions.
        *   `_shared/`: Shared code for functions.
*   `web/`: Web platform specific files.
    *   `firebase-messaging-sw.js`: Service worker for background web push notifications.
    *   `robots.txt`, `sitemap.xml`: SEO related files.
*   `assets/`: App assets (images, logos, fonts).

## Core Technologies & Packages
*   **Flutter & Dart**
*   **Riverpod (`flutter_riverpod`):** State management.
*   **GoRouter (`go_router`):** Declarative routing.
*   **Supabase Flutter (`supabase_flutter`):** Supabase client, authentication, Edge Function calls, Realtime.
*   **Firebase Core & Messaging (`firebase_core`, `firebase_messaging`):** Push notifications.
*   **Shared Preferences (`shared_preferences`):** Local persistence for user preferences.
*   **Flutter DotEnv (`flutter_dotenv`):** Managing environment variables for mobile.
*   **Cached Network Image (`cached_network_image`):** Efficient image loading and caching.
*   **URL Launcher (`url_launcher`):** Opening external links.
*   **Smooth Page Indicator (`smooth_page_indicator`):** Visual indicator for `PageView`.
*   **Intl (`intl`):** Internationalization and localization.
*   **Flutter HTML (`flutter_html`):** Renders HTML content.
*   **Share Plus (`share_plus`):** Sharing content.
*   **Collection (`collection`):** Utility functions for collections (e.g., `groupBy`).

## Architecture & Key Concepts

*   **State Management (Riverpod):**
    *   Utilizes `Provider`, `FutureProvider`, `StateProvider`, `StateNotifierProvider`, and `AsyncNotifierProvider` (often with `.family` modifier) for managing application state.
    *   Providers encapsulate data fetching logic and expose data streams/states to the UI.
    *   Handles dependency injection.

*   **Backend Integration (Supabase):**
    *   Data is fetched from Supabase Edge Functions (e.g., `NFL_news`, `story_lines`, `articlePreviews`, `cluster_articles`, `articleDetail`, `timeline_by_cluster_id`, etc.).
    *   Service classes (e.g., `NewsFeedService`, `StoryLinesService`, `ClusterDetailService`) encapsulate these function calls.
    *   Realtime updates from the `NewsArticles` table are handled by `RealtimeService` to invalidate relevant news providers for UI updates.

*   **Navigation (GoRouter):**
    *   `GoRouter` is used for declarative routing throughout the application.
    *   `MainNavigationWrapper` acts as a `ShellRoute` builder for screens with the main bottom/side navigation.
    *   Dedicated routes are defined for screens like `ArticleDetailScreen`, `ClusterDetailScreen`, `AllNewsScreen`, `TeamsScreen`, `TeamDetailScreen`, `SettingsScreen`, `StandingsScreen`, `ScheduleScreen`, and `TermsPrivacyScreen`.
    *   The `currentDetailArticleIdProvider` is still used in conjunction with GoRouter for scenarios where a detail view might overlay or replace content within the `MainNavigationWrapper`'s context before a full route push, but primary navigation between distinct app sections and detail views is handled by GoRouter.

*   **Push Notifications (Firebase + Supabase):**
    *   FCM tokens are registered with Supabase (`DeviceToken` table), including the user's selected team (numeric ID).
    *   A Supabase Database Webhook on `NewsArticles` (INSERT) triggers an Edge Function (`sendPushNotification`).
    *   The Edge Function uses the Firebase Admin SDK (via secrets) to send targeted push notifications to devices subscribed to the relevant team.
    *   Background and foreground message handling is implemented in the Flutter app.

*   **Theming & Styling:**
    *   `AppTheme` defines the light theme.
    *   `AppColors` centralizes color definitions.
    *   `GlobalAppBar` provides a consistent app bar, defaulting to an app logo unless a specific title widget is provided.

*   **Data Fetching & Services:**
    *   Dedicated service classes interact with Supabase Edge Functions.
    *   **News Feed Structure:**
        *   **Featured Cluster Articles:** Fetched via `featuredClusterProvider` (`cluster_articles` EF) and displayed in a `PageView`.
        *   **Story Lines:** Fetched via `paginatedStoryLinesProvider` (`story_lines` EF), supporting pagination and language.
        *   **Other News:** Fetched via `paginatedArticlesProvider(null)` (`articlePreviews` EF, top 8 shown, with a link to "All News").
    *   **All News Screen:** Uses `paginatedArticlesProvider` with team filtering.
    *   **Team Data:** `TeamService` for team list, `RosterService` for rosters, `InjuryService` for injuries, `ScheduleService` (team-specific) for game schedules.
    *   **League Data:** `ScheduleService` (league-wide) for general schedule, `StandingsService` for standings.
    *   **Cluster Detail:** `ClusterDetailService` (for `cluster_summary_by_id`, `coach_view_by_id`, etc.), `StoryLineTimelineService` (for `timeline_by_cluster_id`), `StoryLineViewService` (for `story_line_view_by_id`).

*   **Localization:**
    *   Supports English ('en') and German ('de').
    *   `LocaleProvider` manages the current locale, persisted using `shared_preferences`.
    *   Uses `GlobalMaterialLocalizations`, `GlobalWidgetsLocalizations`, `GlobalCupertinoLocalizations`.

*   **Local Persistence:**
    *   `shared_preferences` is used by `PreferenceService` to store the user's selected favorite team ID and by `LocaleProvider` to store the selected language. The `BetaBannerProvider` also uses it to manage banner dismissal state.

*   **Responsiveness:**
    *   `MainNavigationWrapper` adapts between `BottomNavigationBar` (mobile) and `Drawer` (desktop/tablet) based on `kMobileLayoutBreakpoint`.
    *   `GlobalAppBar`, `WebDetailWrapper`, and various feature-specific widgets incorporate responsive design principles.
    *   `kMaxContentWidth` constrains content width on larger screens.
    *   `NewsFeedScreen`'s Story Lines section has distinct mobile (vertical list with pagination) and web (horizontal scroll) layouts.

*   **HTML Content Rendering:**
    *   `flutter_html` package is used to render HTML content in `ArticleDetailScreen` and `ClusterDetailScreen` views (summary, story line view content).

*   **Sharing:**
    *   `share_plus` package allows sharing article links from `ArticleDetailScreen`.

*   **SEO:**
    *   Basic SEO support with `robots.txt` and `sitemap.xml` files in the `web/` directory. GoRouter is configured to allow these paths to be served directly.

## Implemented Features

*   **Core Setup:** Flutter project targeting iOS, Android, Web.
*   **Supabase & Firebase Integration:** Setup for data, auth, and push notifications.
*   **Push Notifications:** Backend-triggered notifications for team-specific news.
*   **Global Theme & AppBar.**
*   **Adaptive Navigation with GoRouter.**
*   **News Feed (`NewsFeedScreen`):**
    *   **Featured Cluster Articles:** Horizontally scrollable `PageView`.
    *   **Story Lines:** Paginated list (mobile) / horizontal scroll (web) of curated stories.
    *   **Other News:** Top articles with a link to "All News".
    *   Pull-to-refresh for all sections.
    *   Realtime UI updates for new articles.
*   **Article Detail Screen (`ArticleDetailScreen`):** Displays full article content with HTML rendering and sharing.
*   **Cluster Article Detail Screen (`ClusterArticleDetailScreen`):** Displays details of a featured cluster article.
*   **Story Line Detail Screen (`ClusterDetailScreen`):**
    *   Displays detailed information for a selected "Story Line."
    *   Shows main headline, image, and summary (HTML rendered).
    *   Interactive dots for different views/main content overlay.
    *   Integrates a `StoryLineTimelineWidget` for chronological events with a context menu.
    *   (Note: `AdditionalViewsTabsWidget` for Coach, Player, etc., exists but is not directly integrated into the main `ClusterDetailScreen` layout in the current codebase version.)
*   **All News (`AllNewsScreen`):** Fully paginated news feed with a team filter FAB.
*   **More Options (`MoreOptionsSheetContent`):** Modal bottom sheet for navigation to auxiliary screens.
*   **Teams (`TeamsScreen`):** Browse all teams, grouped by conference and division.
*   **Team Detail (`TeamDetailScreen`):**
    *   Tabbed interface for General Info (placeholder), Roster, Game Day, and Team News.
    *   Game Day tab includes nested tabs for Upcoming Games and Injuries.
    *   Roster, Injury, and News tabs are paginated.
*   **My Team (`MyTeamScreen`):**
    *   Personalized screen for the user's selected favorite team.
    *   Includes a "Team Huddle" section with the latest team headline.
    *   Tabbed interface similar to `TeamDetailScreen`.
*   **Schedule (`ScheduleScreen`):** Displays league-wide game schedules, filterable by week (including HOF game and preseason).
*   **Standings (`StandingsScreen`):** Displays NFL standings, viewable by League, Conference, or Division.
*   **Settings (`SettingsScreen`):** Favorite team selection and language preference (English/German).
*   **Terms & Privacy (`TermsPrivacyScreen`):** Displays terms of service and privacy policy.
*   **Beta Banner:** A dismissible banner displayed at the bottom of the app.
*   **SEO Basics:** `robots.txt` and `sitemap.xml` included for web.

## Running the App
*(No changes here)*

## Backend Notes

*   Relies on a **Supabase backend** with:
    *   Tables: `NewsArticles`, `Teams`, `DeviceToken`, `Rosters`, `Injuries`, `Player`, `clusters`, `cluster_images`, `cluster_summary`, `cluster_summary_int`, `timelines`, `SourceArticles`, `Source`, `StoryLineViews`, `Schedule` (for league schedule), `Standings`.
    *   Edge Functions:
        *   News & Articles: `NFL_news`, `articlePreviews`, `other_news`, `articleDetail`.
        *   Story Lines & Clusters: `cluster_articles` (featured), `story_lines` (news feed), `story_lines_by_id` (cluster detail main), `story_line_view_by_id` (cluster detail views), `timeline_by_cluster_id` (cluster detail timeline), `cluster_summary_by_id`, `coach_view_by_id`, `player_view_by_id`, `franchise_view_by_id`, `team_view_by_id`, `dynamic_view_by_id`.
        *   Team Data: `teams`, `roster`, `injuries`, `schedule_by_team_id`.
        *   League Data: `schedule` (league-wide), `standings`.
        *   Utility: `sendPushNotification`.
    *   Database Webhook for push notifications.
    *   Secrets for Firebase and Supabase.
*   **RLS policies** control data access.
*   Relies on **Firebase Cloud Messaging (FCM)**.
*   Python scripts (run separately) handle backend data processing/scraping.

## Potential Next Steps (See ToDos.md)

Refer to the [ToDos.md](ToDos.md) file for a detailed list of potential improvements and next features.