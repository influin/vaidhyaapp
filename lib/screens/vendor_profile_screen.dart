import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vaidhya_front_end/services/api_providers.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';

class VendorProfileScreen extends ConsumerStatefulWidget {
  final String vendorId;

  const VendorProfileScreen({Key? key, required this.vendorId})
    : super(key: key);

  @override
  ConsumerState<VendorProfileScreen> createState() =>
      _VendorProfileScreenState();
}

class _VendorProfileScreenState extends ConsumerState<VendorProfileScreen> {
  Map<String, dynamic>? vendorProfile;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadVendorProfile();
  }

  Future<void> _loadVendorProfile() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final apiService = ref.read(apiServiceProvider);
      final profile = await apiService.getVendorProfileById(widget.vendorId);

      setState(() {
        vendorProfile = profile;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _openDirections() async {
    if (vendorProfile == null) return;

    final lat = vendorProfile!['latitude'];
    final lng = vendorProfile!['longitude'];

    // Create different URL schemes
    final urls = [
      'comgooglemaps://?daddr=$lat,$lng&directionsmode=driving', // Google Maps app
      'maps://maps.apple.com/?daddr=$lat,$lng&dirflg=d', // Apple Maps
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng', // Web fallback
    ];

    bool launched = false;

    for (String url in urls) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          launched = true;
          break;
        }
      } catch (e) {
        continue;
      }
    }

    if (!launched) {
      // Show a dialog with the address for manual navigation
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Navigation'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Please navigate to:'),
                  const SizedBox(height: 8),
                  Text(
                    '${vendorProfile!['address'] ?? ''}, ${vendorProfile!['city'] ?? ''}, ${vendorProfile!['state'] ?? ''} ${vendorProfile!['postal_code'] ?? ''}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Coordinates: $lat, $lng'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Vendor Profile', showBackButton: true),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error loading vendor profile'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadVendorProfile,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVendorHeader(),
                    _buildVendorImages(),
                    _buildBasicInfo(),
                    _buildServices(),
                    _buildAvailableSlots(),
                    _buildContactInfo(),
                    _buildDirectionsButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
    );
  }

  Widget _buildVendorHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.withOpacity(0.8)],
        ),
      ),
      child: Column(
        children: [
          // Vendor Profile Image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.white, width: 3),
              color: Colors.white,
            ),
            child: Icon(
              _getServiceIcon(
                vendorProfile!['service_types']?.isNotEmpty == true
                    ? vendorProfile!['service_types'][0]
                    : '',
              ),
              size: 50,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),

          // Vendor Name
          Text(
            vendorProfile!['name'] ?? 'Unknown Vendor',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Service Types
          Text(
            (vendorProfile!['service_types'] as List<dynamic>?)?.join(', ') ??
                'Services',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 12),

          // Rating and Reviews
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                '${vendorProfile!['rating'] ?? 0.0}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(width: 8),
              Text(
                '(${vendorProfile!['review_count'] ?? 0} reviews)',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Availability Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  vendorProfile!['is_available_now'] == true
                      ? Colors.green
                      : Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              vendorProfile!['is_available_now'] == true
                  ? 'Available Now'
                  : 'Currently Closed',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorImages() {
    final images = vendorProfile!['images'] as List<dynamic>? ?? [];
    if (images.isEmpty) return const SizedBox();

    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Container(
            width: 300,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(images[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
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
          const Text(
            'Vendor Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Distance
          _buildInfoRow(
            icon: Icons.location_on,
            title: 'Distance',
            value: '${vendorProfile!['distance'] ?? 0} km away',
          ),
          const SizedBox(height: 12),

          // Address
          _buildInfoRow(
            icon: Icons.home,
            title: 'Address',
            value:
                '${vendorProfile!['address'] ?? ''}, ${vendorProfile!['city'] ?? ''}, ${vendorProfile!['state'] ?? ''} ${vendorProfile!['postal_code'] ?? ''}',
          ),
          const SizedBox(height: 12),

          // Website
          if (vendorProfile!['website'] != null)
            _buildInfoRow(
              icon: Icons.language,
              title: 'Website',
              value: vendorProfile!['website'],
              isLink: true,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    bool isLink = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: isLink ? () => launchUrl(Uri.parse(value)) : null,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: isLink ? AppTheme.primaryBlue : Colors.black87,
                    decoration: isLink ? TextDecoration.underline : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServices() {
    final services = vendorProfile!['services'] as List<dynamic>? ?? [];
    if (services.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(16),
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
          const Text(
            'Services Offered',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...services.map((service) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getServiceIcon(service['iconCode']),
                        color: AppTheme.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          service['name'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (service['description'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      service['description'],
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${service['currency'] ?? 'INR'} ${service['price'] ?? 0}',
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${service['durationMinutes'] ?? 0} mins',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAvailableSlots() {
    final slots = vendorProfile!['available_slots'] as List<dynamic>? ?? [];
    if (slots.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(16),
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
          const Text(
            'Available Time Slots',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                slots.map((slot) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      slot.toString(),
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
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
          const Text(
            'Contact Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (vendorProfile!['phone_number'] != null)
            _buildContactRow(
              icon: Icons.phone,
              title: 'Phone',
              value: vendorProfile!['phone_number'],
              onTap:
                  () => launchUrl(
                    Uri.parse('tel:${vendorProfile!['phone_number']}'),
                  ),
            ),

          if (vendorProfile!['email'] != null)
            _buildContactRow(
              icon: Icons.email,
              title: 'Email',
              value: vendorProfile!['email'],
              onTap:
                  () =>
                      launchUrl(Uri.parse('mailto:${vendorProfile!['email']}')),
            ),
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryBlue, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          onTap != null ? AppTheme.primaryBlue : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionsButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _openDirections,
        icon: const Icon(Icons.directions),
        label: const Text('Get Directions'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  IconData _getServiceIcon(String? iconCode) {
    switch (iconCode?.toLowerCase()) {
      case 'medicine':
      case 'pharmacy':
        return Icons.local_pharmacy;
      case 'health':
      case 'medical':
        return Icons.medical_services;
      case 'ayurvedic':
        return Icons.spa;
      case 'fitness':
        return Icons.fitness_center;
      case 'diagnostic':
        return Icons.biotech;
      case 'equipment':
        return Icons.wheelchair_pickup;
      case 'yoga':
        return Icons.self_improvement;
      default:
        return Icons.store;
    }
  }
}
