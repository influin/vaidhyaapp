import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/screens/all_services_screen.dart';
import 'package:vaidhya_front_end/screens/vendor_discovery_screen.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'icon': Icons.local_pharmacy,
        'title': 'Medical Store',
        'color': AppTheme.primaryBlue,
        'serviceType': 'pharmacy',
      },
      {
        'icon': Icons.spa,
        'title': 'Ayurvedic Store',
        'color': Colors.green,
        'serviceType': 'ayurvedic',
      },
      {
        'icon': Icons.fitness_center,
        'title': 'Health & Fitness',
        'color': Colors.orangeAccent,
        'serviceType': 'health & fitness',
      },
      {
        'icon': Icons.medical_services,
        'title': 'Home Nurses / Caretakers',
        'color': Colors.redAccent,
        'serviceType': 'home nurses',
      },
      {
        'icon': Icons.biotech,
        'title': 'Diagnostic Centre',
        'color': Colors.purpleAccent,
        'serviceType': 'diagnostic',
      },
      {
        'icon': Icons.wheelchair_pickup,
        'title': 'Medical Equipments',
        'color': Colors.blueAccent,
        'serviceType': 'medical equipment',
      },
      {
        'icon': Icons.self_improvement,
        'title': 'Yoga Trainer',
        'color': Colors.teal,
        'serviceType': 'yoga trainer',
      },
      {
        'icon': Icons.more_horiz,
        'title': 'More',
        'color': AppTheme.primaryGreen,
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              'Our Services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) => _buildActionItem(
              context: context,
              icon: actions[index]['icon'] as IconData,
              title: actions[index]['title'] as String,
              color: actions[index]['color'] as Color,
              isMore: actions[index]['title'] == 'More',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    String? serviceType,
    bool isMore = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            if (isMore) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllServicesScreen(),
                ),
              );
            } else {
              // Navigate to vendor discovery screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VendorDiscoveryScreen(
                    serviceType: serviceType ?? title.toLowerCase(),
                  ),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
