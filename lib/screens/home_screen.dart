import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/screens/select_category_screen.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/widgets/custom_app_bar.dart';
import 'package:vaidhya_front_end/widgets/upcoming_appointment_card.dart';
import 'package:vaidhya_front_end/widgets/quick_actions_card.dart';
import 'package:vaidhya_front_end/widgets/top_doctors_card.dart';
import 'package:vaidhya_front_end/widgets/google_places_address_input.dart';
import 'package:vaidhya_front_end/services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedLocation;
  double? _selectedLatitude;
  double? _selectedLongitude;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  // Load saved location on app startup
  Future<void> _loadSavedLocation() async {
    try {
      final savedLocation = await LocationService.loadSelectedLocation();
      if (savedLocation != null) {
        setState(() {
          _selectedLocation = savedLocation['address'];
          _selectedLatitude = savedLocation['latitude'];
          _selectedLongitude = savedLocation['longitude'];
          _isLoadingLocation = false;
        });
      } else {
        setState(() {
          _selectedLocation = 'Select location';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      print('Error loading saved location: $e');
      setState(() {
        _selectedLocation = 'Select location';
        _isLoadingLocation = false;
      });
    }
  }

  void _handleLocationSelected(String location) {
    setState(() {
      _selectedLocation = location;
      // Note: For current location, you would get coordinates from location service
      // This is a placeholder - you'd integrate with your location service
    });
  }

  Future<void> _handlePlaceSelected(PlaceDetails placeDetails) async {
    // Only update state if the location actually changed
    if (_selectedLatitude != placeDetails.lat ||
        _selectedLongitude != placeDetails.lng) {
      setState(() {
        _selectedLocation = placeDetails.formattedAddress;
        _selectedLatitude = placeDetails.lat;
        _selectedLongitude = placeDetails.lng;
      });

      // Save the selected location to storage
      try {
        await LocationService.saveSelectedLocation(
          address: placeDetails.formattedAddress,
          latitude: placeDetails.lat,
          longitude: placeDetails.lng,
        );
      } catch (e) {
        print('Error saving location: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while location is being loaded
    if (_isLoadingLocation) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Home',
          showBackButton: false,
          showLocationSelector: false,
          notificationCount: 3,
        ),
        backgroundColor: AppTheme.lightGrey.withOpacity(0.05),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Home',
        showBackButton: false,
        showLocationSelector: true,
        currentLocation: _selectedLocation,
        onPlaceSelected: _handlePlaceSelected,
        onCurrentLocationSelected: _handleLocationSelected,
        notificationCount: 3,
      ),
      backgroundColor: AppTheme.lightGrey.withOpacity(0.05),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Search bar
                    // Replace the search bar Container with a GestureDetector
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => SelectCategoryScreen(
                                  latitude: _selectedLatitude,
                                  longitude: _selectedLongitude,
                                ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: AppTheme.textSecondary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Search doctors, medicines, etc.',
                                style: TextStyle(
                                  color: AppTheme.textSecondary.withOpacity(
                                    0.7,
                                  ),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Icon(Icons.mic, color: AppTheme.primaryBlue),
                          ],
                        ),
                      ),
                    ),

                    // Quick actions for common tasks
                    QuickActionsCard(),

                    // Upcoming appointment card
                    UpcomingAppointmentCard(),

                    // Top doctors list with location data
                    TopDoctorsCard(
                      latitude: _selectedLatitude,
                      longitude: _selectedLongitude,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// In your navigation code
