import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/screens/vendors/vendor_service_form.dart';
import 'package:vaidhya_front_end/models/service_models.dart';

class VendorServicesScreen extends StatefulWidget {
  const VendorServicesScreen({Key? key}) : super(key: key);

  @override
  State<VendorServicesScreen> createState() => _VendorServicesScreenState();
}

class _VendorServicesScreenState extends State<VendorServicesScreen> {
  // Mock data for demonstration
  final List<VendorService> _services = [
    VendorService(
      id: '1',
      name: 'Home Nursing Care',
      description: 'Professional nursing care at your home',
      price: 500.0,
      currency: '₹',
      durationMinutes: 60,
      icon: Icons.medical_services,
    ),
    VendorService(
      id: '2',
      name: 'Physiotherapy Session',
      description: 'Rehabilitation therapy for physical injuries',
      price: 800.0,
      currency: '₹',
      durationMinutes: 45,
      icon: Icons.fitness_center,
    ),
    VendorService(
      id: '3',
      name: 'Medical Equipment Rental',
      description: 'Rent medical equipment for home use',
      price: 1200.0,
      currency: '₹',
      durationMinutes: 0, // Not time-based
      icon: Icons.wheelchair_pickup,
    ),
    VendorService(
      id: '4',
      name: 'Lab Sample Collection',
      description: 'Home collection of samples for lab tests',
      price: 300.0,
      currency: '₹',
      durationMinutes: 15,
      icon: Icons.science,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Services'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: Column(
        children: [
          _buildServiceStats(),
          Expanded(
            child: _services.isEmpty
                ? const Center(child: Text('No services added yet'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _services.length,
                    itemBuilder: (context, index) {
                      return _buildServiceCard(_services[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToServiceForm(context),
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildServiceStats() {
    final activeServices = _services.length;
    final totalBookings = 45; // Mock data
    final totalRevenue = 25000.0; // Mock data

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                'Active Services',
                activeServices.toString(),
                Icons.medical_services,
                AppTheme.primaryBlue,
              ),
              _buildStatItem(
                'Total Bookings',
                totalBookings.toString(),
                Icons.calendar_today,
                AppTheme.primaryGreen,
              ),
              _buildStatItem(
                'Total Revenue',
                '₹$totalRevenue',
                Icons.payments,
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(VendorService service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    service.icon ?? Icons.medical_services,
                    color: AppTheme.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (service.description != null) ...[  
                        const SizedBox(height: 4),
                        Text(
                          service.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Switch(
                  value: true, // Mock active status
                  onChanged: (value) {
                    // Toggle service active status
                    setState(() {
                      // Update service active status
                    });
                  },
                  activeColor: AppTheme.primaryGreen,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${service.currency ?? '₹'}${service.price}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      if (service.durationMinutes != null && service.durationMinutes! > 0) ...[  
                        const SizedBox(height: 4),
                        Text(
                          '${service.durationMinutes} min',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _navigateToServiceForm(context, service),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to bookings for this service
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Bookings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToServiceForm(BuildContext context, [VendorService? service]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VendorServiceForm(
          service: service,
        ),
      ),
    );

    if (result != null && result is VendorService) {
      setState(() {
        if (service != null) {
          // Edit existing service
          final index = _services.indexWhere((s) => s.id == result.id);
          if (index != -1) {
            _services[index] = result;
          }
        } else {
          // Add new service
          _services.add(result);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            service == null ? 'Service added successfully' : 'Service updated successfully',
          ),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }
}