import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/screens/verify_otp_screen.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidhya_front_end/services/api_providers.dart';
import 'package:vaidhya_front_end/widgets/google_places_address_input.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _facilityDetailsController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedUserType = 'customer';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  PlaceDetails? _selectedPlaceDetails;

  // Password strength variables
  double _passwordStrength = 0;
  String _passwordStrengthText = 'Weak';
  Color _passwordStrengthColor = Colors.red;

  final List<String> _userTypes = ['customer', 'doctor', 'hospital', 'vendor'];

  // Doctor categories
  final List<String> _doctorCategories = [
    'Ayurvedic',
    'Homeopathy',
    'Doctors/Physician',
    'Naturopathy',
    'Unani',
    'Alopathy',
    'Baby Care',
    'Veterinary',
  ];

  // Hospital types
  final List<String> _hospitalTypes = [
    'General Hospital',
    'Specialty Hospital',
    'Clinics',
    'Emergency Care',
    'Diagnostic Centers',
    'Maternity Hospitals',
    'Ayurvedic Centers',
    'Veterinary Hospitals',
  ];

  // Variables to track selected values
  String _selectedDoctorCategory = 'Ayurvedic';
  String _selectedHospitalType = 'General Hospital';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _specialtyController.dispose();
    _facilityDetailsController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Calculate password strength
  void _checkPasswordStrength(String password) {
    double strength = 0;
    String text = 'Weak';
    Color color = Colors.red;

    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0;
        _passwordStrengthText = 'Weak';
        _passwordStrengthColor = Colors.red;
      });
      return;
    }

    // Check length
    if (password.length >= 8) strength += 0.25;

    // Check for uppercase letters
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;

    // Check for numbers
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;

    // Check for special characters
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;

    // Determine text and color based on strength
    if (strength <= 0.25) {
      text = 'Weak';
      color = Colors.red;
    } else if (strength <= 0.5) {
      text = 'Medium';
      color = Colors.orange;
    } else if (strength <= 0.75) {
      text = 'Good';
      color = Colors.yellow.shade700;
    } else {
      text = 'Strong';
      color = Colors.green;
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthText = text;
      _passwordStrengthColor = color;
    });
  }

  // Register user method
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      // Additional validation for hospital type
      if (_selectedUserType == 'hospital' &&
          (_selectedHospitalType.isEmpty ||
              _facilityDetailsController.text.trim().isEmpty)) {
        setState(() {
          _errorMessage = 'Hospital type and facility details are required';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Prepare base user data
        final Map<String, dynamic> userData = {
          'name': _nameController.text.trim(),
          'mobileNumber': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'role': _selectedUserType,
          'preferredLanguage': 'english',
        };

        // Add role-specific fields
        if (_selectedUserType == 'doctor') {
          userData['specialty'] = _specialtyController.text.trim();
          userData['category'] = _selectedDoctorCategory;
        } else if (_selectedUserType == 'hospital' ||
            _selectedUserType == 'vendor') {
          userData['facilityDetails'] = _facilityDetailsController.text.trim();

          // Add hospital type for hospital users
          if (_selectedUserType == 'hospital') {
            userData['type'] = _selectedHospitalType;
          }
        }

        // Common address handling for ALL user types (based on hospital logic)
        if (_selectedPlaceDetails != null) {
          // Extract location data for all user types
          userData['city'] =
              _selectedPlaceDetails!.addressComponents['locality'] ??
              _selectedPlaceDetails!.addressComponents['city'] ??
              '';
          userData['state'] =
              _selectedPlaceDetails!
                  .addressComponents['administrative_area_level_1'] ??
              _selectedPlaceDetails!.addressComponents['state'] ??
              '';
          userData['postalCode'] =
              _selectedPlaceDetails!.addressComponents['postal_code'] ??
              _selectedPlaceDetails!.addressComponents['postalCode'] ??
              '';

          // placeDataMap structure for all user types
          final placeDataMap = {
            'name': _selectedPlaceDetails!.name ?? '',
            'street_number':
                _selectedPlaceDetails!.addressComponents['street_number'] ?? '',
            'route': _selectedPlaceDetails!.addressComponents['route'] ?? '',
            'city':
                _selectedPlaceDetails!.addressComponents['locality'] ??
                _selectedPlaceDetails!.addressComponents['city'] ??
                '',
            'state':
                _selectedPlaceDetails!
                    .addressComponents['administrative_area_level_1'] ??
                _selectedPlaceDetails!.addressComponents['state'] ??
                '',
            'postal_code':
                _selectedPlaceDetails!.addressComponents['postal_code'] ??
                _selectedPlaceDetails!.addressComponents['postalCode'] ??
                '',
            'country':
                _selectedPlaceDetails!.addressComponents['country'] ?? '',
            'latitude': _selectedPlaceDetails!.lat?.toString() ?? '0.0',
            'longitude': _selectedPlaceDetails!.lng?.toString() ?? '0.0',
            'place_id': _selectedPlaceDetails!.placeId ?? '',
          };

          // Store placeData as JSON string for all user types
          userData['placeData'] = json.encode(placeDataMap);
        }

        // Basic address text for all user types
        userData['address'] = _addressController.text.trim();

        // Add Google Places data for all user types
        if (_selectedPlaceDetails != null) {
          final addressData = {
            'place_id': _selectedPlaceDetails!.placeId,
            'latitude': _selectedPlaceDetails!.lat,
            'longitude': _selectedPlaceDetails!.lng,
            'formatted_address': _selectedPlaceDetails!.formattedAddress,
            'address_line1': _addressController.text.trim(),
            'city':
                _selectedPlaceDetails!.addressComponents['locality'] ??
                _selectedPlaceDetails!.addressComponents['city'] ??
                '',
            'state':
                _selectedPlaceDetails!
                    .addressComponents['administrative_area_level_1'] ??
                _selectedPlaceDetails!.addressComponents['state'] ??
                '',
            'postalCode':
                _selectedPlaceDetails!.addressComponents['postal_code'] ??
                _selectedPlaceDetails!.addressComponents['postalCode'] ??
                '',
            'country':
                _selectedPlaceDetails!.addressComponents['country'] ?? '',
          };
          userData['addressDataJson'] = json.encode(addressData);
        }

        // Call the registration API
        final result = await ref.read(registerUserProvider(userData).future);

        if (mounted) {
          // Navigate to OTP verification screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => VerifyOtpScreen(
                    phoneNumber: _phoneController.text.trim(),
                    userType: _selectedUserType,
                    name: _nameController.text.trim(),
                    email: _emailController.text.trim(),
                    userId: result['userId'],
                    requiresPayment: result['requiresPayment'] ?? false,
                  ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Registration failed: ${e.toString()}';
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryBlue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(color: AppTheme.primaryBlue),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // User Type Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedUserType,
                  decoration: const InputDecoration(
                    labelText: 'User Type',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items:
                      _userTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type.substring(0, 1).toUpperCase() +
                                type.substring(1),
                          ),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedUserType = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Doctor-specific fields
                if (_selectedUserType == 'doctor') ...[
                  // Category Dropdown for doctors
                  DropdownButtonFormField<String>(
                    value: _selectedDoctorCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items:
                        _doctorCategories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedDoctorCategory = newValue;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Specialty Field
                  TextFormField(
                    controller: _specialtyController,
                    decoration: const InputDecoration(
                      labelText: 'Specialty',
                      prefixIcon: Icon(Icons.medical_services),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your specialty';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Google Places Address Input for doctors
                  GooglePlacesAddressInput(
                    controller: _addressController,
                    onPlaceSelected: (PlaceDetails details) {
                      setState(() {
                        _selectedPlaceDetails = details;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Clinic Address',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_selectedUserType == 'customer') ...[
                  GooglePlacesAddressInput(
                    controller: _addressController,
                    onPlaceSelected: (PlaceDetails details) {
                      setState(() {
                        _selectedPlaceDetails = details;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Clinic Address',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Hospital/Vendor-specific fields
                if (_selectedUserType == 'hospital' ||
                    _selectedUserType == 'vendor') ...[
                  // Facility Details
                  TextFormField(
                    controller: _facilityDetailsController,
                    decoration: const InputDecoration(
                      labelText: 'Facility Details',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter facility details';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Hospital type dropdown - only for hospital user type
                  if (_selectedUserType == 'hospital') ...[
                    DropdownButtonFormField<String>(
                      value: _selectedHospitalType,
                      decoration: const InputDecoration(
                        labelText: 'Hospital Type',
                        prefixIcon: Icon(Icons.local_hospital),
                        border: OutlineInputBorder(),
                      ),
                      items:
                          _hospitalTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedHospitalType = newValue;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a hospital type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Google Places Address Input for hospitals/vendors
                  GooglePlacesAddressInput(
                    controller: _addressController,
                    onPlaceSelected: (PlaceDetails details) {
                      setState(() {
                        _selectedPlaceDetails = details;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                  onChanged: _checkPasswordStrength,
                ),
                const SizedBox(height: 8),

                // Password Strength Indicator
                LinearProgressIndicator(
                  value: _passwordStrength,
                  backgroundColor: Colors.grey[300],
                  color: _passwordStrengthColor,
                ),
                const SizedBox(height: 4),
                Text(
                  'Password Strength: $_passwordStrengthText',
                  style: TextStyle(color: _passwordStrengthColor),
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Error Message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Register Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
