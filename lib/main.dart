import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidhya_front_end/screens/appointments_screen.dart';
import 'package:vaidhya_front_end/services/api_service.dart';
import 'package:vaidhya_front_end/services/theme_provider.dart';

import 'package:vaidhya_front_end/screens/doctor_discovery_screen.dart';
import 'package:vaidhya_front_end/screens/doctor_home_screen.dart';
import 'package:vaidhya_front_end/screens/doctor_profile_screen.dart';
import 'package:vaidhya_front_end/screens/hospital_home_screen.dart';
import 'package:vaidhya_front_end/screens/login_screen.dart';
import 'package:vaidhya_front_end/screens/onboarding_screen.dart';
import 'package:vaidhya_front_end/screens/register_screen.dart';
import 'package:vaidhya_front_end/screens/splash_screen.dart';
import 'package:vaidhya_front_end/screens/vendor_home_screen.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/widgets/customer_bottom_navigation.dart';
import 'screens/video_call_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService().loadAuthToken();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'Vaidhya',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      initialRoute: '/splash',
      routes: {
        '/': (context) => const SplashScreen(),
        '/splash': (context) => const SplashScreen(), // Add this line
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const CustomerMainScreen(),
        '/doctors': (context) => const DoctorDiscoveryScreen(),
        '/doctor-home': (context) => const DoctorHomeScreen(),
        '/hospital-home': (context) => const HospitalHomeScreen(),
        '/vendor-home': (context) => const VendorHomeScreen(),
        '/appointments': (context) => const AppointmentsScreen(),
        '/video_call': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return VideoCallScreen(
            channelName: args['channelName'],
            doctorName: args['doctorName'],
            isVideoCall: args['isVideoCall'] ?? true,
          );
        },
      },
    );
  }
}
