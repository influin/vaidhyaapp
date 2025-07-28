import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/widgets/google_places_address_input.dart';
import 'package:vaidhya_front_end/services/location_service.dart';

class LocationSelector extends StatelessWidget {
  final String? currentLocation;
  final VoidCallback? onLocationTap;
  final Function(PlaceDetails)? onPlaceSelected;
  final Function(String)? onCurrentLocationSelected;

  const LocationSelector({
    Key? key,
    this.currentLocation,
    this.onLocationTap,
    this.onPlaceSelected,
    this.onCurrentLocationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showAddressPicker(context),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppTheme.white, size: 18),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Location',
                  style: TextStyle(color: AppTheme.lightGrey, fontSize: 12),
                ),
                Text(
                  currentLocation ?? 'Select location',
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down,
            color: AppTheme.white,
            size: 18,
          ),
        ],
      ),
    );
  }

  void _showAddressPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final TextEditingController controller = TextEditingController();
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              const Text(
                'Select Location',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Current Location Button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  onPressed: () => _getCurrentLocation(context),
                  icon: const Icon(
                    Icons.my_location,
                    color: AppTheme.primaryBlue,
                  ),
                  label: const Text(
                    'Use Current Location',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Divider with "OR"
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 16),
              
              // Search Input
              GooglePlacesAddressInput(
                controller: controller,
                hint: 'Search for a location',
                onPlaceSelected: (PlaceDetails details) {
                  // Call the callback to update the parent widget
                  if (onPlaceSelected != null) {
                    onPlaceSelected!(details);
                  }
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _getCurrentLocation(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final position = await LocationService.getCurrentPosition();
      
      // Hide loading indicator
      Navigator.pop(context);
      
      if (position != null) {
        final address = await LocationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        if (address != null) {
          // Call the callback to update the parent widget
          if (onCurrentLocationSelected != null) {
            onCurrentLocationSelected!(address);
          }
          Navigator.pop(context);
        } else {
          _showErrorSnackBar(context, 'Unable to get address for current location');
        }
      } else {
        _showErrorSnackBar(context, 'Unable to get current location. Please check location permissions.');
      }
    } catch (e) {
      // Hide loading indicator
      Navigator.pop(context);
      _showErrorSnackBar(context, 'Error getting current location: $e');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
