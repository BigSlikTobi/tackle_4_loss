# Story Line View Testing Plan

## Issue Summary
Story line views are mixed up and not matching their parent clusters when users click on green dots above story line images.

## Implemented Fixes

### 1. Enhanced StoryLineViewService
- ✅ Added optional `clusterId` parameter to `getStoryLineView()`
- ✅ Modified query parameters to include `cluster_id` when provided
- ✅ Added debug logging for cluster ID validation

### 2. Updated storyLineViewProvider
- ✅ Changed parameter type to include `clusterId`
- ✅ Provider now passes clusterId to the service

### 3. Improved _handleViewDotTap() method
- ✅ Added comprehensive debug logging for tracking data flow
- ✅ Modified to pass clusterId to the story line view provider
- ✅ Enhanced error logging with cluster context

## Testing Checklist

### Manual Testing Steps:
1. **Navigate to News Feed**
   - Load the app in Chrome browser
   - Verify news feed loads with story line items

2. **Access Cluster Detail Screen**
   - Click on a story line item to open Cluster Detail Screen
   - Verify the screen loads with correct cluster information

3. **Test Story Line View Dots**
   - Look for green dots above the story line image
   - Click on different dots to test view content
   - Verify that each dot shows content specific to that cluster

4. **Verify Debug Logs**
   - Open browser developer tools (F12)
   - Go to Console tab
   - Look for debug messages showing:
     - `[ClusterDetailScreen] Handling view dot tap for viewId: X, clusterId: Y`
     - `[StoryLineViewService] Fetching story line view ID: X, language: en, clusterId: Y`
     - `[StoryLineViewService] Including cluster_id for validation: Y`

5. **Cross-Cluster Validation**
   - Navigate to different clusters
   - Test story line view dots on each cluster
   - Verify each cluster's views are unique and not mixed up

### Expected Behavior:
- Story line views should only show content belonging to their parent cluster
- Debug logs should show cluster ID being passed correctly
- No cross-contamination of content between different clusters

### Backend Validation:
The Supabase edge function `story_line_view_by_id` should:
- Accept `cluster_id` parameter
- Validate that the requested view belongs to the specified cluster
- Return appropriate error if view doesn't belong to cluster

## Debug Logging Added:
```dart
// Service level logging
debugPrint("[StoryLineViewService] Fetching story line view ID: $storyLineViewId, language: $languageCode, clusterId: $clusterId");
debugPrint("[StoryLineViewService] Including cluster_id for validation: $clusterId");

// UI level logging  
debugPrint("[ClusterDetailScreen] Handling view dot tap for viewId: $viewId, clusterId: $clusterId, languageCode: $languageCode");
debugPrint("[ClusterDetailScreen] Successfully fetched view data for viewId: $viewId. Content length: ${viewData.content.length}");
```

## Files Modified:
- `/lib/features/cluster_detail/data/story_line_view_service.dart`
- `/lib/features/cluster_detail/logic/story_line_view_provider.dart`
- `/lib/features/cluster_detail/ui/cluster_detail_screen.dart`
