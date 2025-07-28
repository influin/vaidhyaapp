import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/screens/onboarding_screen.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'dart:async';
import 'package:vaidhya_front_end/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidhya_front_end/services/api_providers.dart';
import 'package:vaidhya_front_end/screens/doctor_home_screen.dart';
import 'package:vaidhya_front_end/screens/hospital_home_screen.dart';
import 'package:vaidhya_front_end/screens/vendor_home_screen.dart';
import 'package:vaidhya_front_end/widgets/customer_bottom_navigation.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Scale animation (logo grows from 0.5 to 1.0 size)
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    // Opacity animation (logo fades in)
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Rotation animation (slight rotation for dynamic effect)
    _rotationAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    // Start the animation
    _animationController.forward();

    // Check authentication and navigate after delay
    Timer(const Duration(milliseconds: 3000), () {
      _checkAuthAndNavigate();
    });
  }

  // New method to check authentication and navigate accordingly
  Future<void> _checkAuthAndNavigate() async {
    final apiService = ApiService();
    await apiService.loadAuthToken();
    
    // If auth token exists, get user profile and navigate to appropriate dashboard
    if (apiService.hasAuthToken) {
      try {
        // Get user profile to determine role
        final userProfileAsync = await ref.read(userProfileProvider.future);
        final userRole = userProfileAsync['user']['role'];
        
        // Navigate based on user role
        if (mounted) {
          switch (userRole) {
            case 'doctor':
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const DoctorHomeScreen()),
              );
              break;
            case 'hospital':
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HospitalHomeScreen()),
              );
              break;
            case 'vendor':
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const VendorHomeScreen()),
              );
              break;
            case 'customer':
            default:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const CustomerMainScreen()),
              );
              break;
          }
        }
      } catch (e) {
        // If there's an error (like expired token), navigate to onboarding
        print('Error checking authentication: $e');
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        }
      }
    } else {
      // If no auth token, navigate to onboarding
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo using Image.asset
                      Container(
                        width: 200,
                        height: 200,
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // App name with gradient text
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
