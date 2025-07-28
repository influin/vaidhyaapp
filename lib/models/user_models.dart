import 'package:flutter/material.dart';

// Base user model with common properties
class User {
  final String id;
  final String name;
  final String? email;
  final String mobileNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String role;
  final bool isVerified;
  final String preferredLanguage;

  User({
    required this.id,
    required this.name,
    this.email,
    required this.mobileNumber,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.role,
    required this.isVerified,
    required this.preferredLanguage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      mobileNumber: json['mobileNumber'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
      role: json['role'] ?? 'customer',
      isVerified: json['isVerified'] ?? false,
      preferredLanguage: json['preferredLanguage'] ?? 'english',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobileNumber': mobileNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'role': role,
      'isVerified': isVerified,
      'preferredLanguage': preferredLanguage,
    };
  }
}

// Extended user profile with additional health information
class UserProfile extends User {
  final List<MedicalRecord> medicalRecords;
  final List<Medication> medications;
  final List<Vital> vitals;
  final List<FamilyMember> familyMembers;
  final List<Address> addresses;
  final List<PaymentMethod> paymentMethods;
  final UserSettings settings;

  UserProfile({
    required super.id,
    required super.name,
    super.email,
    required super.mobileNumber,
    super.profileImageUrl,
    required super.createdAt,
    required super.updatedAt,
    required super.role,
    required super.isVerified,
    required super.preferredLanguage,
    this.medicalRecords = const [],
    this.medications = const [],
    this.vitals = const [],
    this.familyMembers = const [],
    this.addresses = const [],
    this.paymentMethods = const [],
    required this.settings,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // First create the base User object
    final user = User.fromJson(json);

    // Parse lists if they exist in the JSON, otherwise use empty lists
    final medicalRecords =
        (json['medical_records'] as List?)
            ?.map((e) => MedicalRecord.fromJson(e))
            .toList() ??
        [];

    final medications =
        (json['medications'] as List?)
            ?.map((e) => Medication.fromJson(e))
            .toList() ??
        [];

    final vitals =
        (json['vitals'] as List?)?.map((e) => Vital.fromJson(e)).toList() ?? [];

    final familyMembers =
        (json['family_members'] as List?)
            ?.map((e) => FamilyMember.fromJson(e))
            .toList() ??
        [];

    final addresses =
        (json['addresses'] as List?)
            ?.map((e) => Address.fromJson(e))
            .toList() ??
        [];

    final paymentMethods =
        (json['payment_methods'] as List?)
            ?.map((e) => PaymentMethod.fromJson(e))
            .toList() ??
        [];

    // Create settings from JSON or use default
    final settings =
        json['settings'] != null
            ? UserSettings.fromJson(json['settings'])
            : UserSettings.fromJson({});

    // Return the UserProfile with all properties
    return UserProfile(
      id: user.id,
      name: user.name,
      email: user.email,
      mobileNumber: user.mobileNumber,
      profileImageUrl: user.profileImageUrl,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      role: user.role,
      isVerified: user.isVerified,
      preferredLanguage: user.preferredLanguage,
      medicalRecords: medicalRecords,
      medications: medications,
      vitals: vitals,
      familyMembers: familyMembers,
      addresses: addresses,
      paymentMethods: paymentMethods,
      settings: settings,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'medical_records': medicalRecords.map((e) => e.toJson()).toList(),
      'medications': medications.map((e) => e.toJson()).toList(),
      'vitals': vitals.map((e) => e.toJson()).toList(),
      'family_members': familyMembers.map((e) => e.toJson()).toList(),
      'addresses': addresses.map((e) => e.toJson()).toList(),
      'payment_methods': paymentMethods.map((e) => e.toJson()).toList(),
      'settings': settings.toJson(),
    });
    return json;
  }
}

class MedicalRecord {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String? fileUrl;
  final String? doctorName;
  final String? hospitalName;

  MedicalRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.fileUrl,
    this.doctorName,
    this.hospitalName,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      fileUrl: json['file_url'],
      doctorName: json['doctor_name'],
      hospitalName: json['hospital_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'file_url': fileUrl,
      'doctor_name': doctorName,
      'hospital_name': hospitalName,
    };
  }
}

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String? prescribedBy;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.prescribedBy,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      startDate: DateTime.parse(json['start_date']),
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      prescribedBy: json['prescribed_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'prescribed_by': prescribedBy,
    };
  }
}

class Vital {
  final String id;
  final String name; // e.g., Blood Pressure, Heart Rate, etc.
  final String value;
  final String unit;
  final DateTime recordedAt;

  Vital({
    required this.id,
    required this.name,
    required this.value,
    required this.unit,
    required this.recordedAt,
  });

  factory Vital.fromJson(Map<String, dynamic> json) {
    return Vital(
      id: json['id'],
      name: json['name'],
      value: json['value'],
      unit: json['unit'],
      recordedAt: DateTime.parse(json['recorded_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'unit': unit,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }
}

class FamilyMember {
  final String id;
  final String name;
  final String relationship;
  final DateTime? dateOfBirth;
  final String? phoneNumber;
  final String? bloodGroup;
  final List<String>? allergies;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relationship,
    this.dateOfBirth,
    this.phoneNumber,
    this.bloodGroup,
    this.allergies,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'],
      name: json['name'],
      relationship: json['relationship'],
      dateOfBirth:
          json['date_of_birth'] != null
              ? DateTime.parse(json['date_of_birth'])
              : null,
      phoneNumber: json['phone_number'],
      bloodGroup: json['blood_group'],
      allergies: (json['allergies'] as List?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'relationship': relationship,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'phone_number': phoneNumber,
      'blood_group': bloodGroup,
      'allergies': allergies,
    };
  }
}

class Address {
  final String id;
  final String name; // e.g., Home, Work, etc.
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;
  // New fields for Google Places API
  final String? placeId; // Google Place ID for future reference
  final double? latitude; // Latitude coordinate
  final double? longitude; // Longitude coordinate
  final String? formattedAddress; // Full formatted address from Google

  Address({
    required this.id,
    required this.name,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.isDefault = false,
    // New fields
    this.placeId,
    this.latitude,
    this.longitude,
    this.formattedAddress,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      name: json['name'],
      addressLine1: json['address_line1'],
      addressLine2: json['address_line2'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      country: json['country'],
      isDefault: json['is_default'] ?? false,
      // New fields
      placeId: json['place_id'],
      latitude:
          json['latitude'] != null
              ? double.parse(json['latitude'].toString())
              : null,
      longitude:
          json['longitude'] != null
              ? double.parse(json['longitude'].toString())
              : null,
      formattedAddress: json['formatted_address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'is_default': isDefault,
      // New fields
      'place_id': placeId,
      'latitude': latitude,
      'longitude': longitude,
      'formatted_address': formattedAddress,
    };
  }
}

class PaymentMethod {
  final String id;
  final String type; // e.g., Credit Card, UPI, etc.
  final String name; // e.g., HDFC Credit Card, PhonePe UPI, etc.
  final String? lastFourDigits;
  final String? expiryDate;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    this.lastFourDigits,
    this.expiryDate,
    this.isDefault = false,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      lastFourDigits: json['last_four_digits'],
      expiryDate: json['expiry_date'],
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'last_four_digits': lastFourDigits,
      'expiry_date': expiryDate,
      'is_default': isDefault,
    };
  }
}

class UserSettings {
  final bool notificationsEnabled;
  final String language;
  final bool darkModeEnabled;
  final bool locationTrackingEnabled;

  UserSettings({
    this.notificationsEnabled = true,
    this.language = 'English',
    this.darkModeEnabled = false,
    this.locationTrackingEnabled = true,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      notificationsEnabled: json['notifications_enabled'] ?? true,
      language: json['language'] ?? 'English',
      darkModeEnabled: json['dark_mode_enabled'] ?? false,
      locationTrackingEnabled: json['location_tracking_enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications_enabled': notificationsEnabled,
      'language': language,
      'dark_mode_enabled': darkModeEnabled,
      'location_tracking_enabled': locationTrackingEnabled,
    };
  }
}
