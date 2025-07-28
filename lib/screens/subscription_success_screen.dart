import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/screens/doctor_home_screen.dart';
import 'package:vaidhya_front_end/screens/hospital_home_screen.dart';
import 'package:vaidhya_front_end/screens/vendor_home_screen.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';

class SubscriptionSuccessScreen extends StatefulWidget {
  final String userType;
  final Map<String, dynamic>? subscriptionDetails;
  
  const SubscriptionSuccessScreen({
    Key? key,
    required this.userType,
    this.subscriptionDetails,
  }) : super(key: key);
  
  @override
  State<SubscriptionSuccessScreen> createState() => _SubscriptionSuccessScreenState();
}

class _SubscriptionSuccessScreenState extends State<SubscriptionSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateToHome();
      }
    });
  }

  void _navigateToHome() {
    Widget homeScreen;
    
    // Navigate based on user type
    switch (widget.userType) {
      case 'doctor':
        homeScreen = const DoctorHomeScreen();
        break;
      case 'hospital':
        homeScreen = const HospitalHomeScreen();
        break;
      case 'vendor':
        homeScreen = const VendorHomeScreen();
        break;
      default:
        // This shouldn't happen, but just in case
        homeScreen = const DoctorHomeScreen();
    }
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => homeScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Add the subscription details display logic here
    if (widget.subscriptionDetails != null) {
      final subscription = widget.subscriptionDetails!;
      // Display subscription details like start date, end date, etc.
    }
    
    String userTypeDisplay = widget.userType.substring(0, 1).toUpperCase() + widget.userType.substring(1);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryGreen,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 32),
                // Success Title
                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Success Message
                Text(
                  'Your $userTypeDisplay account has been activated successfully. You will be redirected to your dashboard shortly.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Transaction Details
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildTransactionDetail('Amount Paid', '₹2,000'),
                      const Divider(height: 24),
                      _buildTransactionDetail('Transaction ID', 'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10)}'),
                      const Divider(height: 24),
                      _buildTransactionDetail('Date', '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
                      const Divider(height: 24),
                      _buildTransactionDetail('Subscription', 'Premium Plan (1 Year)'),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Continue Button
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _navigateToHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Continue to Dashboard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}