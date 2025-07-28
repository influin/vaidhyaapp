import 'package:flutter/material.dart'; // Add this missing import
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vaidhya_front_end/screens/doctor_home_screen.dart';
import 'package:vaidhya_front_end/screens/hospital_home_screen.dart';
import 'package:vaidhya_front_end/screens/vendor_home_screen.dart';
import 'package:vaidhya_front_end/screens/verify_otp_screen.dart';
import 'package:vaidhya_front_end/services/api_providers.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/widgets/customer_bottom_navigation.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String _selectedUserType = 'customer'; // Default user type
  bool _isOtpLogin = true; // Toggle between OTP and password login

  // List of user types
  final List<String> _userTypes = ['customer', 'doctor', 'hospital', 'vendor'];

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final mobileNumber = _phoneController.text.trim();
        final result = await ref.read(
          loginWithMobileProvider(mobileNumber).future,
        );

        if (mounted) {
          // Navigate to OTP verification screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => VerifyOtpScreen(
                    phoneNumber: mobileNumber,
                    userType: _selectedUserType,
                    name: '', // Not needed for login flow
                    email: '', // Not needed for login flow
                    userId: result['userId'],
                    requiresPayment:
                        false, // Will be determined after OTP verification
                  ),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Login failed: ${e.toString()}';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _loginWithPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final loginData = {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        };

        final result = await ref.read(
          loginWithPasswordProvider(loginData).future,
        );

        // Check if user needs verification
        if (result['requiresVerification'] == true) {
          if (mounted) {
            // Navigate to OTP verification screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => VerifyOtpScreen(
                      phoneNumber: result['user']['mobileNumber'] ?? '',
                      userType: result['user']['role'] ?? _selectedUserType,
                      name: result['user']['name'] ?? '',
                      email: result['user']['email'] ?? '',
                      userId: result['userId'],
                      requiresPayment:
                          false, // Will be determined after verification
                    ),
              ),
            );
          }
          return;
        }

        // User is verified, navigate to appropriate screen
        if (mounted) {
          final userRole = result['user']['role'] ?? _selectedUserType;

          switch (userRole) {
            case 'doctor':
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const DoctorHomeScreen(),
                ),
              );
              break;
            case 'hospital':
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const HospitalHomeScreen(),
                ),
              );
              break;
            case 'vendor':
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const VendorHomeScreen(),
                ),
              );
              break;
            case 'customer':
            default:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const CustomerMainScreen(),
                ),
              );
              break;
          }
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Login failed: ${e.toString()}';
        });
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Logo
                Center(
                  child: Image.asset('assets/images/logo.png', height: 120),
                ),
                const SizedBox(height: 40),
                // Title
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login to your account',
                  style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Login Type Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('OTP Login'),
                      selected: _isOtpLogin,
                      onSelected: (selected) {
                        setState(() {
                          _isOtpLogin = true;
                        });
                      },
                      selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color:
                            _isOtpLogin
                                ? AppTheme.primaryBlue
                                : AppTheme.textSecondary,
                        fontWeight:
                            _isOtpLogin ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ChoiceChip(
                      label: const Text('Password Login'),
                      selected: !_isOtpLogin,
                      onSelected: (selected) {
                        setState(() {
                          _isOtpLogin = false;
                        });
                      },
                      selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color:
                            !_isOtpLogin
                                ? AppTheme.primaryBlue
                                : AppTheme.textSecondary,
                        fontWeight:
                            !_isOtpLogin ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // OTP Login Fields
                if (_isOtpLogin) ...[
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
                ] else ...[
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
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
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
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Navigate to forgot password screen
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: AppTheme.primaryBlue),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),
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
                // Login Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : (_isOtpLogin
                                ? _loginWithOtp
                                : _loginWithPassword),
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
                            : Text(
                              _isOtpLogin ? 'Send OTP' : 'Login',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 24),
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account? ',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        'Register',
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
