import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/widgets/custom_app_bar.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: const CustomAppBar(
        title: 'Terms of Service',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Terms of Service',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Last updated: ${DateTime.now().year}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Acceptance of Terms',
                'By accessing and using the Vaidhya app, you accept and agree to be bound by the terms and provision of this agreement.',
              ),
              _buildSection(
                'Use License',
                'Permission is granted to temporarily use the Vaidhya app for personal, non-commercial transitory viewing only.',
              ),
              _buildSection(
                'User Account',
                'You are responsible for safeguarding the password and for maintaining the confidentiality of your account.',
              ),
              _buildSection(
                'Prohibited Uses',
                'You may not use our service for any illegal or unauthorized purpose nor may you violate any laws in your jurisdiction.',
              ),
              _buildSection(
                'Service Availability',
                'We reserve the right to withdraw or amend our service, and any service or material we provide, without notice.',
              ),
              _buildSection(
                'Limitation of Liability',
                'In no event shall Vaidhya or its suppliers be liable for any damages arising out of the use or inability to use the service.',
              ),
              _buildSection(
                'Governing Law',
                'These terms and conditions are governed by and construed in accordance with applicable laws.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}