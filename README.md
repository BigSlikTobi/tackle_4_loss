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

Tackle4Loss aims to provide users with up-to-date American Football news. The main news feed is structured into three distinct sections: a horizontally scrollable "NFL Headlines" (Source 1 news), a "Story Lines" section displaying curated cluster stories in a horizontally scrollable paged grid, and an "Other News" section listing articles from other sources with explicit pagination. Users can select their favorite team and receive push notifications for new, relevant articles. The app also allows users to browse team information, including rosters and injury reports, and dive deep into "Story Lines" with a dedicated detail screen.

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
    *   Deploy all functions: `supabase functions deploy`. Ensure functions like `sendPushNotification`, `NFL_news`, `cluster_infos`, `articlePreviews`, `articleDetail`, `teams`, `roster`, `injuries`, `cluster_timeline`, `cluster_summary_by_id`, `coach_view_by_id`, `player_view_by_id`, `franchise_view_by_id`, `team_view_by_id`, and `dynamic_view_by_id` are successfully deployed.
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
            *   `data/`, `logic/`, `ui/`
        *   `my_team/` 
            *   `data/`, `logic/`, `ui/`
        *   `article_detail/`
            *   `data/`, `logic/`, `ui/`
        *   `cluster_detail/`  <!-- NEW -->
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
*(No major changes here, but ensure all used packages like `flutter_html` are listed if they weren't explicitly before.)*
*   ... (Existing packages)
*   **Flutter HTML (`flutter_html`):** Renders HTML content (used in Article Detail & Cluster Detail).

## Architecture & Key Concepts
*(No major architectural shifts, but worth noting the new detail screen)*

### Navigation (State-Driven Detail & Pushed Routes) 
*   ... (Existing description)
*   `ClusterDetailScreen` is pushed via `Navigator.push` when a "Story Line" item is tapped.

## Implemented Features

*   **Core Setup:** Flutter project targeting iOS, Android, Web.
*   **Supabase & Firebase Integration:** Setup for data, auth, and push notifications.
*   **Push Notifications:** Backend-triggered notifications for team-specific news.
*   **Global Theme & AppBar.**
*   **Adaptive Navigation.**
*   **News Feed (`NewsFeedScreen`):**
    *   Redesigned three-part layout:
        1.  **NFL Headlines:** Horizontally scrollable `PageView` displaying articles from Source 1.
        2.  **Story Lines:** Horizontally scrollable `PageView`, where each page is a 2x2 grid of `ClusterInfo` objects. Tapping a story navigates to `ClusterDetailScreen`.
        3.  **Other News:** Vertically listed articles from other sources, with explicit page number navigation.
    *   Pull-to-refresh for all sections.
*   **Cluster Detail Screen (`ClusterDetailScreen`):** <!-- NEW SECTION -->
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
*   **All News (`AllNewsScreen`):** Unfiltered news feed, pagination, team filter FAB.
*   **More Options (`MoreOptionsSheetContent`):** Modal bottom sheet for navigation.
*   **Teams (`TeamsScreen`) & Team Detail (`TeamDetailScreen`):** Display team info, roster, game day (injuries), team-specific news.
*   **Settings (`SettingsScreen`):** Favorite team and language selection.
*   **My Team (`MyTeamScreen`):** Displays team-specific information and news.
*   **Article Detail (`ArticleDetailScreen`):** Displays full article content.

## Running the App
*(No changes here)*

## Backend Notes

*   Relies on a **Supabase backend** with:
    *   Tables: `NewsArticles`, `Teams`, `DeviceToken`, `Rosters`, `Injuries`, `Player`, `clusters`, `cluster_images`, `cluster_summary`, `cluster_summary_int`, `timelines`, `SourceArticles`, `Source`.
    *   Edge Functions: 
        *   `NFL_news`, `cluster_infos`, `articlePreviews`, `articleDetail`, `sendPushNotification`, `teams`, `roster`, `injuries`.
        *   **New for Cluster Detail:** `cluster_timeline` (fetches chronological events for a cluster), `cluster_summary_by_id` (fetches main summary for a cluster), `coach_view_by_id`, `player_view_by_id`, `franchise_view_by_id`, `team_view_by_id`, `dynamic_view_by_id` (provide different perspectives on the cluster story).
    *   Database Webhook for push notifications.
    *   Secrets for Firebase and Supabase.
*   **RLS policies** control data access.
*   Relies on **Firebase Cloud Messaging (FCM)**.
*   Python scripts (run separately) handle backend data processing/scraping.

## Potential Next Steps (See ToDos.md)

Refer to the [ToDos.md](ToDos.md) file for a detailed list of potential improvements and next features.