import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/widgets/custom_app_bar.dart';

class ServiceVendorScreen extends StatelessWidget {
  final String serviceType;

  const ServiceVendorScreen({Key? key, required this.serviceType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample vendor data - in a real app, this would come from an API
    final vendors = _getVendorsForService(serviceType);

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: CustomAppBar(
        title: '$serviceType Vendors',
        showBackButton: true,
        showLocationSelector: false,
      ),
      body: SafeArea(
        child: vendors.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: vendors.length,
                itemBuilder: (context, index) {
                  return _buildVendorCard(context, vendors[index]);
                },
              ),
      ),
    );
  }

  Widget _buildVendorCard(BuildContext context, Map<String, dynamic> vendor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vendor logo/image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _getColorForService(serviceType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconForService(serviceType),
                    color: _getColorForService(serviceType),
                    size: 40,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${vendor['rating']} (${vendor['reviewCount']}+ reviews)',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppTheme.textSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              vendor['address'],
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            // Services offered section
            Text(
              'Services Offered',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ...(vendor['services'] as List).map((service) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      service['name'],
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      service['price'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Show a snackbar for now
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Calling ${vendor['name']}...'),
                          backgroundColor: AppTheme.primaryGreen,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: AppTheme.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.call, color: AppTheme.primaryBlue, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Call',
                          style: TextStyle(color: AppTheme.primaryBlue),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Show a snackbar for booking confirmation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Booking request sent to ${vendor['name']}'),
                          backgroundColor: AppTheme.primaryGreen,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppTheme.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.calendar_today, size: 16),
                        SizedBox(width: 8),
                        Text('Book'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Show a snackbar for directions
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening directions to ${vendor['name']}...'),
                          backgroundColor: AppTheme.primaryGreen,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: AppTheme.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions, color: AppTheme.primaryBlue, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Directions',
                          style: TextStyle(color: AppTheme.primaryBlue),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_mall_directory,
            size: 80,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No $serviceType vendors available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We are expanding our network. Please check back later.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  // Helper method to get vendors for a specific service type
  List<Map<String, dynamic>> _getVendorsForService(String serviceType) {
    // This would typically come from an API
    // For now, we'll use sample data
    switch (serviceType) {
      case 'Medical Store':
        return [
          {
            'name': 'HealthMart Pharmacy',
            'rating': 4.8,
            'reviewCount': 120,
            'address': '123 Healthcare Avenue, Medical District',
            'services': [
              {'name': 'Prescription Medicines', 'price': 'Varies'},
              {'name': 'OTC Medicines', 'price': 'Varies'},
              {'name': 'Home Delivery', 'price': '₹50'},
              {'name': 'Health Consultation', 'price': '₹200'},
            ],
          },
          {
            'name': 'MediCare Plus',
            'rating': 4.5,
            'reviewCount': 95,
            'address': '456 Wellness Road, Health Center',
            'services': [
              {'name': 'Prescription Medicines', 'price': 'Varies'},
              {'name': 'Medical Equipment Rental', 'price': '₹500/day'},
              {'name': 'Home Delivery', 'price': 'Free'},
              {'name': 'Health Checkup', 'price': '₹300'},
            ],
          },
          {
            'name': 'City Pharmacy',
            'rating': 4.2,
            'reviewCount': 78,
            'address': '789 Health Street, Medical Complex',
            'services': [
              {'name': 'Prescription Medicines', 'price': 'Varies'},
              {'name': 'OTC Medicines', 'price': 'Varies'},
              {'name': 'Vaccination', 'price': '₹400'},
              {'name': 'Blood Pressure Check', 'price': '₹50'},
            ],
          },
        ];
      case 'Ayurvedic Store':
        return [
          {
            'name': 'Ayush Wellness Center',
            'rating': 4.7,
            'reviewCount': 110,
            'address': '234 Natural Lane, Herbal District',
            'services': [
              {'name': 'Ayurvedic Medicines', 'price': 'Varies'},
              {'name': 'Herbal Consultation', 'price': '₹400'},
              {'name': 'Ayurvedic Massage', 'price': '₹800'},
              {'name': 'Panchakarma Therapy', 'price': '₹1500'},
            ],
          },
          {
            'name': 'Herbal Life Ayurveda',
            'rating': 4.6,
            'reviewCount': 85,
            'address': '567 Traditional Road, Ayurvedic Center',
            'services': [
              {'name': 'Herbal Medicines', 'price': 'Varies'},
              {'name': 'Ayurvedic Diet Plan', 'price': '₹600'},
              {'name': 'Yoga Sessions', 'price': '₹300/session'},
              {'name': 'Detox Programs', 'price': '₹2000'},
            ],
          },
        ];
      // Add more cases for other service types
      case 'Health & Fitness':
        return [
          {
            'name': 'FitLife Gym & Wellness',
            'rating': 4.9,
            'reviewCount': 150,
            'address': '789 Fitness Avenue, Sports District',
            'services': [
              {'name': 'Gym Membership', 'price': '₹2000/month'},
              {'name': 'Personal Training', 'price': '₹800/session'},
              {'name': 'Nutrition Consultation', 'price': '₹1200'},
              {'name': 'Group Classes', 'price': '₹500/class'},
            ],
          },
          {
            'name': 'HealthZone Fitness Center',
            'rating': 4.7,
            'reviewCount': 120,
            'address': '456 Wellness Boulevard, Fitness Complex',
            'services': [
              {'name': 'Gym Membership', 'price': '₹1800/month'},
              {'name': 'Yoga Classes', 'price': '₹400/class'},
              {'name': 'Diet Planning', 'price': '₹1000'},
              {'name': 'Fitness Assessment', 'price': '₹500'},
            ],
          },
        ];
      case 'Home Nurses / Caretakers':
        return [
          {
            'name': 'CarePlus Home Healthcare',
            'rating': 4.8,
            'reviewCount': 95,
            'address': '123 Nursing Lane, Healthcare District',
            'services': [
              {'name': 'Skilled Nursing Care', 'price': '₹1200/day'},
              {'name': '24/7 Caretaker', 'price': '₹1500/day'},
              {'name': 'Post-Surgery Care', 'price': '₹1400/day'},
              {'name': 'Elderly Care', 'price': '₹1300/day'},
            ],
          },
          {
            'name': 'HomeMed Nursing Services',
            'rating': 4.6,
            'reviewCount': 80,
            'address': '456 Care Street, Medical Center',
            'services': [
              {'name': 'Registered Nurse Visit', 'price': '₹800/visit'},
              {'name': 'Caretaker Services', 'price': '₹1200/day'},
              {'name': 'Physiotherapy at Home', 'price': '₹900/session'},
              {'name': 'Medical Equipment Setup', 'price': '₹500'},
            ],
          },
        ];
      // Add more cases for other service types
      default:
        return [
          {
            'name': '$serviceType Provider 1',
            'rating': 4.5,
            'reviewCount': 85,
            'address': '123 Service Street, Provider District',
            'services': [
              {'name': 'Basic Service', 'price': '₹500'},
              {'name': 'Premium Service', 'price': '₹1000'},
              {'name': 'Consultation', 'price': '₹300'},
              {'name': 'Home Visit', 'price': '₹800'},
            ],
          },
          {
            'name': '$serviceType Provider 2',
            'rating': 4.3,
            'reviewCount': 70,
            'address': '456 Provider Road, Service Center',
            'services': [
              {'name': 'Standard Package', 'price': '₹700'},
              {'name': 'Express Service', 'price': '₹1200'},
              {'name': 'Basic Consultation', 'price': '₹250'},
              {'name': 'Premium Package', 'price': '₹1500'},
            ],
          },
        ];
    }
  }

  // Helper method to get icon for service type
  IconData _getIconForService(String serviceType) {
    switch (serviceType) {
      case 'Medical Store':
        return Icons.local_pharmacy;
      case 'Ayurvedic Store':
        return Icons.spa;
      case 'Health & Fitness':
        return Icons.fitness_center;
      case 'Home Nurses / Caretakers':
        return Icons.medical_services;
      case 'Diagnostic Centre':
        return Icons.biotech;
      case 'Medical Equipments':
        return Icons.wheelchair_pickup;
      case 'Yoga Trainer':
        return Icons.self_improvement;
      case 'Herbal Store':
        return Icons.eco;
      case 'Food Supplements':
        return Icons.food_bank;
      case 'Sanitisation Services':
        return Icons.cleaning_services;
      case 'Ambulance':
        return Icons.emergency;
      case 'Oxygen':
        return Icons.air;
      case 'Laboratories':
        return Icons.science;
      case 'Care Taker':
        return Icons.support_agent;
      case 'Therapist':
        return Icons.psychology;
      case 'Health and Wellness':
        return Icons.spa_outlined;
      case 'Cosmetologist':
        return Icons.face_retouching_natural;
      default:
        return Icons.medical_services;
    }
  }

  // Helper method to get color for service type
  Color _getColorForService(String serviceType) {
    switch (serviceType) {
      case 'Medical Store':
        return AppTheme.primaryBlue;
      case 'Ayurvedic Store':
        return Colors.green;
      case 'Health & Fitness':
        return Colors.orangeAccent;
      case 'Home Nurses / Caretakers':
        return Colors.redAccent;
      case 'Diagnostic Centre':
        return Colors.purpleAccent;
      case 'Medical Equipments':
        return Colors.blueAccent;
      case 'Yoga Trainer':
        return Colors.teal;
      case 'Herbal Store':
        return Colors.lightGreen;
      case 'Food Supplements':
        return Colors.amber;
      case 'Sanitisation Services':
        return Colors.lightBlue;
      case 'Ambulance':
        return Colors.red;
      case 'Oxygen':
        return Colors.blueGrey;
      case 'Laboratories':
        return Colors.indigo;
      case 'Care Taker':
        return Colors.deepPurple;
      case 'Therapist':
        return Colors.pink;
      case 'Health and Wellness':
        return Colors.cyan;
      case 'Cosmetologist':
        return Colors.deepOrange;
      default:
        return AppTheme.primaryGreen;
    }
  }
}