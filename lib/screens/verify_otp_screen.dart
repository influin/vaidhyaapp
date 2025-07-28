import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vaidhya_front_end/screens/subscription_screen.dart';
import 'package:vaidhya_front_end/services/api_providers.dart';
import 'package:vaidhya_front_end/services/api_service.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/widgets/customer_bottom_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String userType;
  final String name;
  final String email;
  final String userId;
  final bool requiresPayment;

  const VerifyOtpScreen({
    Key? key,
    required this.phoneNumber,
    required this.userType,
    required this.name,
    required this.email,
    required this.userId,
    required this.requiresPayment,
  }) : super(key: key);

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  int _resendSeconds = 30;
  Timer? _resendTimer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    // Start the resend timer
    _startResendTimer();
    // Send OTP when screen loads
  }

  @override
  void dispose() {
    // Dispose controllers and focus nodes
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendSeconds = 30;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyOTP() async {
    // Collect OTP from all text fields
    final otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length != 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Call the API to verify OTP
      final verifyData = {'mobileNumber': widget.phoneNumber, 'otp': otp};

      final result = await ref.read(verifyOTPProvider(verifyData).future);

      // Store the token and user data
      final token = result['token'];
      final user = result['user'];

      if (mounted) {
        // Navigate based on user role and payment requirement
        if (user['role'] == 'customer') {
          // Navigate to home screen for customers
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const CustomerMainScreen()),
          );
        } else if (user['requiresPayment'] == true && 
                   ['doctor', 'hospital', 'vendor'].contains(user['role'])) {
          // Navigate to subscription screen for users requiring payment
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => SubscriptionScreen(userType: user['role']),
            ),
          );
        } else {
          // Navigate to appropriate home screen based on role
          // You'll need to implement this navigation logic based on your app's structure
          // For example:
          switch (user['role']) {
            case 'doctor':
              // Navigate to doctor home screen
              break;
            case 'hospital':
              // Navigate to hospital home screen
              break;
            case 'vendor':
              // Navigate to vendor home screen
              break;
            default:
              // Default navigation
              break;
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Verification failed: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resendOTP() async {
    if (_canResend) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Call the API to resend OTP
        final otpData = {'mobileNumber': widget.phoneNumber};

        await ref.read(sendOTPProvider(otpData).future);

        // Reset the timer
        _startResendTimer();

        // Show success message
        setState(() {
          _errorMessage = null; // Clear any previous error
        });

        // Optional: Show a success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent successfully')),
        );
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to resend OTP: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
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
          'Verify Phone Number',
          style: TextStyle(color: AppTheme.primaryBlue),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Icon(
                Icons.sms_outlined,
                size: 80,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(height: 24),
              Text(
                'Verification Code',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We have sent the verification code to\n${widget.phoneNumber}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 45,
                    height: 55,
                    child: TextFormField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppTheme.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryBlue,
                            width: 2,
                          ),
                        ),
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          // Move to next field
                          if (index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else {
                            // Last field, hide keyboard
                            _focusNodes[index].unfocus();
                            // Auto-verify when all fields are filled
                            _verifyOTP();
                          }
                        }
                      },
                    ),
                  ),
                ),
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
              // Verify Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Verify',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 24),
              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive the code? ",
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  TextButton(
                    onPressed: _canResend ? _resendOTP : null,
                    child: Text(
                      _canResend
                          ? 'Resend'
                          : 'Resend in $_resendSeconds seconds',
                      style: TextStyle(
                        color:
                            _canResend
                                ? AppTheme.primaryBlue
                                : AppTheme.textSecondary,
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
    );
  }
}
