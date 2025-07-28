import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidhya_front_end/models/service_models.dart';
import 'package:vaidhya_front_end/screens/doctors/doctor_service_form.dart';
import 'package:vaidhya_front_end/services/api_providers.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';

class DoctorServicesScreen extends ConsumerStatefulWidget {
  const DoctorServicesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DoctorServicesScreen> createState() =>
      _DoctorServicesScreenState();
}

class _DoctorServicesScreenState extends ConsumerState<DoctorServicesScreen> {
  // Service icon mapping
  final Map<String, IconData> _serviceIcons = {
    'Video Consultation': Icons.video_call,
    'In-person Consultation': Icons.person,
    'Follow-up Consultation': Icons.history,
    'Emergency Consultation': Icons.emergency,
    'Medical Services': Icons.medical_services,
    'Health Checkup': Icons.health_and_safety,
    'Home Visit': Icons.home,
    'Phone Consultation': Icons.phone,
  };

  // Service color mapping
  final Map<String, Color> _serviceColors = {
    'Video Consultation': AppTheme.primaryBlue,
    'In-person Consultation': AppTheme.primaryGreen,
    'Follow-up Consultation': Colors.orange,
    'Emergency Consultation': Colors.red,
    'Medical Services': Colors.purple,
    'Health Checkup': Colors.teal,
    'Home Visit': Colors.indigo,
    'Phone Consultation': Colors.amber,
  };

  @override
  Widget build(BuildContext context) {
    // Watch service overview and services data
    final serviceOverviewAsync = ref.watch(doctorServiceOverviewProvider);
    final servicesAsync = ref.watch(doctorServicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Services'),
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh data
          ref.refresh(doctorServiceOverviewProvider);
          ref.refresh(doctorServicesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service overview section
              serviceOverviewAsync.when(
                data: (overview) => _buildServiceStats(overview),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorWidget(error.toString()),
              ),
              const SizedBox(height: 24),

              // Services header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Services',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Refresh services list
                      ref.refresh(doctorServicesProvider);
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Services list
              servicesAsync.when(
                data:
                    (services) =>
                        services.isEmpty
                            ? _buildEmptyState()
                            : Column(
                              children:
                                  services
                                      .map(
                                        (service) => _buildServiceCard(service),
                                      )
                                      .toList(),
                            ),
                loading:
                    () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                error: (error, stack) => _buildErrorWidget(error.toString()),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToServiceForm(null),
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Build empty state widget when no services are available
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No services added yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first service by clicking the + button',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Build service statistics widget
  Widget _buildServiceStats(Map<String, dynamic> overview) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Total Services',
                overview['totalServices'].toString(),
              ),
              _buildStatItem('Active', overview['activeServices'].toString()),
              _buildStatItem(
                'Inactive',
                overview['inactiveServices'].toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build individual stat item
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }

  // Build service card widget
  Widget _buildServiceCard(Map<String, dynamic> serviceData) {
    // Convert API service data to UI model
    final service = DoctorService.fromJson(serviceData);

    // Assign icon and color based on serviceType or use defaults
    final icon = _serviceIcons[service.serviceType] ?? Icons.medical_services;
    final color = _serviceColors[service.serviceType] ?? AppTheme.primaryBlue;

    // Create a copy with UI properties
    final uiService = service.copyWithUI(icon: icon, color: color);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (uiService.color ?? AppTheme.primaryBlue).withOpacity(
                  0.1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                uiService.icon ?? Icons.medical_services,
                color: uiService.color ?? AppTheme.primaryBlue,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Service details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service name and active toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          uiService.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Switch(
                        value: uiService.isActive,
                        onChanged:
                            (value) =>
                                _updateServiceStatus(uiService.id, value),
                        activeColor: AppTheme.primaryBlue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Service description
                  Text(
                    uiService.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Price and duration
                  Row(
                    children: [
                      _buildServiceDetail(
                        Icons.currency_rupee,
                        '₹${uiService.price.toStringAsFixed(0)}',
                      ),
                      const SizedBox(width: 16),
                      _buildServiceDetail(
                        Icons.access_time,
                        '${uiService.durationMinutes} min',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _navigateToServiceForm(serviceData),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primaryBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Edit'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _viewServiceBookings(uiService.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Bookings'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Update service status
  Future<void> _updateServiceStatus(String serviceId, bool isActive) async {
    try {
      final result = await ref.read(
        updateServiceStatusProvider({
          'serviceId': serviceId,
          'isActive': isActive,
        }).future,
      );

      // Refresh the services list
      ref.refresh(doctorServicesProvider);
      ref.refresh(doctorServiceOverviewProvider);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Service status updated'),
            backgroundColor: AppTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating service status: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Navigate to service form
  Future<void> _navigateToServiceForm(Map<String, dynamic>? serviceData) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorServiceForm(service: serviceData),
      ),
    );

    if (result != null && mounted) {
      try {
        // If editing an existing service
        if (serviceData != null) {
          // When updating a service
          await ref.read(
            updateDoctorServiceProvider({
              'serviceId': serviceData['id'],
              'serviceData': {
                'serviceType': result['serviceType'],
                'price': result['price'],
                'isCommissionInclusive': result['isCommissionInclusive'],
                'currency': 'INR',
                'durationMinutes': result['durationMinutes'],  // Changed from result['duration'] to result['durationMinutes']
                'isActive': result['isActive'],
              },
            }).future,
          );

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service updated successfully'),
              backgroundColor: AppTheme.primaryGreen,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // If adding a new service
          await ref.read(
            addDoctorServiceProvider({
              'serviceType': result['serviceType'],
              'price': result['price'],
              'isCommissionInclusive': result['isCommissionInclusive'],
              'currency': 'INR',
              'durationMinutes': result['durationMinutes'], // Fixed: was result['duration']
              'isActive': result['isActive'],
            }).future,
          );

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service added successfully'),
              backgroundColor: AppTheme.primaryGreen,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Refresh the services list
        ref.refresh(doctorServicesProvider);
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // View service bookings
  Future<void> _viewServiceBookings(String serviceId) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading appointments...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Fetch appointments for this service
      final appointments = await ref.read(
        appointmentsByServiceProvider({
          'serviceId': serviceId,
          'status': null, // Get all appointments regardless of status
        }).future,
      );

      // TODO: Navigate to a dedicated bookings screen
      // For now, just show a snackbar with the count
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Found ${appointments.length} appointments for this service',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading appointments: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Helper to build service detail items (price, duration)
  Widget _buildServiceDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  // Error widget
  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Error loading data',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 8),
          Text(error),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              ref.refresh(doctorServicesProvider);
              ref.refresh(doctorServiceOverviewProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
