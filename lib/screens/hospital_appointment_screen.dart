import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/widgets/custom_app_bar.dart';

class HospitalAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> hospital;

  const HospitalAppointmentScreen({Key? key, required this.hospital}) : super(key: key);

  @override
  State<HospitalAppointmentScreen> createState() => _HospitalAppointmentScreenState();
}

class _HospitalAppointmentScreenState extends State<HospitalAppointmentScreen> {
  // State variables using ValueNotifier for reactive updates
  final ValueNotifier<DateTime> selectedDate = ValueNotifier(DateTime.now());
  final ValueNotifier<String?> selectedTimeSlot = ValueNotifier(null);
  final ValueNotifier<String?> selectedService = ValueNotifier(null);
  final ValueNotifier<String?> selectedDepartment = ValueNotifier(null);

  // List of available services with their prices
  final List<Map<String, String>> hospitalServices = [
    {'type': 'General Consultation', 'price': '₹500 - ₹1000'},
    {'type': 'Emergency Services', 'price': '₹1000 - ₹3000'},
    {'type': 'Diagnostic Tests', 'price': '₹500 - ₹5000'},
    {'type': 'Specialized Treatment', 'price': '₹2000 - ₹10000'},
  ];

  // List of departments
  final List<String> departments = [
    'General Medicine',
    'Cardiology',
    'Orthopedics',
    'Neurology',
    'Pediatrics',
    'Gynecology',
    'Dermatology',
    'Ophthalmology',
  ];

