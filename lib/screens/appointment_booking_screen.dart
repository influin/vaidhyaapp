import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vaidhya_front_end/models/appointment_models.dart';
import 'package:vaidhya_front_end/models/doctor_models.dart';
import 'package:vaidhya_front_end/services/api_providers.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/widgets/custom_app_bar.dart';
import 'package:vaidhya_front_end/screens/patient_details_screen.dart';

class AppointmentBookingScreen extends ConsumerStatefulWidget {
  final String doctorId;
  final String doctorName;

  const AppointmentBookingScreen({
    Key? key,
    required this.doctorId,
    required this.doctorName,
  }) : super(key: key);

  @override
  ConsumerState<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState
    extends ConsumerState<AppointmentBookingScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String? _selectedTimeSlot;
  String _selectedConsultationType = 'video';
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final doctorAvailabilityAsync = ref.watch(
      doctorAvailabilityProvider(widget.doctorId),
    );

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: CustomAppBar(title: 'Book Appointment', showBackButton: true),
      body: doctorAvailabilityAsync.when(
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
                    'Failed to load availability',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
        data:
            (doctorAvailability) =>
                doctorAvailability != null
                    ? _buildBookingForm(context, doctorAvailability)
                    : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 64,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No availability data found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
      ),
    );
  }

  Widget _buildBookingForm(
    BuildContext context,
    DoctorAvailability doctorAvailability,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDoctorInfo(),
          const SizedBox(height: 24),
          _buildConsultationTypeSelector(),
          const SizedBox(height: 24),
          _buildCalendar(),
          const SizedBox(height: 24),
          _buildTimeSlots(doctorAvailability),
          const SizedBox(height: 24),
          _buildNotesSection(),
          const SizedBox(height: 32),
          _buildContinueButton(context),
        ],
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Container(
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryBlue,
            child: Text(
              widget.doctorName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. ${widget.doctorName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Book your appointment',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationTypeSelector() {
    return Container(
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
            'Consultation Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildConsultationOption(
                      'video',
                      'Video Call',
                      Icons.videocam,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildConsultationOption(
                      'audio',
                      'Audio Call',
                      Icons.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildConsultationOption(
                      'in-person',
                      'In-Person',
                      Icons.person,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildConsultationOption(
                      'homeVisit',
                      'Home Visit',
                      Icons.home,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationOption(String type, String label, IconData icon) {
    final isSelected = _selectedConsultationType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedConsultationType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppTheme.primaryBlue.withOpacity(0.1)
                  : AppTheme.lightGrey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color:
                    isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
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
            'Select Date',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TableCalendar<Event>(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 90)),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              print('=== DATE SELECTED DEBUG ===');
              print('Selected Day: $selectedDay');
              print('Formatted Date: ${selectedDay.year.toString().padLeft(4, '0')}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}');
              print('Day Name: ${_getDayName(selectedDay.weekday)}');
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedTimeSlot = null; // Reset time slot when date changes
              });
            },
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              selectedDecoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlots(DoctorAvailability doctorAvailability) {
    final dayName = _getDayName(_selectedDay.weekday);
    final selectedDateString = '${_selectedDay.year.toString().padLeft(4, '0')}-${_selectedDay.month.toString().padLeft(2, '0')}-${_selectedDay.day.toString().padLeft(2, '0')}';
    
    print('=== BUILDING TIME SLOTS DEBUG ===');
    print('Selected Date String: $selectedDateString');
    print('Day Name: $dayName');
    print('Doctor Availability: ${doctorAvailability.toJson()}');
    print('Working Days Count: ${doctorAvailability.workingDays.length}');
    
    // Print all working days for debugging
    for (int i = 0; i < doctorAvailability.workingDays.length; i++) {
      final workingDay = doctorAvailability.workingDays[i];
      print('Working Day $i: ${workingDay.day}, Available: ${workingDay.isAvailable}, Slots: ${workingDay.slots.length}');
    }
    
    final availableSlots = _getAvailableSlotsForDay(
      doctorAvailability,
      dayName,
    );
    
    print('Available Slots Found: ${availableSlots.length}');
    print('Available Slots: $availableSlots');
    print('=== END DEBUG ===');

    return Container(
      width: double.infinity, // Make container full width
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
            'Available Time Slots',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (availableSlots.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Text(
                'No available slots for this date',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            )
          else
            Column(
              children:
                  availableSlots
                      .map((slot) => _buildTimeSlotChip(slot))
                      .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotChip(String slot) {
    final isSelected = _selectedTimeSlot == slot;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTimeSlot = slot;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
            ),
          ),
          child: Text(
            slot,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
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
            'Additional Notes (Optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Describe your symptoms or reason for consultation...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.lightGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.primaryBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    final isEnabled = _selectedTimeSlot != null;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? () => _proceedToPatientDetails(context) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: AppTheme.textSecondary.withOpacity(0.3),
        ),
        child: Text(
          'Continue to Patient Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isEnabled ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  List<String> _getAvailableSlotsForDay(
    DoctorAvailability doctorAvailability,
    String dayName,
  ) {
    print('=== GET AVAILABLE SLOTS DEBUG ===');
    print('Looking for day: $dayName');
    print('Selected date: ${_selectedDay.year.toString().padLeft(4, '0')}-${_selectedDay.month.toString().padLeft(2, '0')}-${_selectedDay.day.toString().padLeft(2, '0')}');
    
    // Try both day name and date matching
    final selectedDateString = '${_selectedDay.year.toString().padLeft(4, '0')}-${_selectedDay.month.toString().padLeft(2, '0')}-${_selectedDay.day.toString().padLeft(2, '0')}';
    
    // First try to find by date
    var workingDay = doctorAvailability.workingDays.firstWhere(
      (day) => day.day == selectedDateString,
      orElse: () => WorkingDay(day: '', isAvailable: false, slots: [], id: ''),
    );
    
    print('Found by date: ${workingDay.day}, Available: ${workingDay.isAvailable}');
    
    // If not found by date, try by day name
    if (workingDay.day.isEmpty) {
      workingDay = doctorAvailability.workingDays.firstWhere(
        (day) => day.day.toLowerCase() == dayName.toLowerCase(),
        orElse: () => WorkingDay(day: '', isAvailable: false, slots: [], id: ''),
      );
      print('Found by day name: ${workingDay.day}, Available: ${workingDay.isAvailable}');
    }

    if (!workingDay.isAvailable) {
      print('Working day not available');
      return [];
    }

    final availableSlots = workingDay.slots
        .where((slot) => !slot.isBooked) // Only show available slots
        .map((slot) => '${slot.startTime} - ${slot.endTime}')
        .toList();
        
    print('Final available slots: $availableSlots');
    print('=== END GET AVAILABLE SLOTS DEBUG ===');
    
    return availableSlots;
  }

  void _proceedToPatientDetails(BuildContext context) {
    final selectedDateTime = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      int.parse(_selectedTimeSlot!.split(' - ')[0].split(':')[0]),
      int.parse(_selectedTimeSlot!.split(' - ')[0].split(':')[1]),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PatientDetailsScreen(
              doctorId: widget.doctorId,
              doctorName: widget.doctorName,
              selectedDateTime: selectedDateTime,
              consultationType: _selectedConsultationType,
              notes: _notesController.text,
            ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}

class Event {
  final String title;
  Event(this.title);
}
