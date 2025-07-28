import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidhya_front_end/services/api_providers.dart';
import 'package:vaidhya_front_end/widgets/custom_app_bar.dart';

import '../theme/app_theme.dart';
import '../screens/login_screen.dart';
import '../screens/hospital_service_form.dart';
import '../screens/hospital_services_management_screen.dart';

class HospitalHomeScreen extends StatefulWidget {
  const HospitalHomeScreen({super.key});

  @override
  State<HospitalHomeScreen> createState() => _HospitalHomeScreenState();
}

class _HospitalHomeScreenState extends State<HospitalHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HospitalProfileTab(),
    const HospitalServicesTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Hospital Home', showBackButton: false),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Services',
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final websiteController = TextEditingController();
    final bedCountController = TextEditingController();
    final doctorCountController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Hospital Profile'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Hospital Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: typeController,
                    decoration: const InputDecoration(
                      labelText: 'Hospital Type',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: websiteController,
                    decoration: const InputDecoration(
                      labelText: 'Website',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: bedCountController,
                    decoration: const InputDecoration(
                      labelText: 'Number of Beds',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: doctorCountController,
                    decoration: const InputDecoration(
                      labelText: 'Number of Doctors',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hospital name is required'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }
}

class HospitalProfileTab extends ConsumerWidget {
  const HospitalProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return userProfileAsync.when(
      data: (profileData) {
        // Extract hospital data from the nested 'user' object
        final userData = profileData['user'] ?? {};
        final hospitalData = {
          'name': userData['name'] ?? 'Unknown Hospital',
          'email': userData['email'] ?? 'No email provided',
          'role': userData['role'] ?? 'hospital',
          'facilityDetails':
              userData['facilityDetails'] ?? 'No details available',
          'type': userData['type'] ?? 'General Hospital',
          'city': userData['city'] ?? 'Unknown City',
          'state': userData['state'] ?? 'Unknown State',
          'rating': userData['rating'] ?? 0.0,
          'reviewCount': userData['reviewCount'] ?? 0,
          'address': userData['address'] ?? 'Address not provided',
          'phoneNumber':
              userData['phoneNumber'] ?? userData['mobile'] ?? 'Not provided',
          'website': userData['website'] ?? 'Not provided',
          'bedCount': userData['bedCount'] ?? 0,
          'doctorCount': userData['doctorCount'] ?? 0,
          'facilities': userData['facilities'] ?? [],
          'specialties': userData['specialties'] ?? [],
        };

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hospital Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue,
                      AppTheme.primaryBlue.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospitalData['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hospitalData['type'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hospitalData['facilityDetails'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Rating and Reviews
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${hospitalData['rating']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${hospitalData['reviewCount']} reviews)',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Contact Information
              _buildInfoCard('Contact Information', [
                _buildInfoRow(Icons.email, 'Email', hospitalData['email']),
                _buildInfoRow(
                  Icons.phone,
                  'Mobile',
                  hospitalData['phoneNumber'],
                ),
                _buildInfoRow(Icons.location_on, 'City', hospitalData['city']),
                _buildInfoRow(Icons.map, 'State', hospitalData['state']),
                _buildInfoRow(Icons.home, 'Address', hospitalData['address']),
              ]),
              const SizedBox(height: 16),

              // Hospital Details
              _buildInfoCard('Hospital Details', [
                _buildInfoRow(
                  Icons.hotel,
                  'Beds',
                  '${hospitalData['bedCount']}',
                ),
                _buildInfoRow(
                  Icons.people,
                  'Doctors',
                  '${hospitalData['doctorCount']}',
                ),
                _buildInfoRow(
                  Icons.language,
                  'Website',
                  hospitalData['website'],
                ),
              ]),
              const SizedBox(height: 16),

              // Facilities
              if (hospitalData['facilities'].isNotEmpty) ...[
                const Text(
                  'Facilities',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      hospitalData['facilities'].map<Widget>((facility) {
                        return Chip(
                          label: Text(facility.toString()),
                          backgroundColor: AppTheme.primaryBlue.withOpacity(
                            0.1,
                          ),
                          labelStyle: TextStyle(color: AppTheme.primaryBlue),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Specialties
              if (hospitalData['specialties'].isNotEmpty) ...[
                const Text(
                  'Specialties',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      hospitalData['specialties'].map<Widget>((specialty) {
                        return Chip(
                          label: Text(specialty.toString()),
                          backgroundColor: Colors.green.withOpacity(0.1),
                          labelStyle: const TextStyle(color: Colors.green),
                        );
                      }).toList(),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Failed to load profile',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.refresh(userProfileProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }
}

class HospitalServicesTab extends StatelessWidget {
  const HospitalServicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Directly show the services management screen content
    return const HospitalServicesManagementScreen();
  }
}
