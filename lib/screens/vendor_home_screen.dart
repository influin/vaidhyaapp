import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/screens/vendors/vendor_profile_screen.dart'; // Add this import
import 'package:vaidhya_front_end/screens/vendors/vendor_services_screen.dart'; // Add this import
import 'package:vaidhya_front_end/screens/vendors/vendor_orders_screen.dart'; // Add this import
import 'package:vaidhya_front_end/screens/vendors/vendor_payments_screen.dart'; // Add this import

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({Key? key}) : super(key: key);

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const VendorDashboardTab(),
    const VendorServicesScreen(), // Replace placeholder with actual screen
    const VendorOrdersScreen(),   // Replace placeholder with actual screen
    const VendorPaymentsScreen(), // Replace placeholder with actual screen
    const VendorProfileScreen(),  // Replace placeholder with actual screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Vendor Dashboard'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: AppTheme.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Dashboard Tab
class VendorDashboardTab extends StatelessWidget {
  const VendorDashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    'V',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Welcome, MediSupply',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Your vendor dashboard is ready',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Stats Row
          Row(
            children: [
              _buildStatCard(
                'Active Orders',
                '12',
                Icons.shopping_cart,
                AppTheme.primaryGreen,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'Services Offered',
                '8',
                Icons.medical_services,
                AppTheme.primaryBlue,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                'Total Customers',
                '56',
                Icons.people,
                Colors.orange,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'Today\'s Revenue',
                '₹12,500',
                Icons.currency_rupee,
                Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Recent Orders
          const Text(
            'Recent Orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildOrderCard(
            'Order #1234',
            'Medical Supplies',
            '₹2,500',
            'Processing',
          ),
          _buildOrderCard(
            'Order #1235',
            'Lab Equipment',
            '₹5,000',
            'Shipped',
          ),
          _buildOrderCard(
            'Order #1236',
            'Pharmaceuticals',
            '₹3,200',
            'Delivered',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(String orderNumber, String items, String amount, String status) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'processing':
        statusColor = Colors.blue;
        break;
      case 'shipped':
        statusColor = Colors.orange;
        break;
      case 'delivered':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.inventory,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orderNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items,
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
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
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
}

// Remove these placeholder classes since we're using the actual screens
// class VendorServicesTab extends StatelessWidget { ... }
// class VendorOrdersTab extends StatelessWidget { ... }
// class VendorPaymentsTab extends StatelessWidget { ... }
// class VendorProfileTab extends StatelessWidget { ... }