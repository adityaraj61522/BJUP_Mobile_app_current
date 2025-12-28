# Notification Card System

This document explains the new notification card system that replaces `Get.snackbar` throughout the application.

## Overview

The notification system provides a more reliable and visually appealing way to display messages to users. It consists of animated notification cards that appear at the top of each page.

## Components

### 1. NotificationCard
A widget that displays a single notification with:
- Title and message
- Type-based styling (success, error, warning, info)
- Auto-dismiss functionality
- Manual dismiss option
- Smooth animations

### 2. NotificationController
A GetX controller that manages the notification state:
- `showSuccess(title, message)` - Green notification for success messages
- `showError(title, message)` - Red notification for error messages
- `showWarning(title, message)` - Orange notification for warning messages
- `showInfo(title, message)` - Blue notification for informational messages
- `hideNotification(id)` - Manually hide a specific notification
- `clearAll()` - Clear all notifications

### 3. NotificationCardsList
A widget that displays all active notifications in a stack overlay.

## Usage

### In Controllers

```dart
import '../common/notification_card.dart';

class MyController extends GetxController {
  final NotificationController notificationController = Get.find<NotificationController>();
  
  void someMethod() {
    // Show success
    notificationController.showSuccess('Success', 'Operation completed successfully');
    
    // Show error
    notificationController.showError('Error', 'Something went wrong');
    
    // Show warning
    notificationController.showWarning('Warning', 'Please check your input');
    
    // Show info
    notificationController.showInfo('Info', 'This is an informational message');
  }
}
```

### In Views (StatefulWidget)

```dart
import 'package:bjup_application/common/notification_card.dart';

class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final NotificationController notificationController = Get.find<NotificationController>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Your page content here
          Center(
            child: Text('Page Content'),
          ),
          
          // Add notification overlay
          NotificationCardsList(controller: notificationController),
        ],
      ),
    );
  }
}
```

### In Views (StatelessWidget with GetView)

```dart
import 'package:bjup_application/common/notification_card.dart';

class MyPage extends GetView<MyController> {
  final NotificationController notificationController = Get.find<NotificationController>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Your page content here
          Center(
            child: Text('Page Content'),
          ),
          
          // Add notification overlay
          NotificationCardsList(controller: notificationController),
        ],
      ),
    );
  }
}
```

## Migration from Get.snackbar

All `Get.snackbar` calls have been replaced with the new notification system:

| Old Code | New Code |
|----------|----------|
| `Get.snackbar('Title', 'Message', backgroundColor: AppColors.red)` | `notificationController.showError('Title', 'Message')` |
| `Get.snackbar('Title', 'Message', backgroundColor: AppColors.green)` | `notificationController.showSuccess('Title', 'Message')` |
| `Get.snackbar('Title', 'Message', backgroundColor: AppColors.orange)` | `notificationController.showWarning('Title', 'Message')` |
| `Get.snackbar('Title', 'Message')` | `notificationController.showInfo('Title', 'Message')` |

## Features

- ✅ **Auto-dismiss**: Notifications automatically disappear after 2 seconds (customizable)
- ✅ **Manual dismiss**: Users can tap the close button to dismiss
- ✅ **Animated**: Smooth scale and fade animations
- ✅ **Type-based styling**: Different colors and icons for each type
- ✅ **Dark mode support**: Adapts to light and dark themes
- ✅ **Stack management**: Multiple notifications stack vertically
- ✅ **Safe area aware**: Respects device notches and status bars

## Customization

### Custom Duration

```dart
notificationController.showError(
  'Error',
  'This will stay for 5 seconds',
  duration: Duration(seconds: 5),
);
```

### Custom Icon

```dart
notificationController.showNotification(
  title: 'Custom',
  message: 'With custom icon',
  type: NotificationType.info,
  customIcon: Icons.star,
);
```

### Non-dismissible

```dart
notificationController.showNotification(
  title: 'Important',
  message: 'Cannot be dismissed manually',
  type: NotificationType.warning,
  dismissible: false,
  autoHideDuration: Duration(seconds: 5),
);
```

## Files Updated

The following files have been updated to use the new notification system:

1. `lib/survey_form/survey_form_view.dart` - 16 replacements
2. `lib/attendence_list_page/attendence_list_controller.dart` - 17 replacements
3. `lib/add_beneficery_form/add_beneficery_form_view.dart` - 8 replacements
4. `lib/sync_survey_page/sync_survey_controller.dart` - 6 replacements
5. `lib/download_question_set_page/download_question_set_controller.dart` - 2 replacements
6. `lib/project_action_list/project_action_list_controller.dart` - 3 replacements
7. `lib/module_selection_page/module_selection_view_controller.dart` - 3 replacements
8. `lib/download_village_data_page/download_village_data_controller.dart` - 2 replacements
9. `lib/project_list_page/project_list_controller.dart` - 2 replacements
10. `lib/common/session/session_manager.dart` - 1 replacement
11. `lib/login_page/login_view.dart` - 1 replacement
12. `lib/start_monitoring_page/start_monitoring_controller.dart` - 1 replacement

**Total: 62 Get.snackbar calls replaced**

## Troubleshooting

### Notification not showing
- Ensure `NotificationCardsList` is added to your page's Stack
- Verify that `NotificationController` is initialized in `main.dart`
- Check that you're using `Get.find<NotificationController>()` correctly

### Multiple controllers error
- The `NotificationController` is initialized globally in `main.dart`
- Use `Get.find<NotificationController>()` to retrieve it, not `Get.put()`

### Styling issues
- The notification cards use Material Design and adapt to light/dark themes
- Colors are based on the notification type
- Customize by modifying `notification_card.dart`
