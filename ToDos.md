# TODOs: Known Issues and Required Clean_ups

## Table of Contents

### High Priority / Core Functionality
- [Task: Implement Notification Tap Navigation](#task-implement-notification-tap-navigation)
- [Task: Resolve Persistent 404 Asset Loading Error on Web/Desktop](#task-resolve-persistent-404-asset-loading-error-on-webdesktop)
- [Task: Implement Pagination for Team-Specific Article List](#task-implement-pagination-for-team-specific-article-list)
- [Task: Implement FCM Token Cleanup Logic in Edge Function](#task-implement-fcm-token-cleanup-logic-in-edge-function)

### Medium Priority / User Experience & Refinements
- [Task: Create Global Language Selection Control for Adaptive UI](#task-create-global-language-selection-control-for-adaptive-ui)
- [Task: Add User Setting for Notification Opt-Out](#task-add-user-setting-for-notification-opt-out)
- [Task: Enhance Notification Content Dynamically](#task-enhance-notification-content-dynamically)
- [Task: Refactor Team ID Mapping (Fetch from DB)](#task-refactor-team-id-mapping-fetch-from-db)
- [Task: Add UI Feedback for Team Preference Saving/DB Update](#task-add-ui-feedback-for-team-preference-savingdb-update)
- [Task: Improve Background Message Handling Logic](#task-improve-background-message-handling-logic)


### Low Priority / Future Features
- [Task: (Optional) Support Multiple Team Subscriptions](#task-optional-support-multiple-team-subscriptions)
- [Task: Implement Schedule Screen](#task-implement-schedule-screen)
- [Task: Implement More Screen](#task-implement-more-screen)
- [Task: Connect UpcomingGamesCard and InjuryReportCard to Data](#task-connect-upcominggamescard-and-injuryreportcard-to-data)
- [Task: Add Dark Mode Theme](#task-add-dark-mode-theme)
- [Task: Add Unit, Widget, and Integration Tests](#task-add-unit-widget-and-integration-tests)


---
## High Priority / Core Functionality
---

### Task: Implement Notification Tap Navigation

**Problem:**
Currently, when a user taps a received push notification (background/terminated state), it simply opens the app to the last viewed screen or the default screen. It doesn't navigate to the specific article mentioned in the notification.

**Goal:**
When a push notification related to a specific news article is tapped, the app should open and navigate directly to the `ArticleDetailScreen` for that particular article.

**Possible Approaches & Considerations:**
*   **Utilize Data Payload:** The `sendPushNotification` Edge Function already includes the `articleId` in the FCM `data` payload.
*   **Handle `onMessageOpenedApp`:** Implement a listener for `FirebaseMessaging.onMessageOpenedApp`. This stream fires when the app is opened from a background state by tapping the notification. Inside the listener, extract the `articleId` from the message's `data` payload and update the `currentDetailArticleIdProvider` state (`ref.read(currentDetailArticleIdProvider.notifier).state = articleId;`).
*   **Handle `getInitialMessage`:** Implement logic using `FirebaseMessaging.instance.getInitialMessage()`. This checks if the app was opened from a *terminated* state by tapping a notification. Call this once, early in the app lifecycle (e.g., in `MyApp.initState` or the `main` function after initialization). If a message exists, extract the `articleId` and update the navigation provider. Ensure this logic runs *after* the Riverpod `ProviderContainer` is ready if updating state immediately.
*   **Navigation State:** Ensure that setting `currentDetailArticleIdProvider` correctly triggers the display of the `ArticleDetailScreen` via the logic in `MainNavigationWrapper`.

**Acceptance Criteria:**
*   Tapping a notification when the app is in the background opens the app and navigates to the correct article detail screen.
*   Tapping a notification when the app is terminated launches the app and navigates to the correct article detail screen.
*   The correct `articleId` is extracted from the notification's data payload.

### Task: Resolve Persistent 404 Asset Loading Error on Web/Desktop

**Problem:**
When running the application, particularly after selecting a "My Team" preference which triggers updates in the `TeamHuddleSection` and its child widgets, we consistently encounter 404 errors when trying to load team logo assets (`assets/assets/...`). The duplicated path segment **`assets/assets/`** indicates an incorrect path construction.

**Goal:**
Identify and fix the root cause of the duplicated `assets/` path. Ensure `Image.asset` consistently receives the correct path (e.g., `assets/team_logos/chicago_bears.png`) and logos load correctly across all relevant widgets (`TeamHuddleSection`, `UpcomingGamesCard`, `InjuryReportCard`, `TeamSelectionDropdown`), especially after selecting a team preference on web/desktop platforms.

**Possible Areas to Investigate:**
*   **Re-verify `Image.asset` Calls:** Meticulously re-examine every `Image.asset()` call using `getTeamLogoPath` in relevant widgets. Ensure no extra `assets/` prefix is added.
*   **`getTeamLogoPath` Function:** Double-check the return value of `getTeamLogoPath` in `lib/core/constants/team_constants.dart` to be absolutely certain it returns the correct format (`assets/team_logos/...`).
*   **Build/Cache Issues:** Consider persistent web build cache issues (`flutter clean` might not be enough).
*   **Widget Rebuilds:** Could rapid state updates or widget rebuilds somehow interfere with asset resolution specifically on web?
*   **Base URI Issues (Web):** Check if the web build's base URI (`<base href="/">` in `web/index.html`) is interfering with relative asset paths.

**Acceptance Criteria:**
*   Selecting a team correctly displays the team's logo in all relevant sections without 404 errors on web/desktop.
*   The path used to load the asset in the browser's network inspector is correctly formatted.

### Task: Implement Pagination for Team-Specific Article List

**Problem:**
The `TeamArticleList` widget (used on the "My Team" screen) currently fetches only the *first page* of articles for the selected team using a `FutureBuilder`. It doesn't support loading older articles for that team via infinite scrolling.

**Goal:**
Refactor `TeamArticleList` to support pagination, allowing users to continuously load more articles for their selected team as they scroll down. Use Riverpod for state management, fetching data page by page using the cursor from the `articlePreviews` Edge Function.

**Possible Approaches & Considerations:**
*   **Use Riverpod (Recommended):** Create an `AsyncNotifierProvider.family` (e.g., `teamArticlesProvider(teamId)`) to manage the paginated state per team.
    *   **Notifier Logic:** Implement `build` for initial fetch and `fetchNextPage` for subsequent fetches using `NewsFeedService.getArticlePreviews` with the `teamId` and `cursor`.
    *   **UI:** Convert `TeamArticleList` to `ConsumerWidget`, watch the provider, use `AsyncValue.when`, attach a `ScrollController` to the `ListView`, call `fetchNextPage` on scroll near bottom, display loading indicator.
*   **Error Handling:** Handle errors during subsequent page fetches gracefully.

**Acceptance Criteria:**
*   Scrolling down the "My Team" article list triggers fetching of the next page for the selected team.
*   New articles are appended seamlessly.
*   A loading indicator is shown while fetching subsequent pages.
*   Pagination stops when no more articles are available.
*   Uses Riverpod for state management.

### Task: Implement FCM Token Cleanup Logic in Edge Function

**Problem:**
If a user uninstalls the app or notification permissions are revoked, the FCM token becomes invalid. The backend currently doesn't remove these stale tokens from the `device_tokens` table, leading to wasted send attempts by the `sendPushNotification` Edge Function.

**Goal:**
Add logic to the `sendPushNotification` Edge Function to detect specific FCM API error responses indicating an invalid/unregistered token and delete that token from the `device_tokens` table.

**Implementation Steps:**
1.  **Edge Function (`sendFcmMessage` helper):** Analyze the response from the `fetch` call to the FCM API within the helper function.
2.  **Error Codes:** Check the response status (e.g., 400, 404) and the error body (which might be JSON or plain text) for specific FCM error codes like `UNREGISTERED` or `INVALID_ARGUMENT`. Refer to [FCM Error Codes Documentation](https://firebase.google.com/docs/cloud-messaging/manage-tokens#detect-invalid-token-responses-from-the-fcm-backend).
3.  **Delete Token:** If an unrecoverable token error is detected for a specific `token`, call `supabaseClient.from('device_tokens').delete().eq('token', token)` within the Edge Function to remove the stale entry. Handle potential errors during deletion gracefully (e.g., log them but don't fail the entire function).

---
## Medium Priority / User Experience & Refinements
---

### Task: Create Global Language Selection Control for Adaptive UI

**Problem:**
The app uses an adaptive navigation system (`MainNavigationWrapper`). Mobile uses `BottomNavigationBar`, while Desktop/Tablet uses a `Drawer`. The language selection UI currently resides only within the `Drawer`, making it inaccessible on mobile.

**Goal:**
Implement a language selection UI element that is accessible and consistent across both mobile and desktop layouts, allowing users to change the language preference managed by `localeNotifierProvider`.

**Possible Approaches:**
*   Move the language picker to the `GlobalAppBar`'s `actions` (e.g., using a `PopupMenuButton`).
*   Keep it in the `Drawer` for desktop but add a dedicated option within the mobile "More" screen.
*   Create a dedicated "Settings" screen accessible from both layouts.

### Task: Add User Setting for Notification Opt-Out

**Problem:**
Users currently cannot opt-out of team news notifications without disabling all notifications for the app at the OS level.

**Goal:**
Provide an in-app setting (e.g., on the "More" or a dedicated "Settings" screen) allowing users to toggle team news push notifications on/off.

**Implementation Steps:**
1.  **Database:** Add a boolean column (e.g., `notifications_enabled`, default `true`) to the `device_tokens` table.
2.  **Flutter UI:** Create the toggle switch UI element.
3.  **Flutter Logic:** When the toggle changes, call a method in `NotificationService` to update the `notifications_enabled` flag in the Supabase table for the current device token (`_currentFcmToken`).
4.  **Edge Function:** Modify the `sendPushNotification` Edge Function. Before fetching tokens (`select('token').eq('subscribed_team_id', teamNumericId)`), add another filter: `.eq('notifications_enabled', true)`. This ensures notifications are only sent to tokens that are subscribed *and* have notifications enabled.

### Task: Enhance Notification Content Dynamically

**Problem:**
Push notifications currently use a generic title ("Tackle4Loss News Update") and the article headline as the body.

**Goal:**
Make notification content more informative and engaging, potentially including the team name or other relevant details.

**Implementation Steps:**
1.  **Edge Function:** Modify the `sendPushNotification` Edge Function.
2.  **Fetch Team Name:** If needed, query the `Teams` table based on the `teamNumericId` to get the full team name.
3.  **Construct Dynamic Content:** Create more dynamic `title` and `body` strings within the Edge Function before sending to FCM. Example Title: `New Article for [Team Name]`. Example Body: Could still be the headline, or a truncated summary if available.
4.  **Consider Localization:** If fetching localized headlines/summaries is feasible in the Edge Function, potentially send different content based on device locale (would require storing locale preference alongside the token).

### Task: Refactor Team ID Mapping (Fetch from DB)

**Problem:**
The `teamAbbreviationToNumericId` map is currently hardcoded in `lib/core/constants/team_constants.dart`. This requires manual updates if team IDs change or teams are added/removed and is used by the `NotificationService` to update subscriptions.

**Goal:**
Remove the hardcoded map and fetch the team abbreviation-to-ID mapping dynamically from the `Teams` table in Supabase. Cache this data effectively using Riverpod.

**Implementation Steps:**
1.  **Create Service Method:** Add a method in a Supabase service (e.g., a new `TeamService` or existing relevant service) to fetch all teams (`select('id, abbreviation')`).
2.  **Create Riverpod Provider:** Create a `FutureProvider` or `Provider` that uses the service method to fetch the team data and transforms it into the required `Map<String, int>`. This provider should handle caching.
3.  **Update Consumers:** Modify code that currently uses the hardcoded map (`NotificationService.updateTeamSubscription`, potentially others) to read the mapping from the new Riverpod provider instead. Ensure loading/error states of the provider are handled gracefully, possibly using the hardcoded map as a temporary fallback during loading.

### Task: Add UI Feedback for Team Preference Saving/DB Update

**Problem:**
When the user selects a team, the app updates the subscription in the background (`NotificationService.updateTeamSubscription`), but there's no visual feedback indicating the progress or success/failure of this background database operation.

**Goal:**
Provide visual feedback (e.g., a temporary loading indicator, a success/error message via SnackBar) when the team subscription is being updated in the database.

**Implementation Steps:**
1.  **Modify `SelectedTeamNotifier.selectTeam`:** Make the call to `updateTeamSubscription` `await`-ed so you know when it completes.
2.  **State Management:** Introduce temporary loading/status states within the `MyTeamScreen` or potentially add status flags to the `AsyncValue` returned by `SelectedTeamNotifier` (might require making it return a custom state object instead of just `AsyncValue<String?>`).
3.  **UI Update:** Display a loading indicator while waiting for the `await`. Show a SnackBar or other message upon completion (success or error). Requires careful handling of state updates and widget rebuilds.

### Task: Improve Background Message Handling Logic

**Problem:**
The current `firebaseMessagingBackgroundHandler` only logs the received background message. It doesn't perform any app-specific actions based on the data received.

**Goal:**
Implement useful background logic if needed, such as updating an app badge count (requires additional plugins), pre-fetching the specific article data for faster display when the user opens the app from the notification, or triggering custom local notifications if needed.

**Considerations:**
*   Background execution time is limited, especially on iOS. Keep logic efficient.
*   Accessing shared preferences or other services might require careful setup in the background isolate.
*   Showing custom local notifications (using `flutter_local_notifications`) from the background handler provides more display control but requires additional setup.

---
## Low Priority / Future Features
---

### Task: (Optional) Support Multiple Team Subscriptions

**Problem:**
The current implementation only allows subscribing to notifications for a single favorite team (`subscribed_team_id`).

**Goal:**
Allow users to select and subscribe to notifications for multiple teams.

**Implementation Steps (High Level):**
1.  **Database:** Change `subscribed_team_id` (int) in `device_tokens` to `subscribed_team_ids` (int[] - array of integers).
2.  **Flutter UI:** Modify the "My Team" screen UI to allow multi-selection of teams.
3.  **Flutter Logic (`SelectedTeamNotifier` / `NotificationService`):** Update the logic to save/update the *array* of selected team numeric IDs in the `subscribed_team_ids` column for the device token.
4.  **Edge Function:** Modify the token fetching query to use the `.contains` or `@>` operator to select tokens where the `subscribed_team_ids` array contains the `teamNumericId` from the inserted article. `select('token').contains('subscribed_team_ids', [teamNumericId])`.

### Task: Implement Schedule Screen

**Problem:**
The 'Schedule' tab currently shows a placeholder screen.

**Goal:**
Implement the UI and logic for the Schedule screen, likely fetching and displaying upcoming/past game schedules (potentially filtered by selected team).

### Task: Implement More Screen

**Problem:**
The 'More' tab currently shows a placeholder screen.

**Goal:**
Implement the UI and logic for the More screen. This could be a place for settings (like language selection, notification toggle), about page, contact info, etc.

### Task: Connect UpcomingGamesCard and InjuryReportCard to Data

**Problem:**
The `UpcomingGamesCard` and `InjuryReportCard` widgets within the `TeamHuddleSection` currently display static placeholder data.

**Goal:**
Connect these widgets to actual data sources (likely new Supabase tables or Edge Functions) to display real upcoming games and injury reports for the selected team.

### Task: Add Dark Mode Theme

**Problem:**
The application currently only supports a light theme.

**Goal:**
Implement a dark theme variant (`AppTheme.darkTheme`) and allow users to select their preferred theme (Light, Dark, System) potentially via a setting on the "More" screen.

### Task: Add Unit, Widget, and Integration Tests

**Problem:**
There is a lack of automated tests in the project.

**Goal:**
Add comprehensive unit tests (for services, notifiers, utility functions), widget tests (for individual UI components), and integration tests (for feature flows like team selection, notification handling, navigation) to ensure code quality, prevent regressions, and facilitate refactoring.