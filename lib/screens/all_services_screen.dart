import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/widgets/custom_app_bar.dart';
import 'package:vaidhya_front_end/screens/service_vendor_screen.dart';

class AllServicesScreen extends StatelessWidget {
  const AllServicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allServices = [
      {'icon': Icons.spa, 'title': 'Ayurvedic Store', 'color': Colors.green},
      {
        'icon': Icons.local_pharmacy,
        'title': 'Medical Store',
        'color': AppTheme.primaryBlue,
      },
      {'icon': Icons.eco, 'title': 'Herbal Store', 'color': Colors.lightGreen},
      {
        'icon': Icons.food_bank,
        'title': 'Food Supplements',
        'color': Colors.amber,
      },
      {
        'icon': Icons.fitness_center,
        'title': 'Health & Fitness',
        'color': Colors.orangeAccent,
      },
      {
        'icon': Icons.cleaning_services,
        'title': 'Sanitisation Services',
        'color': Colors.lightBlue,
      },
      {'icon': Icons.emergency, 'title': 'Ambulance', 'color': Colors.red},
      {'icon': Icons.air, 'title': 'Oxygen', 'color': Colors.blueGrey},
      {
        'icon': Icons.biotech,
        'title': 'Diagnostic Centre',
        'color': Colors.purpleAccent,
      },
      {
        'icon': Icons.wheelchair_pickup,
        'title': 'Medical Equipments',
        'color': Colors.blueAccent,
      },
      {'icon': Icons.science, 'title': 'Laboratories', 'color': Colors.indigo},
      {
        'icon': Icons.self_improvement,
        'title': 'Yoga Trainer',
        'color': Colors.teal,
      },
      {
        'icon': Icons.medical_services,
        'title': 'Home Nurses',
        'color': Colors.redAccent,
      },
      {
        'icon': Icons.support_agent,
        'title': 'Care Taker',
        'color': Colors.deepPurple,
      },
      {'icon': Icons.psychology, 'title': 'Therapist', 'color': Colors.pink},
      {
        'icon': Icons.spa_outlined,
        'title': 'Health and Wellness',
        'color': Colors.cyan,
      },
      {
        'icon': Icons.face_retouching_natural,
        'title': 'Cosmetologist',
        'color': Colors.deepOrange,
      },
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: 'All Services',
        showBackButton: true,
        showLocationSelector: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: allServices.length,
                  itemBuilder: (context, index) {
                    final service = allServices[index];
                    return _buildServiceItem(
                      context: context,
                      icon: service['icon'] as IconData,
                      title: service['title'] as String,
                      color: service['color'] as Color,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to service vendor screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceVendorScreen(serviceType: title),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
