import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidhya_front_end/models/doctor_models.dart';
import 'package:vaidhya_front_end/models/user_models.dart';
import 'package:vaidhya_front_end/screens/doctors/doctor_profile_edit_screen.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/services/api_providers.dart';

class DoctorProfileScreen extends ConsumerStatefulWidget {
  const DoctorProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DoctorProfileScreen> createState() =>
      _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends ConsumerState<DoctorProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Get user profile data from provider
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      body: userProfileAsync.when(
        data: (userData) {
          // Convert user data to doctor data format if needed
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(userData),
                _buildInfoSection(userData),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) =>
                Center(child: Text('Error loading profile: $error')),
      ),
    );
  }

  // Add this method for logout confirmation
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> userData) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppTheme.primaryBlue,
      child: Column(
        children: [
          // Profile image
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child:
                userData['profileImageUrl'] != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        userData['profileImageUrl'],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                    : Text(
                      userData['name']?.substring(0, 1) ?? 'D',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
          ),
          const SizedBox(height: 16),
          // Doctor name
          Text(
            userData['name'] ?? 'Doctor',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // Specialty and qualification
          Text(
            '${userData['specialty'] ?? 'Specialist'} | ${userData['qualification'] ?? 'MD'}',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 16),
          // Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                userData['rating']?.toString() ?? '4.5',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${userData['reviewCount'] ?? 0} reviews)',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Map<String, dynamic> userData) {
    // Check if data is nested under 'user' key
    final Map<String, dynamic> userDataMap =
        userData['user'] != null
            ? userData['user'] as Map<String, dynamic>
            : userData;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact information
          _buildSectionTitle('Contact Information'),
          const SizedBox(height: 8),

          // Only show email if it exists and is not empty
          if (userDataMap['email'] != null &&
              userDataMap['email'].toString().isNotEmpty)
            _buildInfoItem(Icons.email, 'Email', userDataMap['email']),

          // Add spacing if email was displayed
          if (userDataMap['email'] != null &&
              userDataMap['email'].toString().isNotEmpty)
            const SizedBox(height: 8),

          // Only show phone if it exists and is not empty
          if (userDataMap['mobileNumber'] != null &&
              userDataMap['mobileNumber'].toString().isNotEmpty)
            _buildInfoItem(Icons.phone, 'Phone', userDataMap['mobileNumber']),

          // Add spacing if either email or phone was displayed
          if ((userDataMap['email'] != null &&
                  userDataMap['email'].toString().isNotEmpty) ||
              (userDataMap['mobileNumber'] != null &&
                  userDataMap['mobileNumber'].toString().isNotEmpty))
            const SizedBox(height: 16),

          // About
          _buildSectionTitle('About'),
          const SizedBox(height: 8),
          Text(
            userDataMap['about'] ?? 'No information provided',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Languages
          _buildSectionTitle('Languages'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                ((userData['languages'] as List?) ?? ['English']).map((
                  language,
                ) {
                  return Chip(
                    label: Text(language.toString()),
                    backgroundColor: AppTheme.lightGrey,
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryBlue),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}
