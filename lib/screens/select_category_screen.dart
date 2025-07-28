import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/widgets/custom_app_bar.dart';
import 'package:vaidhya_front_end/screens/doctor_discovery_screen.dart';

class SelectCategoryScreen extends StatelessWidget {
  final double? latitude;
  final double? longitude;

  const SelectCategoryScreen({Key? key, this.latitude, this.longitude})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // List of medical categories
    final List<Map<String, dynamic>> categories = [
      {
        'name': 'Ayurvedic',
        'icon': Icons.spa_outlined,
        'description': 'Traditional Indian medicine',
      },
      {
        'name': 'Homeopathy',
        'icon': Icons.water_drop_outlined,
        'description': 'Alternative medicine',
      },
      {
        'name': 'Doctors/Physician',
        'icon': Icons.medical_services_outlined,
        'description': 'General practitioners',
      },
      {
        'name': 'Naturopathy',
        'icon': Icons.eco_outlined,
        'description': 'Natural healing methods',
      },
      {
        'name': 'Unani',
        'icon': Icons.healing_outlined,
        'description': 'Greco-Arabic medicine',
      },
      {
        'name': 'Alopathy',
        'icon': Icons.medication_outlined,
        'description': 'Modern medicine',
      },
      {
        'name': 'Baby Care',
        'icon': Icons.child_care_outlined,
        'description': 'Pediatric specialists',
      },
      {
        'name': 'Veterinary',
        'icon': Icons.pets_outlined,
        'description': 'Animal healthcare',
      },
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Categories',
        showBackButton: false,
        showLocationSelector: false,
        notificationCount: 3,
      ),
      backgroundColor: AppTheme.lightGrey.withOpacity(0.05),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Select Category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryCard(
                    context,
                    categories[index]['name'],
                    categories[index]['icon'],
                    categories[index]['description'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String name,
    IconData icon,
    String description,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to doctor discovery screen with the selected category and location
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => DoctorDiscoveryScreen(
                  selectedCategory: name,
                  latitude: latitude,
                  longitude: longitude,
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                description,
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
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
