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
    *   [Navigation (State-Driven Inline Detail View & Overlays)](#navigation-state-driven-inline-detail-view--overlays) <!-- Updated -->
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

Tackle4Loss aims to provide users with up-to-date American Football news curated from different NFL Source News Sites like NFL.com or ESPN.com. Users can select their favorite team and receive push notifications for new, relevant articles.

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
*   **(Backend) Supabase Account & Project:** Set up with necessary tables (`NewsArticles`, `Teams`, `device_tokens`).

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
4.  **Deploy Supabase Edge Function:**
    *   Navigate to the `supabase/functions` directory if needed.
    *   Deploy the notification function: `supabase functions deploy sendPushNotification --no-verify-jwt`
    *   Deploy the data functions: `supabase functions deploy articlePreviews`, `supabase functions deploy articleDetail` (or deploy all).
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
        *   `constants/`: App-wide constants (e.g., `team_constants.dart`, `layout_constants.dart`).
        *   `models/`: Shared data models.
        *   `navigation/`: Navigation setup (`NavItem`, `MainNavigationWrapper`, `app_navigation.dart`).
        *   `providers/`: Shared Riverpod providers (e.g., `locale_provider.dart`, `navigation_provider.dart`, `preference_provider.dart`, `notification_provider.dart`, `realtime_provider.dart`).
        *   `services/`: Shared services (e.g., `preference_service.dart`, `notification_service.dart`, `realtime_service.dart`).
        *   `theme/`: Global theme data (`app_colors.dart`, `app_theme.dart`).
        *   `utils/`: Utility functions.
        *   `widgets/`: Common reusable widgets (e.g., `GlobalAppBar`, `LoadingIndicator`, `ErrorMessageWidget`).
    *   `features/`: Feature modules.
        *   `news_feed/`
            *   `data/`: Models (`ArticlePreview`), Services (`NewsFeedService`).
            *   `logic/`: Riverpod Providers (`news_feed_provider.dart` - Family Provider, `news_feed_state.dart`).
            *   `ui/`: Screens (`NewsFeedScreen`), Widgets (`ArticleListItem`, `HeadlineStoryCard`).
        *   `my_team/`
            *   `data/`: (If models/services specific to this feature are added)
            *   `logic/`: Providers (`selectedTeamNotifierProvider`).
            *   `ui/`: Screens (`MyTeamScreen`), Widgets (`UpcomingGamesCard`, `InjuryReportCard`, `TeamHuddleSection`, `TeamSelectionDropdown`, `TeamArticleList`).
        *   `article_detail/`
            *   `data/`: Models (`ArticleDetail`), Services (`ArticleDetailService`).
            *   `logic/`: Riverpod Providers (`article_detail_provider.dart`).
            *   `ui/`: Screens (`ArticleDetailScreen`).
        *   `all_news/` <!-- Added -->
            *   `ui/`: Screens (`AllNewsScreen` - Displays unfiltered news with team filter).
        *   `settings/` <!-- Added -->
            *   `ui/`: Screens (`SettingsScreen` - Contains team/language settings).
        *   `schedule/`: Placeholder.
            *   `ui/`: Screens (`ScheduleScreen`).
        *   `more/` <!-- Updated -->
            *   `ui/`: Widgets (`MoreOptionsSheetContent.dart` - Content for the bottom sheet overlay).
    *   `models/`: (Alternative location for ALL models if preferred over feature folders).
*   `supabase/`: Supabase backend configuration.
    *   `functions/`: Edge Functions (e.g., `articlePreviews`, `articleDetail`, `sendPushNotification`).
        *   `_shared/`: Shared code for functions (e.g., `cors.ts`).
*   `web/`: Web platform specific files.
    *   `firebase-messaging-sw.js`: **Required** Service worker for background web push notifications.

## Core Technologies & Packages

*   **Flutter:** Cross-platform UI toolkit.
*   **Dart:** Programming language for Flutter.
*   **Supabase:** Backend-as-a-Service:
    *   **Database:** PostgreSQL for data storage (`NewsArticles`, `device_tokens`, `Teams`).
    *   **Edge Functions:** Deno runtime for serverless backend logic (`articlePreviews` - now supports team filtering, `articleDetail`, `sendPushNotification`).
    *   **Database Webhooks:** Triggers the `sendPushNotification` function on new `NewsArticles` inserts.
    *   **Realtime:** Can be used for real-time UI updates (separate from push notifications).
    *   **Auth (Setup for):** Supabase Auth for user management (not fully implemented in UI yet).
    *   **Storage:** For storing images (potentially used by backend Python scripts).
*   **Firebase:** Platform services:
    *   **Firebase Core (`firebase_core`):** For initializing Firebase connection.
    *   **Firebase Cloud Messaging (FCM) (`firebase_messaging`):** For handling push notifications (permissions, token retrieval, message handling).
*   **FlutterFire:** Flutter plugins for Firebase.
*   **Riverpod (`flutter_riverpod`):** State management and dependency injection (using Providers, Notifiers, Family modifiers).
*   **Supabase Flutter (`supabase_flutter`):** Official Supabase client library for Flutter.
*   **Shared Preferences (`shared_preferences`):** Local key-value storage for persisting non-critical user preferences (selected team, language).
*   **Cached Network Image (`cached_network_image`):** Efficiently loads and caches network images.
*   **intl (`intl`):** Used for date formatting and localization support.
*   **Flutter DotEnv (`flutter_dotenv`):** Loads environment variables from a `.env` file.
*   **Flutter HTML (`flutter_html`):** Renders HTML content within Flutter widgets.
*   **URL Launcher (`url_launcher`):** Launches URLs in the default browser.
*   **Share Plus (`share_plus`):** Invokes the native platform sharing UI.
*   **jose (`jose` via esm.sh):** Used within the `sendPushNotification` Edge Function for JWT signing (FCM authentication).

## Architecture & Key Concepts

### State Management (Riverpod)

*   Uses `ProviderScope` at the root (`main.dart`).
*   Widgets use `ConsumerWidget` or `ConsumerStatefulWidget`.
*   **Providers Used:** `Provider` (services), `StateProvider` (simple state like filters), `FutureProvider.family` (async data with params), `StateNotifierProvider`/`AsyncNotifierProvider.family` (complex async state, preferences, paginated data lists with optional filtering). <!-- Updated -->

### Backend Integration (Supabase)

*   Flutter app interacts with Supabase for data (`articlePreviews`, `articleDetail` Edge Functions) and saving preferences/tokens (`device_tokens` table via `supabase_flutter` client).
*   Push notifications are triggered via a **backend-driven** flow (see [Push Notifications](#push-notifications-firebase--supabase) section).
*   **Security (RLS):** Enabled on tables. Policies allow `anon` role actions needed by the app (e.g., insert/update `device_tokens`) and `service_role` key used by the Database Webhook trigger.

### Navigation (State-Driven Inline Detail View & Overlays) <!-- Updated Title -->

*   `MainNavigationWrapper` handles adaptive layout (BottomNav/Drawer) and persistent `GlobalAppBar`.
*   `currentDetailArticleIdProvider` controls whether the main screen stack or `ArticleDetailScreen` is shown in the body. Navigation happens by changing this provider's state.
*   The "More" tab now triggers a modal bottom sheet overlay (`MoreOptionsSheetContent`) instead of navigating to a dedicated screen in the main stack. <!-- Added -->
*   Other screens like "All News" and "Settings" are pushed onto the navigation stack using `Navigator.push`. <!-- Added -->

### Push Notifications (Firebase + Supabase)

*   **Goal:** Notify users about new, published articles for their selected favorite team, even when the app is backgrounded or terminated.
*   **Technology:** Firebase Cloud Messaging (FCM) for cross-platform delivery.
*   **Flutter App Responsibilities (`NotificationService`):**
    *   Initializes Firebase (`firebase_core`).
    *   Requests user permission for notifications (`firebase_messaging`).
    *   Retrieves the unique FCM device registration token.
    *   Upserts the token (and platform) into the Supabase `device_tokens` table.
    *   Updates the `subscribed_team_id` in the `device_tokens` table when the user changes their favorite team (`SelectedTeamNotifier` triggers this).
    *   Listens for and handles foreground messages (currently logs to console).
    *   Registers a background message handler (`firebaseMessagingBackgroundHandler` in `main.dart`).
*   **Web Specific (`web/firebase-messaging-sw.js`):** A service worker file is required to handle background messages when the web app isn't active. It initializes Firebase Messaging Compat SDK.
*   **Backend Trigger Flow:**
    1.  **Database Insert:** A new row is inserted into `NewsArticles`.
    2.  **Supabase Webhook:** A Database Webhook configured on `NewsArticles` (for `INSERT` events) is triggered.
    3.  **Edge Function Call:** The webhook calls the `sendPushNotification` Supabase Edge Function (using the Service Role Key for auth).
    4.  **Edge Function (`sendPushNotification`):**
        *   Receives the inserted article data (`record`).
        *   Checks if `record.release == 'PUBLISHED'` and `record.team` is not null.
        *   Queries the `device_tokens` table to find all tokens where `subscribed_team_id` matches `record.team`.
        *   Authenticates with FCM using a Service Account Key (stored as a Supabase secret) by generating an OAuth2 token.
        *   Sends a push notification payload (title, body, `articleId` data) to each relevant token via the FCM HTTP v1 API.
    5.  **FCM Delivery:** FCM routes the message via APNS (iOS) or its own channel (Android/Web) to the targeted devices.
    6.  **Notification Display:** The OS displays the system notification if the app is backgrounded/terminated. The foreground handler runs if the app is active.

### Theming & Styling

*   Global theme (`AppTheme`), colors (`AppColors`), consistent `GlobalAppBar`. Uses `Theme.of(context)`.

### Data Fetching & Services

*   Network calls encapsulated in Service classes (`NewsFeedService`, `ArticleDetailService`, `NotificationService`, `PreferenceService`).
*   Riverpod providers manage service instances and data states (`paginatedArticlesProvider.family` - supports filtering, `articleDetailProvider`). <!-- Updated -->

### Localization

*   Basic setup (`flutter_localizations`, `intl`). EN/DE supported. `localeNotifierProvider` manages state, persisted via `shared_preferences`. Language can be changed in Settings screen. <!-- Updated -->

### Local Persistence

*   `shared_preferences` used via `PreferenceService` for language override and selected team ID (abbreviation). The `device_tokens` table in Supabase is the source of truth for notification subscriptions.

### Responsiveness

*   Layout adapts via `MainNavigationWrapper`. Content constrained via `kMaxContentWidth` on main screens and implemented on `AllNewsScreen`, `SettingsScreen`. <!-- Updated -->

### HTML Content Rendering

*   `flutter_html` used in `ArticleDetailScreen` with theme styling and link handling.

### Sharing

*   `share_plus` triggers native OS sharing UI from the `ArticleDetailScreen` (via `GlobalAppBar` action).

## Implemented Features

*   **Core Setup:** Flutter project targeting iOS, Android, Web.
*   **Supabase Integration:** Initialization, credential loading, Edge Function interaction (data fetch with filtering), DB table setup (`device_tokens`), Database Webhook trigger.
*   **Firebase Integration:** Core SDK init, FCM setup (permissions, token handling), Web Service Worker.
*   **Push Notifications:**
    *   User permission request (iOS, Android 13+).
    *   FCM Token retrieval and storage in Supabase `device_tokens` table.
    *   Linking stored token to user's selected team via `subscribed_team_id`.
    *   Backend-triggered notifications via Supabase Webhook -> Edge Function -> FCM for new, published articles matching the subscribed team.
    *   Receipt and display of system notifications (background/terminated) on iOS, Android, Web.
    *   Foreground message handling (console logs).
*   **Global Theme:** Consistent app styling.
*   **Adaptive Navigation (State-Driven):** Persistent `GlobalAppBar`, BottomNav/Drawer, Inline Article Detail view.
*   **News Feed (`NewsFeedScreen`):** Displays general news, Pagination, Pull-to-Refresh, Conditional Team Huddle based on user preference. <!-- Updated Description -->
*   **All News (`AllNewsScreen`):** Dedicated screen showing unfiltered news feed, Pagination, Pull-to-Refresh, Floating Action Button for team filtering. <!-- Added -->
*   **More Options (`MoreOptionsSheetContent`):** Modal bottom sheet overlay triggered from navigation, providing access to All News, Teams (placeholder), Settings. <!-- Added -->
*   **Settings (`SettingsScreen`):**
    *   **Favorite Team:** Allows selection/change of favorite team using an interactive logo grid with confirmation. Updates preference and notification subscription. <!-- Added -->
    *   **Language Selection:** Allows changing app language (EN/DE) with persistence. <!-- Added (Moved from Drawer) -->
*   **Team Huddle Section:** Displays team info based on selection (placeholder data for games/injuries). Shown conditionally on `NewsFeedScreen`.
*   **My Team (`MyTeamScreen`):** Team selection dropdown (redundant with Settings, consider refactor), displays team-specific articles (pagination pending). <!-- Updated Description -->
*   **Article Detail (`ArticleDetailScreen`):** Fetches/displays full article, HTML rendering, source link, refresh/share actions. Triggered via state change.
*   **Placeholder Screens:** Schedule.

## Running the App

1.  Ensure you have completed the [Getting Started](#getting-started) steps, including Firebase/Supabase setup, CLI configurations, secret setting, function deployment, and webhook configuration.
2.  Ensure an Android Emulator (with Google Play) or a physical device (iOS/Android) is running and connected, or use Chrome for web.
3.  For iOS physical devices, ensure your Apple Developer account is configured in Xcode and the device is registered.
4.  Select your target device/platform in VS Code or using `flutter devices`.
5.  Start debugging:
    *   Press `F5` in VS Code.
    *   Or run `flutter run -d <device_id>` (e.g., `flutter run -d chrome`, `flutter run -d emulator-5554`, `flutter run -d <your_iphone_id>`).
6.  **Grant Notification Permissions** when prompted on the device/emulator/web.

## Backend Notes

*   Relies on a **Supabase backend** with:
    *   Tables: `NewsArticles`, `Teams` (assumed), `device_tokens`.
    *   Edge Functions: `articlePreviews` (supports pagination, optional team filtering), `articleDetail`, `sendPushNotification`. <!-- Updated -->
    *   Database Webhook: `notifyOnNewArticle` triggering `sendPushNotification`.
    *   Secrets: `FIREBASE_PROJECT_ID`, `FCM_SERVICE_ACCOUNT_KEY_JSON`, `SUPABASE_URL`, `SUPABASE_ANON_KEY` required by `sendPushNotification`. Service Role Key used by Webhook trigger's `Authorization` header.
*   **RLS policies** control data access (ensure `device_tokens` allows needed actions by `anon` role, and Edge Function can read it).
*   Relies on **Firebase Cloud Messaging (FCM)** for push delivery infrastructure.
*   Python scripts (run separately) handle backend data processing/scraping.

## Potential Next Steps (See ToDos.md)

Refer to the [ToDos.md](ToDos.md) file for a detailed list of potential improvements and next features.
