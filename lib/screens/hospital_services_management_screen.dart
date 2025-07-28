import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidhya_front_end/services/api_service.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/models/hospital_models.dart';
import 'package:vaidhya_front_end/widgets/custom_app_bar.dart';

class HospitalServicesManagementScreen extends ConsumerStatefulWidget {
  const HospitalServicesManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HospitalServicesManagementScreen> createState() =>
      _HospitalServicesManagementScreenState();
}

class _HospitalServicesManagementScreenState
    extends ConsumerState<HospitalServicesManagementScreen> {
  final ApiService _apiService = ApiService();

  List<HospitalService> _services = [];
  bool _isLoading = true;
  String? _error;

  // Service icon mapping
  final Map<String, IconData> _serviceIcons = {
    'Emergency': Icons.emergency,
    'Surgery': Icons.medical_services,
    'Consultation': Icons.person,
    'Diagnostic': Icons.biotech,
    'Pharmacy': Icons.local_pharmacy,
    'Laboratory': Icons.science,
    'Radiology': Icons.camera_alt,
    'Cardiology': Icons.favorite,
    'Neurology': Icons.psychology,
    'Orthopedics': Icons.accessibility,
  };

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  // Load hospital services
  Future<void> _loadServices() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _apiService.get('/hospitals/profile');

      // Better null handling for services data
      final servicesData = response['services'];
      if (servicesData != null && servicesData is List) {
        setState(() {
          _services =
              servicesData
                  .where(
                    (serviceData) => serviceData != null,
                  ) // Filter out null items
                  .map((serviceData) {
                    try {
                      return HospitalService.fromJson(
                        serviceData as Map<String, dynamic>,
                      );
                    } catch (e) {
                      print('Error parsing service: $e');
                      return null;
                    }
                  })
                  .where(
                    (service) => service != null,
                  ) // Filter out failed parsing
                  .cast<HospitalService>()
                  .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _services = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load services: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Hospital Services'),
      body: RefreshIndicator(
        onRefresh: _loadServices,
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _buildErrorWidget()
                : _services.isEmpty
                ? _buildEmptyState()
                : _buildServicesList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddServiceDialog(),
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadServices, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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

  Widget _buildServicesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        return _buildServiceCard(_services[index]);
      },
    );
  }

  Widget _buildServiceCard(HospitalService service) {
    // Ensure service name is not null or empty
    final serviceName =
        service.name.isNotEmpty ? service.name : 'Unnamed Service';
    final icon = _serviceIcons[serviceName] ?? Icons.medical_services;

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
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                service.icon ?? icon,
                color: AppTheme.primaryBlue,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Service details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service name
                  Text(
                    serviceName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Service description (with null safety)
                  if (service.description != null &&
                      service.description!.isNotEmpty) ...[
                    Text(
                      service.description!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Price range
                  if (service.minPrice != null || service.maxPrice != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.currency_rupee,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _buildPriceText(service),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showEditServiceDialog(service),
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
                          onPressed: () => _deleteService(service),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Delete'),
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

  String _buildPriceText(HospitalService service) {
    if (service.minPrice != null && service.maxPrice != null) {
      if (service.minPrice == service.maxPrice) {
        return '${service.minPrice!.toStringAsFixed(0)}';
      } else {
        return '${service.minPrice!.toStringAsFixed(0)} - ${service.maxPrice!.toStringAsFixed(0)}';
      }
    } else if (service.minPrice != null) {
      return 'From ${service.minPrice!.toStringAsFixed(0)}';
    } else if (service.maxPrice != null) {
      return 'Up to ${service.maxPrice!.toStringAsFixed(0)}';
    }
    return 'Price not set';
  }

  void _showAddServiceDialog() {
    // Simple dialog for adding service
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Service'),
            content: const Text(
              'Service management functionality will be implemented here.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showEditServiceDialog(HospitalService service) {
    // Simple dialog for editing service
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Service'),
            content: Text(
              'Edit ${service.name} functionality will be implemented here.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _deleteService(HospitalService service) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Service'),
            content: Text('Are you sure you want to delete ${service.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _services.remove(service);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${service.name} deleted'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
