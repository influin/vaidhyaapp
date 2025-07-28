import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';

class UserProfileHeader extends StatelessWidget {
  final String location;
  final VoidCallback onLocationTap;

  const UserProfileHeader({
    Key? key,
    this.location = 'Mumbai, Maharashtra',
    required this.onLocationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Hello, ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      'Rahul',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onLocationTap,
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: AppTheme.primaryBlue, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryBlue, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2), width: 2),
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.lightBlue.withOpacity(0.2),
                child: Text(
                  'R',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}