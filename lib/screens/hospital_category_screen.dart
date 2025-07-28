import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/widgets/custom_app_bar.dart';
import 'package:vaidhya_front_end/screens/hospital_discovery_screen.dart';

class HospitalCategoryScreen extends StatelessWidget {
  final double? latitude;
  final double? longitude;

  const HospitalCategoryScreen({Key? key, this.latitude, this.longitude})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // List of hospital categories
    final List<Map<String, dynamic>> categories = [
      {
        'name': 'General Hospital',
        'icon': Icons.local_hospital_outlined,
        'description': 'Full-service medical facilities',
        'type': 'general',
      },
      {
        'name': 'Specialty Hospital',
        'icon': Icons.medical_services_outlined,
        'description': 'Specialized medical care',
        'type': 'specialty',
      },
      {
        'name': 'Clinics',
        'icon': Icons.healing_outlined,
        'description': 'Outpatient medical services',
        'type': 'clinic',
      },
      {
        'name': 'Emergency Care',
        'icon': Icons.emergency_outlined,
        'description': '24/7 emergency services',
        'type': 'emergency',
      },
      {
        'name': 'Diagnostic Centers',
        'icon': Icons.biotech_outlined,
        'description': 'Medical testing facilities',
        'type': 'diagnostic',
      },
      {
        'name': 'Maternity Hospitals',
        'icon': Icons.pregnant_woman_outlined,
        'description': 'Maternal and infant care',
        'type': 'maternity',
      },
      {
        'name': 'Ayurvedic Centers',
        'icon': Icons.spa_outlined,
        'description': 'Traditional Indian medicine',
        'type': 'ayurvedic',
      },
      {
        'name': 'Veterinary Hospitals',
        'icon': Icons.pets_outlined,
        'description': 'Animal healthcare facilities',
        'type': 'veterinary',
      },
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Hospital Categories',
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
                'Select Hospital Type',
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
                    categories[index]['type'],
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
    String type,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to hospital discovery screen with the selected category, type, and location
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => HospitalDiscoveryScreen(
                  selectedCategory: name,
                  selectedType: type,
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
