import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';

class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({Key? key}) : super(key: key);

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock data for demonstration
  final Map<String, dynamic> _vendorData = {
    'name': 'MediSupply Services',
    'type': 'Medical Equipment Supplier',
    'rating': 4.8,
    'reviewCount': 124,
    'address': '123 Healthcare Avenue, Medical District',
    'city': 'Mumbai',
    'state': 'Maharashtra',
    'postalCode': '400001',
    'phone': '+91 9876543210',
    'email': 'contact@medisupply.com',
    'website': 'www.medisupply.com',
    'about': 'MediSupply is a leading provider of medical equipment and supplies with over 10 years of experience serving hospitals, clinics, and healthcare professionals across India. We specialize in high-quality diagnostic equipment, surgical supplies, and patient care products.',
    'businessHours': [
      {'day': 'Monday - Friday', 'hours': '9:00 AM - 6:00 PM'},
      {'day': 'Saturday', 'hours': '10:00 AM - 4:00 PM'},
      {'day': 'Sunday', 'hours': 'Closed'}
    ],
    'services': [
      {'name': 'Medical Equipment Supply', 'price': '₹Varies'},
      {'name': 'Equipment Maintenance', 'price': '₹2,000/visit'},
      {'name': 'Emergency Delivery', 'price': '₹500'},
      {'name': 'Equipment Training', 'price': '₹1,500/session'},
    ],
  };

  // Settings list
  final List<Map<String, dynamic>> _settings = [
    {
      'category': 'Account',
      'items': [
        {'title': 'Edit Profile', 'icon': Icons.edit, 'action': 'edit_profile'},
        {'title': 'Business Information', 'icon': Icons.business, 'action': 'business_info'},
        {'title': 'Change Password', 'icon': Icons.lock, 'action': 'change_password'},
      ],
    },
    {
      'category': 'Business',
      'items': [
        {'title': 'Service Management', 'icon': Icons.medical_services, 'action': 'manage_services'},
        {'title': 'Inventory', 'icon': Icons.inventory, 'action': 'inventory'},
        {'title': 'Business Hours', 'icon': Icons.access_time, 'action': 'business_hours'},
      ],
    },
    {
      'category': 'Payments',
      'items': [
        {'title': 'Bank Account', 'icon': Icons.account_balance, 'action': 'bank_account'},
        {'title': 'Payment Methods', 'icon': Icons.payment, 'action': 'payment_methods'},
        {'title': 'Tax Information', 'icon': Icons.receipt, 'action': 'tax_info'},
      ],
    },
    {
      'category': 'System',
      'items': [
        {'title': 'Notifications', 'icon': Icons.notifications, 'action': 'notifications'},
        {'title': 'Privacy & Security', 'icon': Icons.security, 'action': 'privacy'},
        {'title': 'Help & Support', 'icon': Icons.help, 'action': 'support'},
        {'title': 'Logout', 'icon': Icons.logout, 'action': 'logout', 'color': Colors.red},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Vendor Profile'),
        backgroundColor: AppTheme.primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutConfirmation(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            _buildInfoSection(),
            _buildTabSection(),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Perform logout
              Navigator.pop(context);
              // Navigate to login screen
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppTheme.primaryBlue,
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              _vendorData['name'].substring(0, 1),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _vendorData['name'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _vendorData['type'],
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                '${_vendorData['rating']} (${_vendorData['reviewCount']} reviews)',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.phone,
                  'Phone',
                  _vendorData['phone'],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildInfoItem(
                  Icons.email,
                  'Email',
                  _vendorData['email'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.location_on,
                  'Address',
                  '${_vendorData['address']}, ${_vendorData['city']}',
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildInfoItem(
                  Icons.language,
                  'Website',
                  _vendorData['website'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('About'),
          const SizedBox(height: 8),
          Text(
            _vendorData['about'],
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.lightGrey)),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryBlue,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primaryBlue,
            tabs: const [
              Tab(text: 'Business Hours'),
              Tab(text: 'Services'),
              Tab(text: 'Reviews'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        SizedBox(
          height: 500, // Fixed height for tab content
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBusinessHoursTab(),
              _buildServicesTab(),
              _buildReviewsTab(),
              _buildSettingsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessHoursTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Business Hours'),
          const SizedBox(height: 16),
          ..._vendorData['businessHours'].map<Widget>((hours) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      hours['day'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(hours['hours']),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Edit business hours
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Hours'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('Services Offered'),
              ElevatedButton.icon(
                onPressed: () {
                  _addNewService(context);
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Service'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _vendorData['services'].length,
            itemBuilder: (context, index) {
              final service = _vendorData['services'][index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: AppTheme.lightGrey),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              service['price'],
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppTheme.primaryBlue),
                        onPressed: () {
                          _editService(context, service, index);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Delete service
                          _deleteService(context, index);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _addNewService(BuildContext context) {
    _buildServiceDialog(context, null, null);
  }

  void _editService(BuildContext context, Map<String, dynamic> service, int index) {
    _buildServiceDialog(context, service, index);
  }

  void _deleteService(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: const Text('Are you sure you want to delete this service?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _vendorData['services'].removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Service deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _buildServiceDialog(BuildContext context, Map<String, dynamic>? service, int? index) {
    final nameController = TextEditingController(text: service?['name'] ?? '');
    final priceController = TextEditingController(text: service?['price']?.replaceAll('₹', '') ?? '');
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service == null ? 'Add New Service' : 'Edit Service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Service Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  prefixText: '₹',
                ),
                keyboardType: TextInputType.text,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Validate inputs
              if (nameController.text.isEmpty || priceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }
              
              final newService = {
                'name': nameController.text,
                'price': '₹${priceController.text}',
              };
              
              setState(() {
                if (index != null) {
                  // Update existing service
                  _vendorData['services'][index] = newService;
                } else {
                  // Add new service
                  _vendorData['services'].add(newService);
                }
              });
              
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    service == null ? 'Service added successfully' : 'Service updated successfully',
                  ),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: Text(service == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    // Placeholder for reviews tab
    return const Center(
      child: Text('No reviews yet'),
    );
  }

  Widget _buildSettingsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _settings.length,
      itemBuilder: (context, categoryIndex) {
        final category = _settings[categoryIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                category['category'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            ...List.generate(
              category['items'].length,
              (itemIndex) {
                final item = category['items'][itemIndex];
                return ListTile(
                  leading: Icon(
                    item['icon'],
                    color: item['color'] ?? AppTheme.primaryBlue,
                  ),
                  title: Text(
                    item['title'],
                    style: TextStyle(
                      color: item['color'] ?? AppTheme.textPrimary,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    if (item['action'] == 'logout') {
                      _showLogoutConfirmation(context);
                    } else {
                      // Handle other settings actions
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${item['title']} tapped')),
                      );
                    }
                  },
                );
              },
            ),
            if (categoryIndex < _settings.length - 1)
              const Divider(height: 32),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}