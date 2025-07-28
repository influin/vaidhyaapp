import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/services/api_providers.dart';
// Import the doctor screens from the doctors directory
import 'package:vaidhya_front_end/screens/doctors/doctor_appointments_screen.dart';
import 'package:vaidhya_front_end/screens/doctors/doctor_services_screen.dart';
import 'package:vaidhya_front_end/screens/doctors/doctor_payments_screen.dart';
import 'package:vaidhya_front_end/screens/doctors/doctor_profile_screen.dart';
import 'package:vaidhya_front_end/widgets/custom_app_bar.dart';

// Provider to control the selected tab index
final selectedTabProvider = StateProvider<int>((ref) => 0);

class DoctorHomeScreen extends ConsumerStatefulWidget {
  const DoctorHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends ConsumerState<DoctorHomeScreen> {
  final List<Widget> _screens = const [
    DoctorDashboardTab(),
    DoctorAppointmentsScreen(),
    DoctorServicesScreen(),
    DoctorPaymentsScreen(),
    DoctorProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final selectedIndex = ref.watch(selectedTabProvider);

    return userProfileAsync.when(
      data: (userProfile) {
        return Scaffold(
          appBar: CustomAppBar(
            title: _getAppBarTitle(selectedIndex),
            showBackButton: false,
          ),
          body: _screens[selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) {
              ref.read(selectedTabProvider.notifier).state = index;
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
                icon: Icon(Icons.calendar_today),
                label: 'Appointments',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.medical_services),
                label: 'Services',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.payment),
                label: 'Payments',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
      loading:
          () => const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading your profile...'),
                ],
              ),
            ),
          ),
      error:
          (error, stack) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Error loading profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(error.toString()),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(userProfileProvider),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Doctor Dashboard';
      case 1:
        return 'Appointments';
      case 2:
        return 'Services';
      case 3:
        return 'Payments';
      case 4:
        return 'Profile';
      default:
        return 'Doctor Dashboard';
    }
  }
}

class DoctorDashboardTab extends ConsumerWidget {
  const DoctorDashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final dashboardStatsAsync = ref.watch(doctorDashboardStatsProvider);

    return userProfileAsync.when(
      data: (userProfile) {
        // Extract the doctor's name from the user profile
        final String doctorName = userProfile['user']?['name'] ?? 'Doctor';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(doctorName),
              const SizedBox(height: 24),
              // Stats Row with AsyncValue builder for dashboard stats
              dashboardStatsAsync.when(
                data: (stats) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          _buildStatCard(
                            'Today\'s Appointments',
                            stats['today_appointments'].toString(),
                            Icons.calendar_today,
                            AppTheme.primaryGreen,
                          ),
                          const SizedBox(width: 16),
                          _buildStatCard(
                            'Pending Reviews',
                            stats['pending_reviews'].toString(),
                            Icons.rate_review,
                            AppTheme.primaryBlue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatCard(
                            'Total Patients',
                            stats['total_patients'].toString(),
                            Icons.people,
                            Colors.orange,
                          ),
                          const SizedBox(width: 16),
                          _buildStatCard(
                            'Today\'s Earnings',
                            '${stats['currency']} ${stats['today_earnings']}',
                            Icons.currency_rupee,
                            Colors.purple,
                          ),
                        ],
                      ),
                    ],
                  );
                },
                loading:
                    () => const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                error:
                    (error, stack) => Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('Failed to load stats data'),
                      ),
                    ),
              ),
              const SizedBox(height: 24),
              _buildUpcomingAppointmentsSection(ref),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 36),
                const SizedBox(height: 16),
                Text('Failed to load dashboard data'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => ref.refresh(userProfileProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildWelcomeCard(String doctorName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              doctorName.isNotEmpty ? doctorName[0] : 'D',
              style: const TextStyle(
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
              children: [
                Text(
                  'Welcome, Dr. $doctorName',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your dashboard is ready',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointmentsSection(WidgetRef ref) {
    // Watch the upcoming appointments
    final appointmentsAsync = ref.watch(doctorAppointmentsProvider('upcoming'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Appointments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // Navigate to the Appointments tab (index 1) using the provider
                ref.read(selectedTabProvider.notifier).state = 1;
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        appointmentsAsync.when(
          data: (appointments) {
            // If no appointments
            if (appointments.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('No upcoming appointments'),
                ),
              );
            }

            // Show only up to 3 appointments
            final displayAppointments =
                appointments.length > 3
                    ? appointments.sublist(0, 3)
                    : appointments;

            return Column(
              children:
                  displayAppointments.map((appointment) {
                    // Extract appointment details
                    final patientName = appointment['patientName'] ?? 'Patient';
                    final reason = appointment['reason'] ?? 'Consultation';
                    final time = appointment['appointmentTime'] ?? '00:00';
                    final date = appointment['appointmentDate'] ?? 'Today';

                    return _buildAppointmentCard(
                      patientName,
                      reason,
                      time,
                      date,
                    );
                  }).toList(),
            );
          },
          loading:
              () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(),
                ),
              ),
          error:
              (error, stack) => Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('Failed to load appointments'),
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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

  Widget _buildAppointmentCard(
    String name,
    String reason,
    String time,
    String date,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
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
              child: Center(
                child: Text(
                  name.isNotEmpty ? name.substring(0, 1) : 'P',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reason,
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
                  time,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
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
