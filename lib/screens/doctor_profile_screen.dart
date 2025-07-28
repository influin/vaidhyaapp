import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidhya_front_end/models/doctor_models.dart';
import 'package:vaidhya_front_end/services/api_providers.dart';

import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/widgets/custom_app_bar.dart';
import 'package:vaidhya_front_end/screens/appointment_booking_screen.dart';

class DoctorProfileScreen extends ConsumerWidget {
  final String doctorId;

  const DoctorProfileScreen({
    Key? key,
    required this.doctorId,
    required Map<String, dynamic> doctor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorProfileAsync = ref.watch(doctorProfileProvider(doctorId));

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: CustomAppBar(
        title: 'Doctor Profile',
        showBackButton: true,
        notificationCount: 3,
      ),
      body: doctorProfileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load doctor profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        () => ref.refresh(doctorProfileProvider(doctorId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        data:
            (doctorProfile) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDoctorHeader(doctorProfile),
                  _buildDoctorInfo(doctorProfile),
                  _buildServicesSection(doctorProfile),
                  _buildAddressSection(doctorProfile),
                  _buildAvailabilitySection(doctorProfile),
                  _buildAppointmentSection(context, doctorProfile),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildDoctorHeader(DoctorProfile doctor) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.white,
      child: Column(
        children: [
          // Doctor image
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.lightBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(Icons.person, color: AppTheme.primaryBlue, size: 60),
          ),
          const SizedBox(height: 16),
          // Doctor name
          Text(
            doctor.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 8),
          // Specialty
          Text(
            doctor.specialty,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          ),
          if (doctor.qualification.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              doctor.qualification,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
          const SizedBox(height: 16),
          // Rating and reviews
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                doctor.rating.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${doctor.reviewCount} reviews)',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Availability status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  doctor.isAvailableNow
                      ? AppTheme.primaryGreen.withOpacity(0.1)
                      : AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              doctor.isAvailableNow ? 'Available Now' : 'Not Available',
              style: TextStyle(
                color:
                    doctor.isAvailableNow
                        ? AppTheme.primaryGreen
                        : AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorInfo(DoctorProfile doctor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      color: AppTheme.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Doctor Information',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(icon: Icons.email, title: 'Email', value: doctor.email),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.phone,
            title: 'Phone',
            value: doctor.phoneNumber,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.calendar_today,
            title: 'Available Slots',
            value: '${doctor.availableSlots} slots',
          ),
          if (doctor.languages.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.language,
              title: 'Languages',
              value: doctor.languages.join(', '),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServicesSection(DoctorProfile doctor) {
    if (doctor.services.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      color: AppTheme.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Services & Pricing',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ...doctor.services
              .map(
                (service) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.serviceType,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${service.durationMinutes} minutes',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${service.currency} ${service.price.toInt()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildAddressSection(DoctorProfile doctor) {
    if (doctor.addresses.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      color: AppTheme.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ...doctor.addresses
              .map(
                (address) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppTheme.primaryBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              address.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (address.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Primary',
                                style: TextStyle(
                                  color: AppTheme.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${address.addressLine1}${address.addressLine2.isNotEmpty ? ', ${address.addressLine2}' : ''}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${address.city}, ${address.state} ${address.postalCode}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection(DoctorProfile doctor) {
    if (doctor.availability.workingDays.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      color: AppTheme.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Availability',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ...doctor.availability.workingDays
              .map(
                (workingDay) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            workingDay.day,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  workingDay.isAvailable
                                      ? AppTheme.primaryGreen
                                      : AppTheme.textSecondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              workingDay.isAvailable
                                  ? 'Available'
                                  : 'Not Available',
                              style: const TextStyle(
                                color: AppTheme.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (workingDay.isAvailable &&
                          workingDay.slots.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children:
                              workingDay.slots
                                  .map(
                                    (slot) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            slot.isBooked
                                                ? AppTheme.lightGrey
                                                : AppTheme.primaryBlue
                                                    .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color:
                                              slot.isBooked
                                                  ? AppTheme.textSecondary
                                                  : AppTheme.primaryBlue,
                                        ),
                                      ),
                                      child: Text(
                                        '${slot.startTime} - ${slot.endTime}',
                                        style: TextStyle(
                                          color:
                                              slot.isBooked
                                                  ? AppTheme.textSecondary
                                                  : AppTheme.primaryBlue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildAppointmentSection(BuildContext context, DoctorProfile doctor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            'Book Appointment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => AppointmentBookingScreen(
                          doctorId: doctorId,
                          doctorName: doctor.name,
                        ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Book Appointment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
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
}
