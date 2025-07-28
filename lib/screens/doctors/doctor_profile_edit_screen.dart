import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vaidhya_front_end/services/api_providers.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';

class DoctorProfileEditScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> userData;

  const DoctorProfileEditScreen({Key? key, required this.userData})
    : super(key: key);

  @override
  ConsumerState<DoctorProfileEditScreen> createState() =>
      _DoctorProfileEditScreenState();
}

class _DoctorProfileEditScreenState
    extends ConsumerState<DoctorProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  late TextEditingController _medicalRegController;
  late TextEditingController _yearsExpController;
  late TextEditingController _hospitalAffiliationController;

  // For qualifications and specialty tags
  List<String> _qualifications = [];
  List<String> _specialtyTags = [];

  // For new qualification and specialty
  final TextEditingController _newQualificationController =
      TextEditingController();
  final TextEditingController _newSpecialtyController = TextEditingController();

  // For profile image
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Extract user data
    final Map<String, dynamic> userDataMap =
        widget.userData['user'] != null
            ? widget.userData['user'] as Map<String, dynamic>
            : widget.userData;

    // Initialize controllers with existing data
    _medicalRegController = TextEditingController(
      text: userDataMap['medicalRegistrationNumber'] ?? '',
    );
    _yearsExpController = TextEditingController(
      text: userDataMap['yearsOfExperience']?.toString() ?? '',
    );
    _hospitalAffiliationController = TextEditingController(
      text: userDataMap['clinicHospitalAffiliation'] ?? '',
    );

    // Initialize lists
    _qualifications = List<String>.from(userDataMap['qualifications'] ?? []);
    _specialtyTags = List<String>.from(userDataMap['specialtyTags'] ?? []);

    // Add this to the class fields section
    late TextEditingController _consultationFeesController;

    // Add this in initState() after other controller initializations
    _consultationFeesController = TextEditingController(
      text: userDataMap['consultationFees']?.toString() ?? '',
    );

    // Add this in dispose() method
    _consultationFeesController.dispose();

    // Add this in the _saveProfile() method's profileData map

    // Add this in the build method where the comment "// Consultation Fees" is
    TextFormField(
      controller: _consultationFeesController,
      decoration: const InputDecoration(
        labelText: 'Consultation Fees (₹)',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your consultation fees';
        }
        if (int.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _medicalRegController.dispose();
    _yearsExpController.dispose();
    _hospitalAffiliationController.dispose();

    _newQualificationController.dispose();
    _newSpecialtyController.dispose();
    super.dispose();
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Add a qualification
  void _addQualification() {
    final qualification = _newQualificationController.text.trim();
    if (qualification.isNotEmpty) {
      setState(() {
        _qualifications.add(qualification);
        _newQualificationController.clear();
      });
    }
  }

  // Add a specialty tag
  void _addSpecialtyTag() {
    final specialty = _newSpecialtyController.text.trim();
    if (specialty.isNotEmpty) {
      setState(() {
        _specialtyTags.add(specialty);
        _newSpecialtyController.clear();
      });
    }
  }

  // Remove a qualification
  void _removeQualification(int index) {
    setState(() {
      _qualifications.removeAt(index);
    });
  }

  // Remove a specialty tag
  void _removeSpecialtyTag(int index) {
    setState(() {
      _specialtyTags.removeAt(index);
    });
  }

  // Save profile
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Prepare profile data
        final profileData = {
          'medicalRegistrationNumber': _medicalRegController.text,
          'qualifications': _qualifications,
          'yearsOfExperience': int.tryParse(_yearsExpController.text) ?? 0,
          'clinicHospitalAffiliation': _hospitalAffiliationController.text,

          'specialtyTags': _specialtyTags,
        };

        // Call the provider
        final updateDoctorProfileProvider =
            FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((
              ref,
              data,
            ) async {
              final apiService = ref.watch(apiServiceProvider);
              return apiService.updateDoctorProfile(
                data['profileData'],
                imagePath: data['imagePath'],
              );
            });

        // Refresh user profile
        ref.refresh(userProfileProvider);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract user data
    final Map<String, dynamic> userDataMap =
        widget.userData['user'] != null
            ? widget.userData['user'] as Map<String, dynamic>
            : widget.userData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Image
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[200],
                              backgroundImage:
                                  _imageFile != null
                                      ? FileImage(_imageFile!)
                                      : userDataMap['profileImageUrl'] != null
                                      ? NetworkImage(
                                        userDataMap['profileImageUrl'],
                                      )
                                      : null,
                              child:
                                  (_imageFile == null &&
                                          userDataMap['profileImageUrl'] ==
                                              null)
                                      ? Text(
                                        userDataMap['name']?.substring(0, 1) ??
                                            'D',
                                        style: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryBlue,
                                        ),
                                      )
                                      : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor: AppTheme.primaryBlue,
                                radius: 20,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: _pickImage,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Medical Registration Number
                      TextFormField(
                        controller: _medicalRegController,
                        decoration: const InputDecoration(
                          labelText: 'Medical Registration Number',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your medical registration number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Qualifications
                      const Text(
                        'Qualifications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                          _qualifications.length,
                          (index) => Chip(
                            label: Text(_qualifications[index]),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () => _removeQualification(index),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _newQualificationController,
                              decoration: const InputDecoration(
                                labelText: 'Add Qualification',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addQualification,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Years of Experience
                      TextFormField(
                        controller: _yearsExpController,
                        decoration: const InputDecoration(
                          labelText: 'Years of Experience',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your years of experience';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Hospital Affiliation
                      TextFormField(
                        controller: _hospitalAffiliationController,
                        decoration: const InputDecoration(
                          labelText: 'Clinic/Hospital Affiliation',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Consultation Fees

                      // Specialty Tags
                      const Text(
                        'Specialty Tags',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                          _specialtyTags.length,
                          (index) => Chip(
                            label: Text(_specialtyTags[index]),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () => _removeSpecialtyTag(index),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _newSpecialtyController,
                              decoration: const InputDecoration(
                                labelText: 'Add Specialty',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addSpecialtyTag,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Save Profile',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
