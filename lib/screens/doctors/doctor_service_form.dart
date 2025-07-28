import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/models/service_models.dart';

class DoctorServiceForm extends StatefulWidget {
  final Map<String, dynamic>?
  service; // Pass existing service for editing, null for new service

  const DoctorServiceForm({Key? key, this.service}) : super(key: key);

  @override
  State<DoctorServiceForm> createState() => _DoctorServiceFormState();
}

class _DoctorServiceFormState extends State<DoctorServiceForm> {
  final _formKey = GlobalKey<FormState>();

  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  bool _isActive = true;
  String _selectedServiceType = 'Clinical Visit'; // Default service type
  bool _isCommissionInclusive = true; // Default to inclusive commission

  // Commission percentage
  final double _commissionPercentage = 10.0; // 10% commission

  // Calculated values
  double _doctorReceives = 0.0;
  double _platformReceives = 0.0;
  double _customerPays = 0.0;

  // List of available service types
  final List<String> _serviceTypes = [
    'Clinical Visit',
    'Home Visit',
    'Video Consultation',
    'Voice Consultation',
  ];

  // Map service types to icons and colors
  Map<String, IconData> get _serviceTypeIcons => {
    'Clinical Visit': Icons.medical_services,
    'Home Visit': Icons.home,
    'Video Consultation': Icons.video_call,
    'Voice Consultation': Icons.phone,
  };

  Map<String, Color> get _serviceTypeColors => {
    'Clinical Visit': AppTheme.primaryBlue,
    'Home Visit': Colors.orange,
    'Video Consultation': AppTheme.primaryGreen,
    'Voice Consultation': Colors.purple,
  };

  // Get icon based on service type
  IconData get _selectedIcon =>
      _serviceTypeIcons[_selectedServiceType] ?? Icons.medical_services;

  // Get color based on service type
  Color get _selectedColor =>
      _serviceTypeColors[_selectedServiceType] ?? AppTheme.primaryBlue;

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      // Populate form with existing service data
      _priceController.text = widget.service!['price'].toString();
      _durationController.text =
          widget.service!['durationMinutes']
              .toString(); // Changed from 'duration' to 'durationMinutes'
      _isActive = widget.service!['isActive'];
      _selectedServiceType = widget.service!['serviceType'] ?? 'Clinical Visit';
      _isCommissionInclusive = widget.service!['isCommissionInclusive'] ?? true;
    }

    // Calculate initial values
    _calculateCommission();

    // Add listener to price controller to update calculations
    _priceController.addListener(_calculateCommission);
  }

  void _calculateCommission() {
    double price = double.tryParse(_priceController.text) ?? 0.0;
    double commission = price * (_commissionPercentage / 100);

    if (_isCommissionInclusive) {
      // Inclusive commission
      _doctorReceives = price - commission;
      _platformReceives = commission;
      _customerPays = price;
    } else {
      // Exclusive commission
      _doctorReceives = price;
      _platformReceives = commission;
      _customerPays = price + commission;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.service == null ? 'Add New Service' : 'Edit Service',
        ),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service title

              // Service Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedServiceType,
                decoration: InputDecoration(
                  labelText: 'Service Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: Icon(_selectedIcon, color: _selectedColor),
                ),
                items:
                    _serviceTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Row(
                          children: [
                            Icon(
                              _serviceTypeIcons[type] ?? Icons.medical_services,
                              color:
                                  _serviceTypeColors[type] ??
                                  AppTheme.primaryBlue,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(type),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedServiceType = newValue;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a service type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price and duration in a row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Price (₹)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.currency_rupee),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      decoration: InputDecoration(
                        labelText: 'Duration (min)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.access_time),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Commission Settings
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commission Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Commission is inclusive in price',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        Switch(
                          value: _isCommissionInclusive,
                          onChanged: (value) {
                            setState(() {
                              _isCommissionInclusive = value;
                              _calculateCommission();
                            });
                          },
                          activeColor: AppTheme.primaryBlue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Commission Rate: $_commissionPercentage%',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),

                    // Commission Calculation Display
                    if (_priceController.text.isNotEmpty &&
                        double.tryParse(_priceController.text) != null)
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Customer Pays:'),
                              Text(
                                '₹${_customerPays.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('You Receive:'),
                              Text(
                                '₹${_doctorReceives.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Platform Fee:'),
                              Text(
                                '₹${_platformReceives.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Active status
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Service Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Text('Inactive'),
                    Switch(
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                      activeColor: AppTheme.primaryBlue,
                    ),
                    const Text('Active'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    widget.service == null ? 'Add Service' : 'Save Changes',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveService() {
    if (_formKey.currentState!.validate()) {
      // Create service object
      final service = {
        'id':
            widget.service?['id'] ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        'serviceType': _selectedServiceType,
        'price': double.parse(_priceController.text),
        'durationMinutes': int.parse(
          _durationController.text,
        ), // Changed from 'duration' to 'durationMinutes'
        'isActive': _isActive,
        'isCommissionInclusive': _isCommissionInclusive,
        'icon': _selectedIcon,
        'color': _selectedColor,
      };

      // Return the service to the previous screen
      Navigator.pop(context, service);
    }
  }
}
