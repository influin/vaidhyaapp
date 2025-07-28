import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidhya_front_end/services/api_providers.dart';
import '../models/vendor_models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/google_places_address_input.dart';
import '../services/location_service.dart';
import 'vendor_profile_screen.dart';

class VendorDiscoveryScreen extends ConsumerStatefulWidget {
  final String? serviceType;
  final double? latitude;
  final double? longitude;
  final String? initialLocation;

  const VendorDiscoveryScreen({
    Key? key,
    this.serviceType,
    this.latitude,
    this.longitude,
    this.initialLocation,
  }) : super(key: key);

  @override
  ConsumerState<VendorDiscoveryScreen> createState() =>
      _VendorDiscoveryScreenState();
}

class _VendorDiscoveryScreenState extends ConsumerState<VendorDiscoveryScreen> {
  String _selectedServiceType = 'All Types';
  String _searchQuery = '';
  bool _isLoading = false;
  List<Vendor> _vendors = [];
  String? _selectedCity;
  double? _currentLatitude;
  double? _currentLongitude;
  double? _selectedLatitude;
  double? _selectedLongitude;
  int _currentPage = 1;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  final List<String> _serviceTypes = [
    'All Types',
    'pharmacy',
    'medical supplies',
    'ayurvedic',
    'health & fitness',
    'home nurses',
    'diagnostic',
    'medical equipment',
    'yoga trainer',
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _scrollController.addListener(_onScroll);
    if (widget.serviceType != null) {
      _selectedServiceType = widget.serviceType!;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasMoreData && !_isLoading) {
        _loadMoreVendors();
      }
    }
  }

  Future<void> _initializeLocation() async {
    try {
      if (widget.latitude != null && widget.longitude != null) {
        _selectedLatitude = widget.latitude;
        _selectedLongitude = widget.longitude;
        _selectedCity = widget.initialLocation ?? 'Selected Location';
      } else {
        final savedLocation = await LocationService.loadSelectedLocation();
        if (savedLocation != null) {
          _selectedLatitude = savedLocation['latitude'];
          _selectedLongitude = savedLocation['longitude'];
          _selectedCity = savedLocation['address'];
        } else {
          final currentLocation = await LocationService.getCurrentLocation();
          if (currentLocation != null) {
            _currentLatitude = currentLocation.latitude;
            _currentLongitude = currentLocation.longitude;
            _selectedLatitude = _currentLatitude;
            _selectedLongitude = _currentLongitude;
            _selectedCity = 'Current Location';
          } else {
            // Fallback to default location if getCurrentLocation fails
            _selectedLatitude = 12.9716; // Default to Bangalore
            _selectedLongitude = 77.5946;
            _selectedCity = 'Bangalore, Karnataka';
          }
        }
      }
      _fetchNearbyVendors();
    } catch (e) {
      print('Error initializing location: $e');
      _selectedLatitude = 12.9716; // Default to Bangalore
      _selectedLongitude = 77.5946;
      _selectedCity = 'Bangalore, Karnataka';
      _fetchNearbyVendors();
    }
  }

  Future<void> _handlePlaceSelected(PlaceDetails placeDetails) async {
    setState(() {
      _selectedCity = placeDetails.formattedAddress;
      _selectedLatitude = placeDetails.lat;
      _selectedLongitude = placeDetails.lng;
      _vendors.clear();
      _currentPage = 1;
      _hasMoreData = true;
    });

    try {
      await LocationService.saveSelectedLocation(
        address: placeDetails.formattedAddress,
        latitude: placeDetails.lat,
        longitude: placeDetails.lng,
      );
    } catch (e) {
      print('Error saving location: $e');
    }

    _fetchNearbyVendors();
  }

  Future<void> _fetchNearbyVendors() async {
    if (_selectedLatitude == null || _selectedLongitude == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.getNearbyVendors(
        latitude: _selectedLatitude!,
        longitude: _selectedLongitude!,
        serviceType:
            _selectedServiceType == 'All Types' ? null : _selectedServiceType,
        page: _currentPage,
      );

      setState(() {
        if (_currentPage == 1) {
          _vendors = response.data.vendors;
        } else {
          _vendors.addAll(response.data.vendors);
        }
        _hasMoreData = response.data.pagination.hasNext;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading vendors: $e')));
    }
  }

  Future<void> _loadMoreVendors() async {
    _currentPage++;
    await _fetchNearbyVendors();
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Find Vendors',
        showBackButton: true,
        showLocationSelector: true,
        currentLocation: _selectedCity,
        onPlaceSelected: _handlePlaceSelected,
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          _buildServiceTypeChips(),
          Expanded(
            child:
                _isLoading && _vendors.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _vendors.isEmpty
                    ? _buildEmptyState()
                    : _buildVendorsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search vendors...',
          prefixIcon: Icon(Icons.search, color: AppTheme.primaryBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppTheme.lightGrey.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildServiceTypeChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _serviceTypes.length,
        itemBuilder: (context, index) {
          final serviceType = _serviceTypes[index];
          final isSelected = _selectedServiceType == serviceType;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                _capitalizeFirst(serviceType),
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.primaryBlue,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedServiceType = serviceType;
                  _vendors.clear();
                  _currentPage = 1;
                  _hasMoreData = true;
                });
                _fetchNearbyVendors();
              },
              backgroundColor: Colors.white,
              selectedColor: AppTheme.primaryBlue,
              checkmarkColor: Colors.white,
              side: BorderSide(color: AppTheme.primaryBlue),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVendorsList() {
    final filteredVendors =
        _vendors.where((vendor) {
          if (_searchQuery.isEmpty) return true;
          return vendor.name.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              vendor.serviceTypes.any(
                (type) =>
                    type.toLowerCase().contains(_searchQuery.toLowerCase()),
              );
        }).toList();

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: filteredVendors.length + (_hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == filteredVendors.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return _buildVendorCard(filteredVendors[index]);
      },
    );
  }

  Widget _buildVendorCard(Vendor vendor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VendorProfileScreen(vendorId: vendor.id),
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
                      _getServiceIcon(
                        vendor.serviceTypes.isNotEmpty
                            ? vendor.serviceTypes.first
                            : '',
                      ),
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
                          vendor.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vendor.serviceTypes.join(', '),
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${vendor.rating}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${vendor.reviewCount} reviews)',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${vendor.distance.toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              vendor.isAvailableNow
                                  ? AppTheme.primaryGreen.withOpacity(0.1)
                                  : AppTheme.textPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          vendor.isAvailableNow ? 'Available' : 'Closed',
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                vendor.isAvailableNow
                                    ? AppTheme.primaryGreen
                                    : AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${vendor.address}, ${vendor.city}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (vendor.services.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Services: ${vendor.services.take(2).map((s) => s.name).join(', ')}${vendor.services.length > 2 ? '...' : ''}',
                  style: TextStyle(fontSize: 12, color: AppTheme.primaryBlue),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'pharmacy':
      case 'medical store':
        return Icons.local_pharmacy;
      case 'ayurvedic':
      case 'ayurvedic store':
        return Icons.spa;
      case 'health & fitness':
        return Icons.fitness_center;
      case 'home nurses':
      case 'caretakers':
        return Icons.medical_services;
      case 'diagnostic':
      case 'diagnostic centre':
        return Icons.biotech;
      case 'medical equipment':
      case 'medical equipments':
        return Icons.wheelchair_pickup;
      case 'yoga trainer':
        return Icons.self_improvement;
      default:
        return Icons.store;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No vendors found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
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
}
