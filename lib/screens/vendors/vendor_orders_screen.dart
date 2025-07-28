import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/models/appointment_models.dart';

class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({Key? key}) : super(key: key);

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['New', 'Ongoing', 'Completed', 'Cancelled'];
  
  // Mock data for demonstration
  final List<Map<String, dynamic>> _newOrders = [
    {
      'id': 'ORD1001',
      'customerName': 'Rahul Sharma',
      'serviceName': 'Home Nursing Care',
      'dateTime': DateTime.now().add(const Duration(hours: 2)),
      'amount': 500.0,
      'status': 'New',
      'address': '123 Main St, Bangalore',
      'phoneNumber': '+91 9876543210',
    },
    {
      'id': 'ORD1002',
      'customerName': 'Priya Patel',
      'serviceName': 'Physiotherapy Session',
      'dateTime': DateTime.now().add(const Duration(hours: 5)),
      'amount': 800.0,
      'status': 'New',
      'address': '456 Park Ave, Mumbai',
      'phoneNumber': '+91 9876543211',
    },
  ];
  
  final List<Map<String, dynamic>> _ongoingOrders = [
    {
      'id': 'ORD1000',
      'customerName': 'Amit Kumar',
      'serviceName': 'Medical Equipment Rental',
      'dateTime': DateTime.now().subtract(const Duration(days: 1)),
      'amount': 1200.0,
      'status': 'Ongoing',
      'address': '789 Lake View, Delhi',
      'phoneNumber': '+91 9876543212',
    },
  ];
  
  final List<Map<String, dynamic>> _completedOrders = [
    {
      'id': 'ORD999',
      'customerName': 'Neha Singh',
      'serviceName': 'Lab Sample Collection',
      'dateTime': DateTime.now().subtract(const Duration(days: 2)),
      'amount': 300.0,
      'status': 'Completed',
      'address': '321 Hill Road, Chennai',
      'phoneNumber': '+91 9876543213',
    },
    {
      'id': 'ORD998',
      'customerName': 'Vikram Malhotra',
      'serviceName': 'Home Nursing Care',
      'dateTime': DateTime.now().subtract(const Duration(days: 3)),
      'amount': 500.0,
      'status': 'Completed',
      'address': '654 River View, Hyderabad',
      'phoneNumber': '+91 9876543214',
    },
  ];
  
  final List<Map<String, dynamic>> _cancelledOrders = [
    {
      'id': 'ORD997',
      'customerName': 'Sanjay Gupta',
      'serviceName': 'Physiotherapy Session',
      'dateTime': DateTime.now().subtract(const Duration(days: 1)),
      'amount': 800.0,
      'status': 'Cancelled',
      'address': '987 Mountain View, Pune',
      'phoneNumber': '+91 9876543215',
      'cancellationReason': 'Customer requested cancellation',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: AppTheme.primaryBlue,
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(_newOrders),
          _buildOrderList(_ongoingOrders),
          _buildOrderList(_completedOrders),
          _buildOrderList(_cancelledOrders),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      return const Center(child: Text('No orders found'));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final DateTime dateTime = order['dateTime'];
    final String formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    final String formattedTime = '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    final String status = order['status'];
    
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['id'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order['serviceName'],
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  order['customerName'],
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 16),
                Icon(Icons.phone, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  order['phoneNumber'],
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order['address'],
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoItem(Icons.calendar_today, formattedDate),
                const SizedBox(width: 16),
                _buildInfoItem(Icons.access_time, formattedTime),
                const SizedBox(width: 16),
                _buildInfoItem(Icons.payments, '₹${order['amount']}'),
              ],
            ),
            if (order['cancellationReason'] != null) ...[  
              const SizedBox(height: 12),
              Text(
                'Reason: ${order['cancellationReason']}',
                style: const TextStyle(fontSize: 14, color: Colors.red),
              ),
            ],
            if (status == 'New') ...[  
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    'Accept', 
                    Icons.check_circle, 
                    AppTheme.primaryGreen,
                    () {
                      // Accept order logic
                    },
                  ),
                  _buildActionButton(
                    'Reject', 
                    Icons.cancel, 
                    Colors.red,
                    () {
                      // Reject order logic
                    },
                  ),
                ],
              ),
            ],
            if (status == 'Ongoing') ...[  
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    'Complete', 
                    Icons.task_alt, 
                    AppTheme.primaryGreen,
                    () {
                      // Complete order logic
                    },
                  ),
                  _buildActionButton(
                    'Contact', 
                    Icons.phone, 
                    AppTheme.primaryBlue,
                    () {
                      // Contact customer logic
                    },
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

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Expanded(
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 16),
        label: Text(
          label,
          style: TextStyle(color: color),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'New':
        return Colors.blue;
      case 'Ongoing':
        return Colors.orange;
      case 'Completed':
        return AppTheme.primaryGreen;
      case 'Cancelled':
        return Colors.red;
      default:
        return AppTheme.textSecondary;
    }
  }
}