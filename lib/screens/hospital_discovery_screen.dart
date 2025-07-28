import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidhya_front_end/models/hospital_models.dart';
import 'package:vaidhya_front_end/screens/hospital_detail_screen.dart';
import 'package:vaidhya_front_end/screens/hospital_profile_screen.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/widgets/custom_app_bar.dart';
import 'package:vaidhya_front_end/services/api_providers.dart';

import 'package:vaidhya_front_end/services/location_service.dart';
import 'package:vaidhya_front_end/widgets/google_places_address_input.dart';

class HospitalDiscoveryScreen extends ConsumerStatefulWidget {
  final String? selectedCategory;
  final String? selectedType;
  final double? latitude;
  final double? longitude;

  const HospitalDiscoveryScreen({
    Key? key,
    this.selectedCategory,
    this.selectedType,
    this.latitude,
    this.longitude,
  }) : super(key: key);

  @override
  ConsumerState<HospitalDiscoveryScreen> createState() =>
      _HospitalDiscoveryScreenState();
}

class _HospitalDiscoveryScreenState
    extends ConsumerState<HospitalDiscoveryScreen> {
  String _selectedType = 'All Types';
  String _searchQuery = '';
  bool _isLoading = false;
  List<Hospital> _hospitals = [];
  double? _currentLatitude;
  double? _currentLongitude;

  // State variables for saved location handling
  String _selectedCity = 'Select location';
  double? _selectedLatitude;
  double? _selectedLongitude;
  bool _isLoadingLocation = true;

  final List<String> _hospitalTypes = [
    'All Types',
    'General',
    'Specialty',
    'Clinic',
    'Emergency',
    'Diagnostic',
    'Maternity',
    'Ayurvedic',
    'Veterinary',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType =
        widget.selectedType != null
            ? _capitalizeFirst(widget.selectedType!)
            : 'All Types';
    _currentLatitude = widget.latitude;
    _currentLongitude = widget.longitude;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedLocation();
      _initializeLocation();
    });
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Future<void> _loadSavedLocation() async {
    try {
      final savedLocation = await LocationService.loadSelectedLocation();
      if (savedLocation != null) {
        setState(() {
          _selectedCity = savedLocation['address'];
          _selectedLatitude = savedLocation['latitude'];
          _selectedLongitude = savedLocation['longitude'];
          _isLoadingLocation = false;
        });
        // Fetch hospitals with saved location immediately
        _fetchNearbyHospitals();
      } else {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      print('Error loading saved location: $e');
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _handlePlaceSelected(PlaceDetails placeDetails) async {
    setState(() {
      _selectedCity = placeDetails.formattedAddress;
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

    // Refresh hospitals with new location
    _fetchNearbyHospitals();
  }

  Future<void> _initializeLocation() async {
    if (_currentLatitude == null || _currentLongitude == null) {
      try {
        final position = await LocationService.getCurrentPosition();
        if (position != null) {
          setState(() {
            _currentLatitude = position.latitude;
            _currentLongitude = position.longitude;
          });
        }
      } catch (e) {
        print('Error getting location: $e');
        // Use default location (Mumbai) if location access fails
        setState(() {
          _currentLatitude = 19.0760;
          _currentLongitude = 72.8777;
        });
      }
    }
    _fetchNearbyHospitals();
  }

  Future<void> _fetchNearbyHospitals() async {
    // Use saved location if available, otherwise use current location
    final lat = _selectedLatitude ?? _currentLatitude;
    final lng = _selectedLongitude ?? _currentLongitude;

    if (lat == null || lng == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final params = NearbyHospitalsParams(
        latitude: lat,
        longitude: lng,
        radius: 10.0,
        limit: 20,
        page: 1,
        type: _selectedType == 'All Types' ? null : _selectedType.toLowerCase(),
      );

      final response = await ref.read(nearbyHospitalsProvider(params).future);

      setState(() {
        _hospitals = response.hospitals;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching hospitals: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching hospitals: ${e.toString()}')),
        );
      }
    }
  }

  List<Hospital> get _filteredHospitals {
    if (_searchQuery.isEmpty) {
      return _hospitals;
    }

    return _hospitals.where((hospital) {
      return hospital.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          hospital.type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          hospital.specialties.any(
            (specialty) =>
                specialty.toLowerCase().contains(_searchQuery.toLowerCase()),
          );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.selectedCategory ?? 'Hospitals',
        showBackButton: true,
        showLocationSelector: true,
        currentLocation: _selectedCity, // Pass the saved location
        onPlaceSelected: _handlePlaceSelected, // Connect place selection
        notificationCount: 3,
      ),
      backgroundColor: Colors.white, // Change to white background
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchAndFilters(),
            _buildTypeChips(),
            Expanded(child: _buildHospitalsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search hospitals...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _hospitalTypes.length,
        itemBuilder: (context, index) {
          final type = _hospitalTypes[index];
          final isSelected = _selectedType == type;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedType = type;
                });
                _fetchNearbyHospitals();
              },
              backgroundColor: Colors.white,
              selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryBlue,
              labelStyle: TextStyle(
                color:
                    isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHospitalsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredHospitals.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredHospitals.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildHospitalCard(_filteredHospitals[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_hospital_outlined,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No hospitals found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(Hospital hospital) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HospitalProfileScreen(
                hospitalId: hospital.id,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.local_hospital,
                      color: AppTheme.primaryBlue,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hospital.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hospital.type,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${hospital.rating}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${hospital.reviewCount} reviews)',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${hospital.distance.toStringAsFixed(1)} km',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(Icons.bed, '${hospital.bedCount} beds'),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.medical_services,
                    '${hospital.doctorCount} doctors',
                  ),
                  if (hospital.isOpen24x7) ...[
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.access_time,
                      '24/7',
                      color: Colors.green,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? AppTheme.primaryBlue).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? AppTheme.primaryBlue),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color ?? AppTheme.primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
