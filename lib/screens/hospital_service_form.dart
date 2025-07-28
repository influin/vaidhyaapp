import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';

class HospitalServiceForm extends StatefulWidget {
  final Map<String, dynamic>? item; // Pass existing item for editing, null for new item
  final String type; // 'service', 'lab', or 'test'

  const HospitalServiceForm({Key? key, this.item, required this.type}) : super(key: key);

  @override
  State<HospitalServiceForm> createState() => _HospitalServiceFormState();
}

class _HospitalServiceFormState extends State<HospitalServiceForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  
  IconData _selectedIcon = Icons.medical_services;
  bool _isActive = true;

  final List<IconData> _iconOptions = [
    Icons.medical_services,
    Icons.local_hospital,
    Icons.emergency,
    Icons.biotech,
    Icons.science,
    Icons.monitor_heart,
    Icons.healing,
    Icons.health_and_safety,
    Icons.medication,
    Icons.bloodtype,
    Icons.radio,
    Icons.opacity,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      // Populate form with existing item data
      _nameController.text = widget.item!['name'];
      _descriptionController.text = widget.item!['description'] ?? '';
      _isActive = widget.item!['isActive'];
      _selectedIcon = widget.item!['icon'];
      
      if (widget.type == 'test') {
        _priceController.text = widget.item!['price'].toString();
        _durationController.text = widget.item!['duration'].toString();
      } else {
        _minPriceController.text = widget.item!['minPrice'].toString();
        _maxPriceController.text = widget.item!['maxPrice'].toString();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title;
    switch (widget.type) {
      case 'service':
        title = widget.item == null ? 'Add New Service' : 'Edit Service';
        break;
      case 'lab':
        title = widget.item == null ? 'Add New Lab' : 'Edit Lab';
        break;
      case 'test':
        title = widget.item == null ? 'Add New Test' : 'Edit Test';
        break;
      default:
        title = widget.item == null ? 'Add New Item' : 'Edit Item';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '${widget.type.substring(0, 1).toUpperCase() + widget.type.substring(1)} Name',
                  hintText: widget.type == 'service' ? 'e.g., General Consultation' :
                           widget.type == 'lab' ? 'e.g., Pathology Lab' : 'e.g., Complete Blood Count',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g., Basic health checkup and consultation',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // Price fields
              if (widget.type == 'test') ...[  
                // Single price for tests
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price (₹)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.currency_rupee),
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
                        decoration: const InputDecoration(
                          labelText: 'Duration (days)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
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
              ] else ...[  
                // Price range for services and labs
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Min Price (₹)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.currency_rupee),
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
                        controller: _maxPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Max Price (₹)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.currency_rupee),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid price';
                          }
                          final minPrice = double.tryParse(_minPriceController.text);
                          final maxPrice = double.tryParse(value);
                          if (minPrice != null && maxPrice != null && maxPrice < minPrice) {
                            return 'Max price must be greater than min price';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              
              // Icon selection
              const Text(
                'Select Icon',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _iconOptions.map((icon) {
                  final isSelected = _selectedIcon.codePoint == icon.codePoint;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryBlue.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? AppTheme.primaryBlue : Colors.grey,
                        size: 28,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              // Active status
              Row(
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              const SizedBox(height: 32),
              
              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    widget.item == null ? 'Add ${widget.type.substring(0, 1).toUpperCase() + widget.type.substring(1)}' : 'Save Changes',
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

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      // Create item object based on type
      final Map<String, dynamic> item;
      
      if (widget.type == 'test') {
        item = {
          'id': widget.item?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'name': _nameController.text,
          'description': _descriptionController.text.isEmpty ? null : _descriptionController.text,
          'price': double.parse(_priceController.text),
          'currency': '₹',
          'duration': int.parse(_durationController.text),
          'isActive': _isActive,
          'icon': _selectedIcon,
        };
      } else {
        item = {
          'id': widget.item?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'name': _nameController.text,
          'description': _descriptionController.text.isEmpty ? null : _descriptionController.text,
          'minPrice': double.parse(_minPriceController.text),
          'maxPrice': double.parse(_maxPriceController.text),
          'currency': '₹',
          'isActive': _isActive,
          'icon': _selectedIcon,
        };
      }
      
      // Return the item to the previous screen
      Navigator.pop(context, item);
    }
  }
}