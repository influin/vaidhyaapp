import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/widgets/call_action_buttons.dart';
import 'package:vaidhya_front_end/widgets/custom_app_bar.dart';
import 'package:vaidhya_front_end/services/api_providers.dart';
import 'package:vaidhya_front_end/models/appointment_models.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey.withOpacity(0.05),
      appBar: CustomAppBar(
        title: 'My Appointments',
        showBackButton: false,
        notificationCount: 3,
      ),
      body: _buildDoctorAppointmentsList(),
    );
  }

  Widget _buildDoctorAppointmentsList() {
    final appointmentsAsync = ref.watch(customerAppointmentsProvider);

    return appointmentsAsync.when(
      data: (appointments) {
        final doctorAppointments =
            appointments
                .where(
                  (appointment) => appointment.type == AppointmentType.doctor,
                )
                .toList();

        if (doctorAppointments.isEmpty) {
          return _buildEmptyState('No doctor appointments found');
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(customerAppointmentsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctorAppointments.length,
            itemBuilder: (context, index) {
              final appointment = doctorAppointments[index];
              return _buildDoctorAppointmentCard(appointment);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: AppTheme.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load appointments',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(customerAppointmentsProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/main', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Book an Appointment'),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorAppointmentCard(Appointment appointment) {
    final bool isUpcoming = appointment.status == AppointmentStatus.upcoming;
    final Color statusColor =
        isUpcoming ? AppTheme.primaryBlue : AppTheme.textSecondary;
    final bool isVideoConsultation =
        appointment.consultationType?.toLowerCase() == 'video';

    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final formattedDate = dateFormat.format(appointment.dateTime);
    final formattedTime = timeFormat.format(appointment.dateTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    appointment.doctorName ?? 'Doctor',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment.status.name.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (appointment.specialty != null)
              Text(
                appointment.specialty!,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildInfoItem(Icons.calendar_today, formattedDate),
                _buildInfoItem(Icons.access_time, formattedTime),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoItem(
              isVideoConsultation ? Icons.videocam : Icons.local_hospital,
              appointment.consultationType ?? 'Consultation',
            ),
            if (!isVideoConsultation && appointment.clinicAddress != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Clinic Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  if (appointment.clinicName != null &&
                      appointment.clinicName!.isNotEmpty)
                    _buildInfoItem(Icons.business, appointment.clinicName!),
                  const SizedBox(height: 4),
                  _buildInfoItem(Icons.location_on, appointment.clinicAddress!),
                ],
              ),
            const SizedBox(height: 16),
            if (isUpcoming && _hasSpecificDateTime(appointment))
              _buildActionButton(appointment),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  bool _hasSpecificDateTime(Appointment appointment) {
    return appointment.dateTime.isAfter(DateTime.now());
  }

  Widget _buildActionButton(Appointment appointment) {
    final consultationType = appointment.consultationType?.toLowerCase() ?? '';

    switch (consultationType) {
      case 'video':
        return ElevatedButton(
          onPressed: () {
            final channelName = 'appointment_${appointment.id}';
            Navigator.pushNamed(
              context,
              '/video_call',
              arguments: {
                'channelName': channelName,
                'doctorName': appointment.doctorName ?? 'Doctor',
                'isVideoCall': true,
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Join Video Call'),
        );

      case 'audio':
        return ElevatedButton(
          onPressed: () {
            final channelName = 'appointment_${appointment.id}';
            Navigator.pushNamed(
              context,
              '/video_call',
              arguments: {
                'channelName': channelName,
                'doctorName': appointment.doctorName ?? 'Doctor',
                'isVideoCall': false,
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Join Audio Call'),
        );

      case 'in-person':
        return ElevatedButton(
          onPressed: () {
            _openDirections(appointment);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Get Directions'),
        );

      case 'home visit':
      case 'homevisit':
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home, color: AppTheme.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Doctor will be arriving soon',
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );

      default:
        return ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Appointment details')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('View Details'),
        );
    }
  }

  void _openDirections(Appointment appointment) async {
    if (appointment.clinicAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clinic address not available')),
      );
      return;
    }

    try {
      final address = Uri.encodeComponent(appointment.clinicAddress!);
      final googleMapsUrl =
          'https://www.google.com/maps/search/?api=1&query=$address';
      final appleMapsUrl = 'http://maps.apple.com/?q=$address';

      if (await canLaunchUrl(Uri.parse('comgooglemaps://'))) {
        await launchUrl(Uri.parse('comgooglemaps://?q=$address'));
      } else if (await canLaunchUrl(Uri.parse('maps://'))) {
        await launchUrl(Uri.parse(appleMapsUrl));
      } else if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl));
      } else {
        _showManualNavigationDialog(appointment.clinicAddress!);
      }
    } catch (e) {
      _showManualNavigationDialog(appointment.clinicAddress!);
    }
  }

  void _showManualNavigationDialog(String address) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Navigation'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Unable to open maps app. Here\'s the address:'),
                const SizedBox(height: 8),
                Text(
                  address,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
