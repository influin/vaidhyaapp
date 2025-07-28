import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/screens/doctor_profile_screen.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/widgets/custom_app_bar.dart';
import 'package:vaidhya_front_end/widgets/doctor_category_card.dart';
import 'package:vaidhya_front_end/widgets/doctor_search_filter.dart';
import 'package:vaidhya_front_end/widgets/featured_doctor_card.dart';
import 'package:vaidhya_front_end/services/api_service.dart';
import 'package:vaidhya_front_end/services/location_service.dart';
import 'package:vaidhya_front_end/widgets/google_places_address_input.dart';

class DoctorDiscoveryScreen extends StatefulWidget {
  final String? selectedCategory;
  final double? latitude;
  final double? longitude;

  const DoctorDiscoveryScreen({
    Key? key,
    this.selectedCategory,
    this.latitude,
    this.longitude,
  }) : super(key: key);

  @override
  State<DoctorDiscoveryScreen> createState() => _DoctorDiscoveryScreenState();
}

class _DoctorDiscoveryScreenState extends State<DoctorDiscoveryScreen> {
  // Filter state variables
  String _selectedSpecialty = 'All Specialties';
  String _searchQuery = '';
  String _selectedCity = 'Select location';
  double? _selectedLatitude;
  double? _selectedLongitude;
  double _minRating = 0.0;
  bool _showAvailableOnly = false;
  bool _isGridView = false;
  RangeValues _priceRange = const RangeValues(500, 2000);
  String _selectedCategory = '';
  bool _isLoadingLocation = true;

  // New filter state variables
  String _consultationType = 'All Types'; // In-person, Video, Chat
  String _sortBy = 'Rating'; // Rating, Price, Distance
  bool _availableNow = false; // Now or Later

  // For infinite scroll
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  int _currentPage = 1;
  int _itemsPerPage = 10;

  // Add this flag to prevent multiple API calls
  bool _isApiCallInProgress = false;

  // Cache the filtered doctors to prevent repeated calculations
  List<Map<String, dynamic>>? _cachedFilteredDoctors;
  String _lastFilterKey = '';

  // Example list of specialties
  final List<String> _specialties = [
    'All Specialties',
    'Cardiology',
    'Neurologist',
    'Pediatrician',
    'Dermatologist',
    'Orthopedic',
    'Gynecologist',
    'Ophthalmologist',
    'Dentist',
    'Psychiatrist',
  ];

