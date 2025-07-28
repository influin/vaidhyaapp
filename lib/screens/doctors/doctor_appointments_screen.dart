import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidhya_front_end/models/appointment_models.dart';
import 'package:vaidhya_front_end/services/api_providers.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';

// Update the class to use ConsumerStatefulWidget
class DoctorAppointmentsScreen extends ConsumerStatefulWidget {
  const DoctorAppointmentsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState
    extends ConsumerState<DoctorAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Upcoming', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      // Force refresh when tab changes
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the status based on the current tab
    String? status;
    if (_tabController.index == 0) {
      status = 'upcoming';
    } else if (_tabController.index == 1) {
      status = 'completed';
    } else if (_tabController.index == 2) {
      status = 'cancelled';
    }

    // Watch the appointments provider
    final appointmentsAsync = ref.watch(doctorAppointmentsProvider(status));

    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: [
          // Upcoming appointments
          appointmentsAsync.when(
            data: (appointments) => _buildAppointmentList(appointments, true),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
          // Completed appointments
          appointmentsAsync.when(
            data: (appointments) => _buildAppointmentList(appointments, false),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
          // Cancelled appointments
          appointmentsAsync.when(
            data: (appointments) => _buildAppointmentList(appointments, false),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(List<dynamic> appointments, bool showActions) {
    if (appointments.isEmpty) {
      return const Center(child: Text('No appointments found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return _buildAppointmentCard(appointment, showActions);
      },
    );
  }

  Widget _buildAppointmentCard(
    Map<String, dynamic> appointment,
    bool showActions,
  ) {
    final DateTime dateTime = appointment['dateTime'];
    final String formattedDate =
        '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    final String formattedTime =
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    final String appointmentId = appointment['id'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.lightGrey,
                  backgroundImage:
                      appointment['patientImage'] != null
                          ? NetworkImage(appointment['patientImage'])
                          : null,
                  child:
                      appointment['patientImage'] == null
                          ? Text(
                            appointment['patientName'].substring(0, 1),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          )
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment['patientName'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment['symptoms'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          appointment['status'],
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(appointment['status']),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(appointment['status']),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoItem(Icons.calendar_today, formattedDate),
                const SizedBox(width: 16),
                _buildInfoItem(Icons.access_time, formattedTime),
                const SizedBox(width: 16),
                _buildInfoItem(Icons.medical_services, appointment['type']),
              ],
            ),
            if (appointment['status'] == AppointmentStatus.cancelled &&
                appointment['cancellationReason'] != null) ...[
              const SizedBox(height: 12),
              Text(
                'Reason: ${appointment['cancellationReason']}',
                style: const TextStyle(fontSize: 14, color: Colors.red),
              ),
            ],
            if (showActions && appointmentId.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    'Start',
                    Icons.video_call,
                    AppTheme.primaryGreen,
                    appointmentId,
                  ),
                  _buildActionButton(
                    'Reschedule',
                    Icons.schedule,
                    AppTheme.primaryBlue,
                    appointmentId,
                  ),
                  _buildActionButton(
                    'Cancel',
                    Icons.cancel,
                    Colors.red,
                    appointmentId,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    String appointmentId,
  ) {
    return Expanded(
      child: TextButton.icon(
        onPressed: () {
          if (label == 'Start') {
            // Start consultation logic
            _startConsultation(appointmentId);
          } else if (label == 'Reschedule') {
            // Reschedule logic
            _showRescheduleDialog(appointmentId);
          } else if (label == 'Cancel') {
            _showCancellationDialog(appointmentId);
          }
        },
        icon: Icon(icon, color: color, size: 16),
        label: Text(label, style: TextStyle(color: color)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  void _startConsultation(String appointmentId) {
    // Implementation for starting a consultation
    // This could navigate to a video call screen or chat interface
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Starting consultation...')));

    // Here you would typically navigate to the consultation screen
    // Navigator.push(context, MaterialPageRoute(builder: (context) => ConsultationScreen(appointmentId: appointmentId)));
  }

  void _showRescheduleDialog(String appointmentId) {
    // Implementation for rescheduling an appointment
    // This would typically show a date/time picker
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reschedule Appointment'),
            content: const Text(
              'Rescheduling functionality will be implemented here.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Here you would call the API to reschedule
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rescheduling appointment...'),
                    ),
                  );
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
  }

  void _showCancellationDialog(String appointmentId) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Appointment'),
            content: TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason for cancellation',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
              TextButton(
                onPressed: () {
                  if (reasonController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please provide a reason for cancellation',
                        ),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context);

                  // Call the provider to cancel the appointment
                  ref
                      .read(
                        respondToAppointmentProvider({
                          'appointmentId': appointmentId,
                          'action': 'reject',
                          'reason': reasonController.text.trim(),
                        }).future,
                      )
                      .then((_) {
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Appointment cancelled successfully'),
                          ),
                        );
                        // Refresh the appointments list
                        ref.refresh(doctorAppointmentsProvider('upcoming'));
                      })
                      .catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $error')),
                        );
                      });
                },
                child: const Text(
                  'Confirm',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}

Color _getStatusColor(AppointmentStatus status) {
  switch (status) {
    case AppointmentStatus.upcoming:
      return AppTheme.primaryBlue;
    case AppointmentStatus.completed:
      return AppTheme.primaryGreen;
    case AppointmentStatus.cancelled:
      return Colors.red;
    case AppointmentStatus.rescheduled:
      return Colors.orange;
    case AppointmentStatus.noShow:
      return Colors.grey;
    default:
      return AppTheme.textSecondary;
  }
}

String _getStatusText(AppointmentStatus status) {
  switch (status) {
    case AppointmentStatus.upcoming:
      return 'Upcoming';
    case AppointmentStatus.completed:
      return 'Completed';
    case AppointmentStatus.cancelled:
      return 'Cancelled';
    case AppointmentStatus.rescheduled:
      return 'Rescheduled';
    case AppointmentStatus.noShow:
      return 'No Show';
    default:
      return 'Unknown';
  }
}
