import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/widgets/custom_app_bar.dart';

class CustomerAppBarContainer extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final bool showLocationSelector;
  final String? currentLocation;
  final VoidCallback? onLocationTap;
  final VoidCallback? onNotificationTap;
  final int notificationCount;
  final Widget child;

  const CustomerAppBarContainer({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.showLocationSelector = false,
    this.currentLocation,
    this.onLocationTap,
    this.onNotificationTap,
    this.notificationCount = 0,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        showBackButton: showBackButton,
        showLocationSelector: showLocationSelector,
        currentLocation: currentLocation,
        onLocationTap: onLocationTap,
        onNotificationTap: onNotificationTap,
        notificationCount: notificationCount,
      ),
      body: child,
    );
  }
}