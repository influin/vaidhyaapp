import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vaidhya_front_end/models/user_models.dart';
import 'package:vaidhya_front_end/services/api_providers.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/widgets/custom_app_bar.dart';
import 'package:vaidhya_front_end/services/theme_provider.dart';
import 'package:vaidhya_front_end/screens/help_center_screen.dart';
import 'package:vaidhya_front_end/screens/privacy_policy_screen.dart';
import 'package:vaidhya_front_end/screens/terms_of_service_screen.dart';
import 'package:vaidhya_front_end/screens/about_vaidhya_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppTheme.darkBackground : AppTheme.lightGrey,
      appBar: const CustomAppBar(
        title: 'My Profile',
        showBackButton: false,
        notificationCount: 2,
      ),
      body: userProfileAsync.when(
        data: (data) {
          final userData = data['user'] as Map<String, dynamic>;
          final userProfile = UserProfile.fromJson(userData);
          return _buildProfileContent(context, ref, userProfile);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: TextStyle(color: Colors.red.shade500, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => ref.refresh(userProfileProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    UserProfile userProfile,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(context, userProfile),
          const SizedBox(height: 16),

          _buildAppSettings(context, ref),
          const SizedBox(height: 16),
          _buildSupportSection(context),
          const SizedBox(height: 24),
          _buildSignOutButton(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile userProfile) {
    final String firstLetter =
        userProfile.name.isNotEmpty ? userProfile.name[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryBlue.withOpacity(0.2),
                    width: 3,
                  ),
                ),
                child:
                    userProfile.profileImageUrl != null
                        ? CircleAvatar(
                          radius: 48,
                          backgroundImage: NetworkImage(
                            userProfile.profileImageUrl!,
                          ),
                        )
                        : CircleAvatar(
                          radius: 48,
                          backgroundColor: AppTheme.lightBlue.withOpacity(0.2),
                          child: Text(
                            firstLetter,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
              ),
              GestureDetector(
                onTap: () {
                  // Handle profile image change
                  _showImagePickerDialog(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: AppTheme.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            userProfile.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(
                userProfile.mobileNumber,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
              ),
            ],
          ),
          if (userProfile.email != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  userProfile.email!,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Navigate to edit profile screen
                _navigateToEditProfile(context);
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryBlue,
                side: BorderSide(color: AppTheme.primaryBlue),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthSection(BuildContext context) {
    return _buildSection(
      title: 'Health Information',
      icon: Icons.favorite,
      children: [
        _buildMenuItem(
          icon: Icons.medical_information,
          title: 'Medical Records',
          subtitle: 'View your medical history',
          iconColor: Colors.red,
          onTap: () => _navigateToMedicalRecords(context),
        ),
        _buildMenuItem(
          icon: Icons.medication,
          title: 'Medications',
          subtitle: 'Track your medications and prescriptions',
          iconColor: AppTheme.primaryGreen,
          onTap: () => _navigateToMedications(context),
        ),
        _buildMenuItem(
          icon: Icons.monitor_heart,
          title: 'Health Vitals',
          subtitle: 'Track your health metrics',
          iconColor: AppTheme.primaryBlue,
          onTap: () => _navigateToHealthVitals(context),
        ),
        _buildMenuItem(
          icon: Icons.family_restroom,
          title: 'Family Members',
          subtitle: 'Manage family profiles',
          iconColor: Colors.purple,
          onTap: () => _navigateToFamilyMembers(context),
        ),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return _buildSection(
      title: 'Account Settings',
      icon: Icons.settings,
      children: [
        _buildMenuItem(
          icon: Icons.person,
          title: 'Personal Information',
          subtitle: 'Manage your personal details',
          iconColor: AppTheme.primaryBlue,
          onTap: () => _navigateToPersonalInfo(context),
        ),
        _buildMenuItem(
          icon: Icons.location_on,
          title: 'Addresses',
          subtitle: 'Manage your saved addresses',
          iconColor: AppTheme.primaryGreen,
          onTap: () => _navigateToAddresses(context),
        ),
        _buildMenuItem(
          icon: Icons.payment,
          title: 'Payment Methods',
          subtitle: 'Manage your payment options',
          iconColor: Colors.orange,
          onTap: () => _navigateToPaymentMethods(context),
        ),
        _buildMenuItem(
          icon: Icons.history,
          title: 'Order History',
          subtitle: 'View your past orders and prescriptions',
          iconColor: Colors.brown,
          onTap: () => _navigateToOrderHistory(context),
        ),
      ],
    );
  }

  Widget _buildAppSettings(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return _buildSection(
      title: 'App Settings',
      icon: Icons.tune,
      children: [
        _buildSwitchMenuItem(
          icon: Icons.dark_mode,
          title: 'Dark Mode',
          subtitle: 'Switch between light and dark theme',
          iconColor: Colors.indigo,
          value: isDarkMode,
          onChanged: (value) {
            ref.read(themeProvider.notifier).toggleTheme();
          },
        ),
        _buildMenuItem(
          icon: Icons.language,
          title: 'Language',
          subtitle: 'English',
          iconColor: Colors.blue,
          onTap: () => _navigateToLanguageSettings(context),
        ),
        _buildMenuItem(
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'Manage notification preferences',
          iconColor: Colors.amber,
          onTap: () => _navigateToNotificationSettings(context),
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return _buildSection(
      title: 'Support',
      icon: Icons.support_agent,
      children: [
        _buildMenuItem(
          icon: Icons.help,
          title: 'Help Center',
          subtitle: 'Get help with the app',
          iconColor: AppTheme.primaryBlue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.policy,
          title: 'Privacy Policy',
          subtitle: 'Read our privacy policy',
          iconColor: Colors.grey,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacyPolicyScreen(),
              ),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.description,
          title: 'Terms of Service',
          subtitle: 'Read our terms of service',
          iconColor: Colors.grey,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TermsOfServiceScreen(),
              ),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.info,
          title: 'About Vaidhya',
          subtitle: 'App version 1.0.0',
          iconColor: AppTheme.primaryGreen,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AboutVaidhyaScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          ...children.map(
            (child) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: child,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildSwitchMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppTheme.primaryBlue,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showSignOutDialog(context),
        icon: const Icon(Icons.logout),
        label: const Text('Sign Out'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: AppTheme.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  // Helper methods for navigation and actions
  void _showImagePickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    // Handle camera capture
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    // Handle gallery selection
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    // Handle photo removal
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/onboarding',
                    (route) => false,
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Sign Out'),
              ),
            ],
          ),
    );
  }

  // Navigation methods (implement these based on your app structure)
  void _navigateToEditProfile(BuildContext context) {
    // Navigator.pushNamed(context, '/edit-profile');
  }

  void _navigateToMedicalRecords(BuildContext context) {
    // Navigator.pushNamed(context, '/medical-records');
  }

  void _navigateToMedications(BuildContext context) {
    // Navigator.pushNamed(context, '/medications');
  }

  void _navigateToHealthVitals(BuildContext context) {
    // Navigator.pushNamed(context, '/health-vitals');
  }

  void _navigateToFamilyMembers(BuildContext context) {
    // Navigator.pushNamed(context, '/family-members');
  }

  void _navigateToPersonalInfo(BuildContext context) {
    // Navigator.pushNamed(context, '/personal-info');
  }

  void _navigateToAddresses(BuildContext context) {
    // Navigator.pushNamed(context, '/addresses');
  }

  void _navigateToPaymentMethods(BuildContext context) {
    // Navigator.pushNamed(context, '/payment-methods');
  }

  void _navigateToOrderHistory(BuildContext context) {
    // Navigator.pushNamed(context, '/order-history');
  }

  void _navigateToLanguageSettings(BuildContext context) {
    // Navigator.pushNamed(context, '/language-settings');
  }

  void _navigateToNotificationSettings(BuildContext context) {
    // Navigator.pushNamed(context, '/notification-settings');
  }
}
