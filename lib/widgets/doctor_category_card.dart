import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';

// Rename DoctorCategory to DoctorSpecialization or create an alias
class DoctorSpecialization {
  final String name;
  final IconData icon;
  final String description;

  DoctorSpecialization({
    required this.name,
    required this.icon,
    required this.description,
  });
}

// Update the widget to accept DoctorSpecialization
class DoctorCategoryCard extends StatelessWidget {
  final DoctorSpecialization category; // or rename to specialization
  final bool isSelected;
  final VoidCallback onTap;

  const DoctorCategoryCard({
    Key? key,
    required this.category,
    this.isSelected = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.lightGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : AppTheme.lightGrey.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                category.description,
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}