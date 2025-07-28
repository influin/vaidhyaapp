import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidhya_front_end/services/api_providers.dart';
import 'package:vaidhya_front_end/services/api_service.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/widgets/google_places_address_input.dart';
import 'package:vaidhya_front_end/widgets/notification_panel.dart';
import 'package:vaidhya_front_end/widgets/location_selector.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showLocationSelector;
  final String? currentLocation;
  final VoidCallback? onLocationTap;
  final Function(PlaceDetails)? onPlaceSelected;
  final Function(String)? onCurrentLocationSelected; // Add this line
  final int? notificationCount;
  final VoidCallback? onNotificationTap;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.showLocationSelector = false,
    this.currentLocation,
    this.onLocationTap,
    this.onPlaceSelected,
    this.onCurrentLocationSelected, // Add this line
    this.notificationCount,
    this.onNotificationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primaryBlue,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading:
          showBackButton
              ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AppTheme.white),
                onPressed: () => Navigator.of(context).pop(),
              )
              : null,
      title:
          showLocationSelector
              ? LocationSelector(
                currentLocation: currentLocation,
                onLocationTap: onLocationTap,
                onPlaceSelected: onPlaceSelected,
                onCurrentLocationSelected:
                    onCurrentLocationSelected, // Add this line
              )
              : Text(
                title,
                style: const TextStyle(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
      actions: [
        // Notification bell with badge
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                _showLogoutConfirmation(context);
              },
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showNotificationPanel(BuildContext context) {
    // Example notifications - in a real app, these would come from a service or provider
    final notifications = [
      NotificationItem(
        id: '1',
        title: 'Appointment Reminder',
        message: 'Your appointment with Dr. Sharma is tomorrow at 10:00 AM',
        timeAgo: '1 hour ago',
        type: NotificationType.appointment,
      ),
      NotificationItem(
        id: '2',
        title: 'Medicine Reminder',
        message: 'Time to take your evening medication',
        timeAgo: '3 hours ago',
        type: NotificationType.reminder,
        isRead: true,
      ),
      NotificationItem(
        id: '3',
        title: 'New Message',
        message:
            'Dr. Patel has sent you a message regarding your recent test results',
        timeAgo: '1 day ago',
        type: NotificationType.message,
      ),
    ];

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: NotificationPanel(
              notifications: notifications,
              onClearAll: () {
                // Handle clear all notifications
                Navigator.of(context).pop();
              },
              onNotificationTap: (id) {
                // Handle notification tap
                Navigator.of(context).pop();
                // Navigate to relevant screen based on notification ID
              },
            ),
          ),
    );

    // Call the original onNotificationTap if provided
    if (onNotificationTap != null) {
      onNotificationTap!();
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Consumer(
            builder:
                (context, ref, _) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        // Perform logout action
                        final apiService = ref.read(apiServiceProvider);
                        apiService.clearAuthToken();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
          ),
    );
  }
}

// Remove this incorrect class
// class _showLogoutConfirmation {}