  @override
  void dispose() {
    // Clean up the ValueNotifiers
    selectedDate.dispose();
    selectedTimeSlot.dispose();
    selectedService.dispose();
    selectedDepartment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: CustomAppBar(
        title: 'Book Hospital Appointment',
        showBackButton: true,
        notificationCount: 3,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHospitalHeader(),
            _buildAppointmentForm(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.white,
      child: Row(
        children: [
          // Hospital image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.local_hospital, color: AppTheme.primaryBlue, size: 40),
          ),
          const SizedBox(width: 16),
          // Hospital details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.hospital['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.hospital['type'],
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      widget.hospital['rating'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.location_on, color: AppTheme.textSecondary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      widget.hospital['distance'],
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentForm(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      color: AppTheme.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Book Appointment',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),

          // Department selection
          const Text(
            'Select Department',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          const SizedBox(height: 12),

          ValueListenableBuilder<String?>(
            valueListenable: selectedDepartment,
            builder: (context, selectedDept, _) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: departments.map((department) {
                  final isSelected = department == selectedDept;
                  return GestureDetector(
                    onTap: () {
                      selectedDepartment.value = department;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryBlue : AppTheme.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryBlue : AppTheme.lightGrey,
                        ),
                      ),
                      child: Text(
                        department,
                        style: TextStyle(
                          color: isSelected ? AppTheme.white : AppTheme.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),

          // Service type selection
          const Text(
            'Select Service',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          const SizedBox(height: 12),

          ValueListenableBuilder<String?>(
            valueListenable: selectedService,
            builder: (context, selectedServiceType, _) {
              return Column(
                children: hospitalServices.map((service) {
                  final isSelected = service['type'] == selectedServiceType;
                  return GestureDetector(
                    onTap: () {
                      selectedService.value = service['type'];
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : AppTheme.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryBlue : AppTheme.lightGrey,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getServiceIcon(service['type']!),
                                color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                service['type']!,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            service['price']!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),

          // Date selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Date',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
              // Calendar button could be added here
            ],
          ),
          const SizedBox(height: 8),

          // Date chips
          ValueListenableBuilder<DateTime>(
            valueListenable: selectedDate,
            builder: (context, selectedDateValue, _) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(90, (index) {
                    final date = DateTime.now().add(Duration(days: index));
                    final isSelected = date.day == selectedDateValue.day && 
                                      date.month == selectedDateValue.month && 
                                      date.year == selectedDateValue.year;
                    return GestureDetector(
                      onTap: () {
                        selectedDate.value = date;
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: _buildDateChip(date: date, isSelected: isSelected),
                      ),
                    );
                  }),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Time selection
          const Text(
            'Select Time Slot',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          const SizedBox(height: 8),

          // Time slots
          ValueListenableBuilder<String?>(
            valueListenable: selectedTimeSlot,
            builder: (context, selectedTime, _) {
              final timeSlots = [
                '09:00 AM',
                '10:00 AM',
                '11:00 AM',
                '12:00 PM',
                '02:00 PM',
                '03:00 PM',
                '04:00 PM',
                '05:00 PM',
              ];
              final availableSlots = {
                '09:00 AM': true,
                '10:00 AM': true,
                '11:00 AM': false,
                '12:00 PM': true,
                '02:00 PM': true,
                '03:00 PM': true,
                '04:00 PM': false,
                '05:00 PM': true,
              };

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: timeSlots.map((time) {
                  final isAvailable = availableSlots[time] ?? false;
                  final isSelected = time == selectedTime;

                  return GestureDetector(
                    onTap: isAvailable
                        ? () {
                            selectedTimeSlot.value = time;
                          }
                        : null,
                    child: _buildTimeSlot(
                      time,
                      isAvailable: isAvailable,
                      isSelected: isSelected,
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),

          // Book button
          ValueListenableBuilder<String?>(
            valueListenable: selectedService,
            builder: (context, selectedServiceType, _) {
              return ValueListenableBuilder<String?>(
                valueListenable: selectedTimeSlot,
                builder: (context, selectedTime, _) {
                  return ValueListenableBuilder<String?>(
                    valueListenable: selectedDepartment,
                    builder: (context, selectedDept, _) {
                      final bool canBook =
                          selectedTime != null && 
                          selectedServiceType != null && 
                          selectedDept != null;

                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: canBook
                              ? () {
                                  // Book appointment logic
                                  final snackBar = SnackBar(
                                    content: Text(
                                      'Appointment booked at ${widget.hospital['name']} for ${selectedDate.value.day}/${selectedDate.value.month} at $selectedTime - $selectedServiceType in $selectedDept department',
                                      style: const TextStyle(
                                        color: AppTheme.white,
                                      ),
                                    ),
                                    backgroundColor: AppTheme.primaryGreen,
                                    duration: const Duration(seconds: 3),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  Navigator.pop(context); // Return to previous screen after booking
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor:
                                canBook ? AppTheme.primaryBlue : AppTheme.lightGrey,
                            disabledBackgroundColor: AppTheme.lightGrey,
                          ),
                          child: const Text(
                            'Confirm Appointment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper method to get icon for service type
  IconData _getServiceIcon(String type) {
    switch (type) {
      case 'General Consultation':
        return Icons.medical_services;
      case 'Emergency Services':
        return Icons.emergency;
      case 'Diagnostic Tests':
        return Icons.biotech;
      case 'Specialized Treatment':
        return Icons.healing;
      default:
        return Icons.local_hospital;
    }
  }

  Widget _buildDateChip({required DateTime date, required bool isSelected}) {
    final day = _getWeekday(date.weekday);
    final dateNum = date.day.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryBlue : AppTheme.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.lightGrey,
        ),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              color: isSelected ? AppTheme.white : AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateNum,
            style: TextStyle(
              color: isSelected ? AppTheme.white : AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(
    String time, {
    required bool isAvailable,
    bool isSelected = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryBlue
            : isAvailable
                ? AppTheme.white
                : AppTheme.lightGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? AppTheme.primaryBlue
              : isAvailable
                  ? AppTheme.lightGrey
                  : AppTheme.lightGrey.withOpacity(0.5),
        ),
      ),
      child: Text(
        time,
        style: TextStyle(
          color: isSelected
              ? AppTheme.white
              : isAvailable
                  ? AppTheme.textPrimary
                  : AppTheme.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }
}