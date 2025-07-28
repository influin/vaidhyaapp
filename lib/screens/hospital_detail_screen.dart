import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/screens/hospital_appointment_screen.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/widgets/custom_app_bar.dart';

class HospitalDetailScreen extends StatelessWidget {
  final Map<String, dynamic> hospital;

  const HospitalDetailScreen({Key? key, required this.hospital})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: CustomAppBar(
        title: 'Hospital Details',
        showBackButton: true,
        notificationCount: 3,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHospitalHeader(),
            _buildHospitalPhotos(), // Add the new photos section here
            _buildHospitalInfo(),
            _buildAppointmentSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.white,
      child: Column(
        children: [
          // Hospital image
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.local_hospital,
              color: AppTheme.primaryBlue,
              size: 60,
            ),
          ),
          const SizedBox(height: 16),
          // Hospital name
          Text(
            hospital['name'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Hospital type
          Text(
            hospital['type'],
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 16),
          // Rating and reviews
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                hospital['rating'].toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(80+ reviews)',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      color: AppTheme.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Hospital',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            '${hospital['name']} is a well-equipped ${hospital['type']} providing comprehensive healthcare services. The hospital has modern facilities and a team of experienced medical professionals dedicated to patient care.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          // Location
          _buildInfoRow(
            icon: Icons.location_on,
            title: 'Location',
            value: hospital['address'],
          ),
          const SizedBox(height: 12),
          // Beds
          _buildInfoRow(
            icon: Icons.hotel,
            title: 'Beds',
            value: hospital['beds'],
          ),
          const SizedBox(height: 12),
          // Doctors
          _buildInfoRow(
            icon: Icons.medical_services,
            title: 'Doctors',
            value: hospital['doctors'],
          ),
          const SizedBox(height: 12),
          // Availability
          _buildInfoRow(
            icon: Icons.access_time,
            title: 'Availability',
            value:
                hospital['available']
                    ? 'Available Now'
                    : 'Currently Unavailable',
            valueColor:
                hospital['available'] ? AppTheme.primaryGreen : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.lightGrey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppointmentSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Services',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          _buildServiceItem('General Consultation', '₹500 - ₹1000'),
          _buildServiceItem('Emergency Services', '₹1000 - ₹3000'),
          _buildServiceItem('Diagnostic Tests', '₹500 - ₹5000'),
          _buildServiceItem('Specialized Treatment', '₹2000 - ₹10000'),
          const SizedBox(height: 24),
          // Update the onPressed callback in the _buildAppointmentSection method
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to the appointment screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            HospitalAppointmentScreen(hospital: hospital),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: AppTheme.primaryBlue,
              ),
              child: const Text(
                'Book Appointment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String service, String priceRange) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.lightGrey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_services,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                service,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            priceRange,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalPhotos() {
    // List of equipment photos
    final List<Map<String, dynamic>> equipmentPhotos = [
      {
        'image':
            'assets/images/equipment1.png', // Replace with actual image paths
        'name': 'MRI Scanner',
      },
      {'image': 'assets/images/equipment2.png', 'name': 'CT Scan'},
      {'image': 'assets/images/equipment3.png', 'name': 'X-Ray Machine'},
      {'image': 'assets/images/equipment4.png', 'name': 'Ultrasound'},
      {'image': 'assets/images/equipment5.png', 'name': 'Laboratory'},
      {'image': 'assets/images/equipment6.png', 'name': 'Operation Theater'},
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      color: AppTheme.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hospital Facilities',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: equipmentPhotos.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.lightGrey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withOpacity(0.1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(7),
                              topRight: Radius.circular(7),
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              _getEquipmentIcon(equipmentPhotos[index]['name']),
                              color: AppTheme.primaryBlue,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          equipmentPhotos[index]['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEquipmentIcon(String equipmentName) {
    switch (equipmentName) {
      case 'MRI Scanner':
        return Icons.medical_services;
      case 'CT Scan':
        return Icons.biotech;
      case 'X-Ray Machine':
        return Icons.healing;
      case 'Ultrasound':
        return Icons.monitor_heart;
      case 'Laboratory':
        return Icons.science;
      case 'Operation Theater':
        return Icons.local_hospital;
      default:
        return Icons.medical_services;
    }
  }
}