  // Example list of cities
  final List<String> _cities = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Ahmedabad',
  ];

  // Example list of consultation types
  final List<String> _consultationTypes = [
    'All Types',
    'In-person',
    'Video',
    'Chat',
  ];

  // Example list of sort options

  // Example list of doctors (in a real app, this would come from an API)
  List<Map<String, dynamic>> _doctors = [
    {
      'name': 'Dr. Sharma',
      'specialty': 'Cardiology',
      'city': 'Mumbai',
      'rating': 4.8,
      'fee': '₹800',
      'available': true,
      'image': null, // Would be an actual image in production
      'featured': true,
      'experience': '15 years',
      'patients': '5000+',
      'category': 'Heart',
    },
    {
      'name': 'Dr. Patel',
      'specialty': 'Neurologist',
      'city': 'Mumbai',
      'rating': 4.7,
      'fee': '₹1000',
      'available': true,
      'image': null,
      'featured': true,
      'experience': '12 years',
      'patients': '3500+',
      'category': 'Brain',
    },
    {
      'name': 'Dr. Gupta',
      'specialty': 'Pediatrician',
      'city': 'Delhi',
      'rating': 4.9,
      'fee': '₹700',
      'available': false,
      'image': null,
      'featured': false,
      'experience': '10 years',
      'patients': '4000+',
      'category': 'General',
    },
    {
      'name': 'Dr. Singh',
      'specialty': 'Dermatologist',
      'city': 'Bangalore',
      'rating': 4.5,
      'fee': '₹900',
      'available': true,
      'image': null,
      'featured': false,
      'experience': '8 years',
      'patients': '2800+',
      'category': 'General',
    },
    {
      'name': 'Dr. Reddy',
      'specialty': 'Orthopedic',
      'city': 'Hyderabad',
      'rating': 4.6,
      'fee': '₹850',
      'available': true,
      'image': null,
      'featured': true,
      'experience': '14 years',
      'patients': '4200+',
      'category': 'Bone',
    },
    {
      'name': 'Dr. Kumar',
      'specialty': 'Gynecologist',
      'city': 'Chennai',
      'rating': 4.4,
      'fee': '₹750',
      'available': false,
      'image': null,
      'featured': false,
      'experience': '9 years',
      'patients': '3100+',
      'category': 'General',
    },
  ];

  // Simplified filtered doctors - since we're using API filtering, minimal local filtering needed
  List<Map<String, dynamic>> get _filteredDoctors {
    return _doctors.where((doctor) {
      // Only apply search query filter locally (if needed)
      if (_searchQuery.isNotEmpty &&
          !doctor['name'].toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !doctor['specialty'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          )) {
        return false;
      }
      return true;
    }).toList();
  }

  // Featured doctors
  List<Map<String, dynamic>> get _featuredDoctors {
    return _filteredDoctors
        .where((doctor) => doctor['featured'] == true)
        .toList();
  }

  // Add this method to load saved location
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
      } else {
        setState(() {
          _selectedCity = 'Select location';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      print('Error loading saved location: $e');
      setState(() {
        _selectedCity = 'Select location';
        _isLoadingLocation = false;
      });
    }
  }

  // Add method to handle location updates
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

    // Fetch doctors with new location
    _fetchNearbyDoctors();
  }

  // Add this method to fetch doctors from API
  Future<void> _fetchNearbyDoctors() async {
    // Prevent multiple simultaneous API calls
    if (_isApiCallInProgress) return;

    // Use either widget location or selected location
    final latitude = widget.latitude ?? _selectedLatitude;
    final longitude = widget.longitude ?? _selectedLongitude;

    if (latitude != null && longitude != null) {
      try {
        _isApiCallInProgress = true;
        print('=== FETCHING NEARBY DOCTORS ===');
        print('Latitude: $latitude');
        print('Longitude: $longitude');
        print('Selected Category: $_selectedCategory');

        final response = await ApiService().getNearbyDoctors(
          latitude: latitude,
          longitude: longitude,
          radius: 10,
          limit: 10,
          specialty: 'all',
          category:
              _selectedCategory.isNotEmpty && _selectedCategory != 'all'
                  ? _selectedCategory
                  : null,
        );

        if (mounted) {
          setState(() {
            _doctors =
                response.doctors
                    .map(
                      (doctor) => {
                        'id': doctor.id,
                        'name': doctor.name,
                        'email': doctor.email,
                        'specialty': doctor.specialty,
                        'phone': doctor.phoneNumber,
                        'rating': doctor.rating,
                        'reviewCount': doctor.reviewCount,
                        'fee':
                            doctor.consultationTypes.isNotEmpty
                                ? '₹${doctor.consultationTypes.first.fee}'
                                : '₹0',
                        'available': doctor.isAvailableNow,
                        'distance': '${doctor.distance.toStringAsFixed(1)} km',
                        'address':
                            doctor.addresses.isNotEmpty
                                ? '${doctor.addresses.first.addressLine1}, ${doctor.addresses.first.city}'
                                : 'Address not available',
                        'category': _selectedCategory,
                        'qualification': doctor.qualification,
                        'languages': doctor.languages,
                        'specializations': doctor.specializations,
                        'consultationTypes': doctor.consultationTypes,
                        'fullAddress': doctor.addresses,
                      },
                    )
                    .toList();
          });
          // Add debug call here
          _debugDoctorsData();
        }

        print(
          'Successfully loaded ${_doctors.length} doctors for category: $_selectedCategory',
        );
      } catch (e) {
        print('Error fetching nearby doctors: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load doctors: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        _isApiCallInProgress = false;
      }
    } else {
      print('Location not available - cannot fetch nearby doctors');
    }
  }

  @override
  void initState() {
    super.initState();
    // Set the selected category if provided
    if (widget.selectedCategory != null) {
      _selectedCategory = widget.selectedCategory!;
    }
    _scrollController.addListener(_scrollListener);

    // Load saved location first
    _loadSavedLocation().then((_) {
      // Fetch doctors when screen loads with a small delay
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchNearbyDoctors();
      });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      _loadMoreDoctors();
    }
  }

  void _loadMoreDoctors() {
    if (!_isLoading && !_isApiCallInProgress) {
      setState(() {
        _isLoading = true;
      });

      // Simulate loading more doctors
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _currentPage++;
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we're being displayed directly or as part of CustomerMainScreen

    return Scaffold(
      // Only show appBar if we're navigated to directly (not as a tab)
      appBar: CustomAppBar(
        title: 'Find Doctors',
        showBackButton: true,
        showLocationSelector: true,
        currentLocation: _isLoadingLocation ? 'Loading...' : _selectedCity,
        notificationCount: 3,
        onPlaceSelected: _handlePlaceSelected,
        onLocationTap: () {
          // Navigate to location picker
          Navigator.pushNamed(context, '/location_picker').then((result) {
            if (result != null && result is PlaceDetails) {
              _handlePlaceSelected(result);
            }
          });
        },
        onNotificationTap: () {
          // Handle notification tap
        },
      ),
      backgroundColor: AppTheme.lightGrey,

      body: SafeArea(
        child: Column(
          children: [
            // Search and filter section
            DoctorSearchFilter(
              searchQuery: _searchQuery,
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              specialties: _specialties,
              selectedSpecialty: _selectedSpecialty,
              onSpecialtyChanged: (specialty) {
                setState(() {
                  _selectedSpecialty = specialty;
                });
              },
              minRating: _minRating,
              onRatingChanged: (rating) {
                setState(() {
                  _minRating = rating;
                });
              },
              showAvailableOnly: _showAvailableOnly,
              onAvailabilityChanged: (value) {
                setState(() {
                  _showAvailableOnly = value;
                });
              },
              priceRange: _priceRange,
              onPriceRangeChanged: (range) {
                setState(() {
                  _priceRange = range;
                });
              },
              recentSearches: const ['Cardiology', 'Dr. Sharma', 'Dentist'],
              // New filter options
              consultationType: _consultationType,
              onConsultationTypeChanged: (type) {
                setState(() {
                  _consultationType = type;
                });
              },
              sortBy: _sortBy,
              onSortByChanged: (option) {
                setState(() {
                  _sortBy = option;
                });
              },
              availableNow: _availableNow,
              onAvailableNowChanged: (value) {
                setState(() {
                  _availableNow = value;
                });
              },
            ),

            // Doctors list with infinite scroll
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    _buildSpecialtyChips(),
                    // Removed featured doctors section
                    _buildDoctorsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchFilter() {
    return DoctorSearchFilter(
      consultationType: _consultationType,
      onConsultationTypeChanged: (value) {
        setState(() {
          _consultationType = value;
        });
      },
      sortBy: _sortBy,
      onSortByChanged: (value) {
        setState(() {
          _sortBy = value;
        });
      },
      availableNow: _availableNow,
      onAvailableNowChanged: (value) {
        setState(() {
          _availableNow = value;
        });
      },
      searchQuery: _searchQuery,
      onSearchChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      specialties: _specialties,
      selectedSpecialty: _selectedSpecialty,
      onSpecialtyChanged: (value) {
        setState(() {
          _selectedSpecialty = value;
        });
      },
      minRating: _minRating,
      onRatingChanged: (value) {
        setState(() {
          _minRating = value;
        });
      },
      showAvailableOnly: _showAvailableOnly,
      onAvailabilityChanged: (value) {
        setState(() {
          _showAvailableOnly = value;
        });
      },
      priceRange: _priceRange,
      onPriceRangeChanged: (value) {
        setState(() {
          _priceRange = value;
        });
      },
      recentSearches: ['Cardiology', 'Dr. Sharma', 'Dentist'],
    );
  }

  Widget _buildCategoriesSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all categories
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSpecialtyChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Specialty',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _specialties.length,
              itemBuilder: (context, index) {
                final specialty = _specialties[index];
                final isSelected = _selectedSpecialty == specialty;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      specialty,
                      style: TextStyle(
                        color:
                            isSelected ? AppTheme.white : AppTheme.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedSpecialty = specialty;
                      });
                      // Call API with selected specialty
                      _fetchNearbyDoctorsWithSpecialty(specialty);
                    },
                    backgroundColor: AppTheme.lightGrey.withOpacity(0.3),
                    selectedColor: AppTheme.primaryBlue,
                    checkmarkColor: AppTheme.white,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Add this new method to fetch doctors with specialty filter
  Future<void> _fetchNearbyDoctorsWithSpecialty(String specialty) async {
    // Prevent multiple simultaneous API calls
    if (_isApiCallInProgress) return;

    // Use either widget location or selected location
    final latitude = widget.latitude ?? _selectedLatitude;
    final longitude = widget.longitude ?? _selectedLongitude;

    if (latitude != null && longitude != null) {
      try {
        _isApiCallInProgress = true;
        print('=== FETCHING NEARBY DOCTORS WITH SPECIALTY ===');
        print('Latitude: $latitude');
        print('Longitude: $longitude');
        print('Selected Category: $_selectedCategory');
        print('Selected Specialty: $specialty');

        final response = await ApiService().getNearbyDoctors(
          latitude: latitude,
          longitude: longitude,
          radius: 10,
          limit: 20,
          specialty: specialty == 'All Specialties' ? null : specialty,
          category:
              _selectedCategory.isNotEmpty && _selectedCategory != 'all'
                  ? _selectedCategory
                  : null,
        );

        if (mounted) {
          setState(() {
            _doctors =
                response.doctors
                    .map(
                      (doctor) => {
                        'id': doctor.id,
                        'name': doctor.name,
                        'email': doctor.email,
                        'specialty': doctor.specialty,
                        'phone': doctor.phoneNumber,
                        'rating': doctor.rating,
                        'reviewCount': doctor.reviewCount,
                        'fee':
                            doctor.consultationTypes.isNotEmpty
                                ? '₹${doctor.consultationTypes.first.fee}'
                                : '₹0',
                        'available': doctor.isAvailableNow,
                        'distance': '${doctor.distance.toStringAsFixed(1)} km',
                        'address':
                            doctor.addresses.isNotEmpty
                                ? '${doctor.addresses.first.addressLine1}, ${doctor.addresses.first.city}'
                                : 'Address not available',
                        'category': _selectedCategory,
                        'qualification': doctor.qualification,
                        'languages': doctor.languages,
                        'specializations': doctor.specializations,
                        'consultationTypes': doctor.consultationTypes,
                        'fullAddress': doctor.addresses,
                      },
                    )
                    .toList();
          });
          // Add debug call here
          _debugDoctorsData();
        }

        print(
          'Successfully loaded ${_doctors.length} doctors for specialty: $specialty',
        );
      } catch (e) {
        print('Error fetching nearby doctors with specialty: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load doctors: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        _isApiCallInProgress = false;
      }
    } else {
      print('Location not available - cannot fetch nearby doctors');
    }
  }

  Widget _buildFeaturedDoctorsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Doctors',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Show all featured doctors
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _featuredDoctors.length,
              itemBuilder: (context, index) {
                final doctor = _featuredDoctors[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: FeaturedDoctorCard(
                    doctor: doctor,
                    onTap: () => _navigateToDoctorProfile(doctor),
                    onBookTap: () {
                      // Book appointment logic
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Doctors',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              // View toggle
              InkWell(
                onTap: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.lightGrey),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isGridView ? Icons.grid_view : Icons.view_list,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isGridView ? 'Grid' : 'List',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _filteredDoctors.isEmpty
              ? _buildEmptyState()
              : _isGridView
              ? _buildDoctorsGrid()
              : _buildDoctorsList(),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList() {
    return Column(
      children: [
        ...List.generate(_filteredDoctors.length, (index) {
          final doctor = _filteredDoctors[index];
          return Column(
            children: [
              _buildDoctorCard(doctor),
              if (index < _filteredDoctors.length - 1)
                Divider(height: 24, color: AppTheme.lightGrey.withOpacity(0.5)),
            ],
          );
        }),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildDoctorsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredDoctors.length,
      itemBuilder: (context, index) {
        final doctor = _filteredDoctors[index];
        return _buildDoctorGridCard(doctor);
      },
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return InkWell(
      onTap: () {
        _navigateToDoctorProfile(doctor);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.lightBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  doctor['profilePhoto'] != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          doctor['profilePhoto'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              color: AppTheme.primaryBlue,
                              size: 30,
                            );
                          },
                        ),
                      )
                      : Icon(
                        Icons.person,
                        color: AppTheme.primaryBlue,
                        size: 30,
                      ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['name'] ?? 'Unknown Doctor',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor['specialty'] ?? 'General Physician',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        (doctor['rating'] ?? 4.0).toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${doctor['reviewCount'] ?? 100}+ patients',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${doctor['distance'] ?? '0.0 km'}',
                        style: const TextStyle(
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
      ),
    );
  }

  Widget _buildDoctorGridCard(Map<String, dynamic> doctor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _navigateToDoctorProfile(doctor);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Doctor image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.person,
                  color: AppTheme.primaryBlue,
                  size: 40,
                ),
              ),
              const SizedBox(height: 12),
              // Doctor name
              Text(
                doctor['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              // Specialty
              Text(
                doctor['specialty'],
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    doctor['rating'].toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Experience
              Text(
                doctor['experience'],
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              // Fee
              Text(
                'Fee: ${doctor['fee']}',
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              // Book button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Book appointment logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Book'),
                ),
              ),
              const SizedBox(height: 4),
              // Availability badge
              if (doctor['available'])
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Available',
                    style: TextStyle(
                      color: AppTheme.primaryGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppTheme.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No doctors found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different specialty or check back later',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showSpecialtyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Specialty',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: _specialties.length,
                itemBuilder: (context, index) {
                  final specialty = _specialties[index];
                  return ListTile(
                    title: Text(specialty),
                    trailing:
                        _selectedSpecialty == specialty
                            ? const Icon(
                              Icons.check,
                              color: AppTheme.primaryBlue,
                            )
                            : null,
                    onTap: () {
                      setState(() {
                        _selectedSpecialty = specialty;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select City',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: _cities.length,
                itemBuilder: (context, index) {
                  final city = _cities[index];
                  return ListTile(
                    title: Text(city),
                    trailing:
                        _selectedCity == city
                            ? const Icon(
                              Icons.check,
                              color: AppTheme.primaryBlue,
                            )
                            : null,
                    onTap: () {
                      setState(() {
                        _selectedCity = city;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRatingPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Minimum Rating',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [const Text('0'), const Text('5')],
                      ),
                      Slider(
                        value: _minRating,
                        min: 0,
                        max: 5,
                        divisions: 5,
                        label: _minRating.toString(),
                        onChanged: (value) {
                          setState(() {
                            _minRating = value;
                          });
                        },
                      ),
                      Text(
                        'Selected: ${_minRating.toInt()}+ stars',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () {
                      this.setState(() {
                        // Update the parent state
                        this._minRating = _minRating;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Add this method to debug the filtering
  void _debugDoctorsData() {
    print('=== DEBUGGING DOCTORS DATA ===');
    print('Total doctors from API: ${_doctors.length}');
    print('Filtered doctors: ${_filteredDoctors.length}');
    print('Selected specialty: $_selectedSpecialty');
    print('Selected category: $_selectedCategory');
    print('Search query: $_searchQuery');

    if (_doctors.isNotEmpty) {
      print('Sample doctor data:');
      final sampleDoctor = _doctors.first;
      sampleDoctor.forEach((key, value) {
        print('  $key: $value');
      });
    }
    print('=== END DEBUG ===');
  }

  void _navigateToDoctorProfile(Map<String, dynamic> doctor) {
    // This would navigate to a doctor profile page
    // For now, just show a snackbar
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                DoctorProfileScreen(doctorId: doctor['id'], doctor: doctor),
      ),
    );

    // In a real app, you would navigate to a doctor profile page
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => DoctorProfileScreen(doctor: doctor),
    //   ),
    // );
  }
}
