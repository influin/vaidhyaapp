import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vaidhya_front_end/services/api_providers.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';

class HospitalProfileScreen extends ConsumerStatefulWidget {
  final String hospitalId;

  const HospitalProfileScreen({Key? key, required this.hospitalId})
    : super(key: key);

  @override
  ConsumerState<HospitalProfileScreen> createState() =>
      _HospitalProfileScreenState();
}

class _HospitalProfileScreenState extends ConsumerState<HospitalProfileScreen> {
  Map<String, dynamic>? hospitalProfile;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadHospitalProfile();
  }

  Future<void> _loadHospitalProfile() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final apiService = ref.read(apiServiceProvider);
      final profile = await apiService.getHospitalProfileById(
        widget.hospitalId,
      );

      setState(() {
        hospitalProfile = profile;
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
    if (hospitalProfile == null) return;

    final lat = hospitalProfile!['latitude'];
    final lng = hospitalProfile!['longitude'];
    final name = hospitalProfile!['name'];

    // Try Apple Maps first (iOS), then Google Maps
    final appleMapsUrl = 'http://maps.apple.com/?daddr=$lat,$lng&dirflg=d';
    final googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=${hospitalProfile!['name']}';

    try {
      if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
        await launchUrl(Uri.parse(appleMapsUrl));
      } else if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl));
      } else {
        throw 'Could not launch maps';
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open maps: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Hospital Profile', showBackButton: true),
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
                    Text('Error loading hospital profile'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadHospitalProfile,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHospitalHeader(),
                    _buildHospitalImages(),
                    _buildBasicInfo(),
                    _buildFacilitiesAndServices(),
                    _buildSpecialties(),
                    _buildInsuranceInfo(),
                    _buildContactInfo(),
                    _buildDirectionsButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
    );
  }

  Widget _buildHospitalHeader() {
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
          // Hospital Profile Image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.white, width: 3),
              image:
                  hospitalProfile!['profile_image_url'] != null
                      ? DecorationImage(
                        image: NetworkImage(
                          hospitalProfile!['profile_image_url'],
                        ),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                hospitalProfile!['profile_image_url'] == null
                    ? Icon(Icons.local_hospital, size: 50, color: Colors.white)
                    : null,
          ),
          const SizedBox(height: 16),

          // Hospital Name
          Text(
            hospitalProfile!['name'] ?? 'Unknown Hospital',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Hospital Type
          Text(
            hospitalProfile!['type'] ?? 'Hospital',
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
                '${hospitalProfile!['rating'] ?? 0.0}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(width: 8),
              Text(
                '(${hospitalProfile!['review_count'] ?? 0} reviews)',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 24x7 Status
          if (hospitalProfile!['is_open_24x7'] == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '24x7 Open',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHospitalImages() {
    final images = hospitalProfile!['images'] as List<dynamic>? ?? [];
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
            'Hospital Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Bed Count and Doctor Count
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.bed,
                  title: 'Beds',
                  value: '${hospitalProfile!['bed_count'] ?? 0}',
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.person,
                  title: 'Doctors',
                  value: '${hospitalProfile!['doctor_count'] ?? 0}',
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Address
          _buildInfoRow(
            icon: Icons.location_on,
            title: 'Address',
            value:
                '${hospitalProfile!['address'] ?? ''}, ${hospitalProfile!['city'] ?? ''}, ${hospitalProfile!['state'] ?? ''} ${hospitalProfile!['postal_code'] ?? ''}',
          ),
          const SizedBox(height: 12),

          // Website
          if (hospitalProfile!['website'] != null)
            _buildInfoRow(
              icon: Icons.language,
              title: 'Website',
              value: hospitalProfile!['website'],
              isLink: true,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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

  Widget _buildFacilitiesAndServices() {
    final facilities = hospitalProfile!['facilities'] as List<dynamic>? ?? [];
    final services = hospitalProfile!['services'] as List<dynamic>? ?? [];

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
          // Facilities
          if (facilities.isNotEmpty) ...[
            const Text(
              'Facilities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  facilities.map((facility) {
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
                        facility.toString(),
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Services
          if (services.isNotEmpty) ...[
            const Text(
              'Services',
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
                    if (service['minPrice'] != null &&
                        service['maxPrice'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${service['currency'] ?? 'INR'} ${service['minPrice']} - ${service['maxPrice']}',
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  IconData _getServiceIcon(String? iconCode) {
    switch (iconCode) {
      case 'heart':
        return Icons.favorite;
      case 'brain':
        return Icons.psychology;
      case 'bone':
        return Icons.accessibility;
      default:
        return Icons.medical_services;
    }
  }

  Widget _buildSpecialties() {
    final specialties = hospitalProfile!['specialties'] as List<dynamic>? ?? [];
    if (specialties.isEmpty) return const SizedBox();

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
            'Specialties',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                specialties.map((specialty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      specialty.toString(),
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceInfo() {
    final insurance =
        hospitalProfile!['insurance_accepted'] as List<dynamic>? ?? [];
    if (insurance.isEmpty) return const SizedBox();

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
            'Insurance Accepted',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...insurance.map((ins) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(ins.toString()),
                ],
              ),
            );
          }).toList(),
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

          if (hospitalProfile!['phone_number'] != null)
            _buildContactRow(
              icon: Icons.phone,
              title: 'Phone',
              value: hospitalProfile!['phone_number'],
              onTap:
                  () => launchUrl(
                    Uri.parse('tel:${hospitalProfile!['phone_number']}'),
                  ),
            ),

          if (hospitalProfile!['email'] != null)
            _buildContactRow(
              icon: Icons.email,
              title: 'Email',
              value: hospitalProfile!['email'],
              onTap:
                  () => launchUrl(
                    Uri.parse('mailto:${hospitalProfile!['email']}'),
                  ),
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
}
