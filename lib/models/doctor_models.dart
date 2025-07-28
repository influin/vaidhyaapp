import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/models/service_models.dart';

class DoctorCategory {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  final Color? color;

  DoctorCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    this.color,
  });

  factory DoctorCategory.fromJson(Map<String, dynamic> json) {
    return DoctorCategory(
      id: json['id'],
      name: json['name'],
      icon: IconData(json['icon_code'], fontFamily: 'MaterialIcons'),
      description: json['description'],
      color: json['color'] != null ? Color(json['color']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_code': icon.codePoint,
      'description': description,
      'color': color?.value,
    };
  }
}

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String? qualification;
  final double rating;
  final int reviewCount;
  final String? profileImageUrl;
  final String? about;
  final int experienceYears;
  final List<String> languages;
  final List<Clinic> clinics;
  final List<ConsultationType> consultationTypes;
  final List<String> specializations;
  final List<String> services;
  final List<Education> education;
  final List<Experience> experience;
  final List<Award> awards;
  final List<TimeSlot> availableSlots;
  final bool isAvailableNow;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    this.qualification,
    required this.rating,
    required this.reviewCount,
    this.profileImageUrl,
    this.about,
    required this.experienceYears,
    required this.languages,
    required this.clinics,
    required this.consultationTypes,
    required this.specializations,
    required this.services,
    required this.education,
    required this.experience,
    required this.awards,
    required this.availableSlots,
    this.isAvailableNow = false,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'],
      specialty: json['specialty'],
      qualification: json['qualification'],
      rating: json['rating'].toDouble(),
      reviewCount: json['review_count'],
      profileImageUrl: json['profile_image_url'],
      about: json['about'],
      experienceYears: json['experience_years'],
      languages: (json['languages'] as List).cast<String>(),
      clinics:
          (json['clinics'] as List).map((e) => Clinic.fromJson(e)).toList(),
      consultationTypes:
          (json['consultation_types'] as List)
              .map((e) => ConsultationType.fromJson(e))
              .toList(),
      specializations: (json['specializations'] as List).cast<String>(),
      services: (json['services'] as List).cast<String>(),
      education:
          (json['education'] as List)
              .map((e) => Education.fromJson(e))
              .toList(),
      experience:
          (json['experience'] as List)
              .map((e) => Experience.fromJson(e))
              .toList(),
      awards: (json['awards'] as List).map((e) => Award.fromJson(e)).toList(),
      availableSlots:
          (json['available_slots'] as List)
              .map((e) => TimeSlot.fromJson(e))
              .toList(),
      isAvailableNow: json['is_available_now'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'qualification': qualification,
      'rating': rating,
      'review_count': reviewCount,
      'profile_image_url': profileImageUrl,
      'about': about,
      'experience_years': experienceYears,
      'languages': languages,
      'clinics': clinics.map((e) => e.toJson()).toList(),
      'consultation_types': consultationTypes.map((e) => e.toJson()).toList(),
      'specializations': specializations,
      'services': services,
      'education': education.map((e) => e.toJson()).toList(),
      'experience': experience.map((e) => e.toJson()).toList(),
      'awards': awards.map((e) => e.toJson()).toList(),
      'available_slots': availableSlots.map((e) => e.toJson()).toList(),
      'is_available_now': isAvailableNow,
    };
  }
}

class Clinic {
  final String id;
  final String name;
  final String address;
  final String? city;
  final String? state;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String? phoneNumber;
  final List<String>? images;
  final List<TimeSlot>? availableSlots;

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    this.city,
    this.state,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.images,
    this.availableSlots,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      phoneNumber: json['phone_number'],
      images: (json['images'] as List?)?.cast<String>(),
      availableSlots:
          (json['available_slots'] as List?)
              ?.map((e) => TimeSlot.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'phone_number': phoneNumber,
      'images': images,
      'available_slots': availableSlots?.map((e) => e.toJson()).toList(),
    };
  }
}

class ConsultationType {
  final String id;
  final String type; // e.g., Video, In-person, Chat
  final double fee;
  final String? currency;
  final int? durationMinutes;
  final IconData? icon;

  ConsultationType({
    required this.id,
    required this.type,
    required this.fee,
    this.currency,
    this.durationMinutes,
    this.icon,
  });

  factory ConsultationType.fromJson(Map<String, dynamic> json) {
    return ConsultationType(
      id: json['id'],
      type: json['type'],
      fee: json['fee'].toDouble(),
      currency: json['currency'],
      durationMinutes: json['duration_minutes'],
      icon:
          json['icon_code'] != null
              ? IconData(json['icon_code'], fontFamily: 'MaterialIcons')
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'fee': fee,
      'currency': currency,
      'duration_minutes': durationMinutes,
      'icon_code': icon?.codePoint,
    };
  }
}

class Education {
  final String degree;
  final String institution;
  final String? year;

  Education({required this.degree, required this.institution, this.year});

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      degree: json['degree'],
      institution: json['institution'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'degree': degree, 'institution': institution, 'year': year};
  }
}

class Experience {
  final String position;
  final String organization;
  final String? startYear;
  final String? endYear;
  final String? description;

  Experience({
    required this.position,
    required this.organization,
    this.startYear,
    this.endYear,
    this.description,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      position: json['position'],
      organization: json['organization'],
      startYear: json['start_year'],
      endYear: json['end_year'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'organization': organization,
      'start_year': startYear,
      'end_year': endYear,
      'description': description,
    };
  }
}

class Award {
  final String title;
  final String? organization;
  final String? year;

  Award({required this.title, this.organization, this.year});

  factory Award.fromJson(Map<String, dynamic> json) {
    return Award(
      title: json['title'],
      organization: json['organization'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'organization': organization, 'year': year};
  }
}

class TimeSlot {
  final String id;
  final DateTime dateTime;
  final bool isAvailable;

  TimeSlot({required this.id, required this.dateTime, this.isAvailable = true});

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'],
      dateTime: DateTime.parse(json['date_time']),
      isAvailable: json['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date_time': dateTime.toIso8601String(),
      'is_available': isAvailable,
    };
  }
}

// Add these new classes at the end of the file

// Add this new class before NearbyDoctor
class NearbyDoctorService {
  final String id;
  final String serviceType;
  final double price;
  final bool isCommissionInclusive;
  final double commissionPercentage;
  final String currency;
  final int durationMinutes;
  final bool isActive;
  final DateTime createdAt;
  final String serviceId;

  NearbyDoctorService({
    required this.id,
    required this.serviceType,
    required this.price,
    required this.isCommissionInclusive,
    required this.commissionPercentage,
    required this.currency,
    required this.durationMinutes,
    required this.isActive,
    required this.createdAt,
    required this.serviceId,
  });

  factory NearbyDoctorService.fromJson(Map<String, dynamic> json) {
    return NearbyDoctorService(
      id: json['id'] ?? '',
      serviceType: json['serviceType'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      isCommissionInclusive: json['isCommissionInclusive'] ?? false,
      commissionPercentage: (json['commissionPercentage'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'INR',
      durationMinutes: json['durationMinutes'] ?? 0,
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      serviceId: json['_id'] ?? '',
    );
  }
}

// Doctor Address Model
class DoctorAddress {
  final String name;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final double latitude;
  final double longitude;
  final String placeId;
  final bool isDefault;
  final String id;

  DoctorAddress({
    required this.name,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.placeId,
    required this.isDefault,
    required this.id,
  });

  factory DoctorAddress.fromJson(Map<String, dynamic> json) {
    return DoctorAddress(
      name: json['name'] ?? '',
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postalCode'] ?? '',
      country: json['country'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      placeId: json['placeId'] ?? '',
      isDefault: json['isDefault'] ?? false,
      id: json['_id'] ?? '',
    );
  }
}

// Payment Method Model
class PaymentMethod {
  final String id;
  final String type;
  final String name;
  final String lastFourDigits;
  final String? expiryDate;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    required this.lastFourDigits,
    this.expiryDate,
    required this.isDefault,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      lastFourDigits: json['last_four_digits'] ?? '',
      expiryDate: json['expiry_date'],
      isDefault: json['is_default'] ?? false,
    );
  }
}

// Doctor Settings Model
class DoctorSettings {
  final bool notificationsEnabled;
  final String language;
  final bool darkModeEnabled;
  final bool locationTrackingEnabled;

  DoctorSettings({
    required this.notificationsEnabled,
    required this.language,
    required this.darkModeEnabled,
    required this.locationTrackingEnabled,
  });

  factory DoctorSettings.fromJson(Map<String, dynamic> json) {
    return DoctorSettings(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      language: json['language'] ?? 'English',
      darkModeEnabled: json['darkModeEnabled'] ?? false,
      locationTrackingEnabled: json['locationTrackingEnabled'] ?? true,
    );
  }
}

// Time Slot for Availability
class AvailabilitySlot {
  final String startTime;
  final String endTime;
  final bool isBooked;
  final String id;
  final int? duration;
  final List<String>? consultationTypes;

  AvailabilitySlot({
    required this.startTime,
    required this.endTime,
    required this.isBooked,
    required this.id,
    this.duration,
    this.consultationTypes,
  });

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlot(
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      isBooked: json['isBooked'] ?? false,
      id: json['_id'] ?? json['id'] ?? '',
      duration: json['duration'],
      consultationTypes: json['consultationTypes'] != null 
          ? List<String>.from(json['consultationTypes']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'isBooked': isBooked,
      '_id': id,
      'duration': duration,
      'consultationTypes': consultationTypes,
    };
  }
}

// Working Day Model
class WorkingDay {
  final String day;
  final bool isAvailable;
  final List<AvailabilitySlot> slots;
  final String id;

  WorkingDay({
    required this.day,
    required this.isAvailable,
    required this.slots,
    required this.id,
  });

  factory WorkingDay.fromJson(Map<String, dynamic> json) {
    return WorkingDay(
      day: json['day'] ?? '',
      isAvailable: json['isAvailable'] ?? false,
      slots:
          (json['slots'] as List<dynamic>? ?? [])
              .map((e) => AvailabilitySlot.fromJson(e))
              .toList(),
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'isAvailable': isAvailable,
      'slots': slots.map((slot) => slot.toJson()).toList(),
      '_id': id,
    };
  }
}

// Doctor Availability Model
class DoctorAvailability {
  final List<dynamic> unavailablePeriods;
  final List<WorkingDay> workingDays;

  DoctorAvailability({
    required this.unavailablePeriods,
    required this.workingDays,
  });

  factory DoctorAvailability.fromJson(Map<String, dynamic> json) {
    return DoctorAvailability(
      unavailablePeriods: json['unavailablePeriods'] ?? [],
      workingDays:
          (json['workingDays'] as List<dynamic>? ?? [])
              .map((e) => WorkingDay.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unavailablePeriods': unavailablePeriods,
      'workingDays': workingDays.map((day) => day.toJson()).toList(),
    };
  }
}

// Complete Doctor Profile Model
class DoctorProfile {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userType;
  final String specialty;
  final String qualification;
  final double rating;
  final int reviewCount;
  final List<String> languages;
  final List<String> clinics;
  final List<String> consultationTypes;
  final List<String> specializations;
  final List<DoctorService> services;
  final List<String> education;
  final List<String> experience;
  final List<String> awards;
  final int availableSlots;
  final bool isAvailableNow;
  final List<DoctorAddress> addresses;
  final List<PaymentMethod> paymentMethods;
  final DoctorSettings settings;
  final DoctorAvailability availability;

  DoctorProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.userType,
    required this.specialty,
    required this.qualification,
    required this.rating,
    required this.reviewCount,
    required this.languages,
    required this.clinics,
    required this.consultationTypes,
    required this.specializations,
    required this.services,
    required this.education,
    required this.experience,
    required this.awards,
    required this.availableSlots,
    required this.isAvailableNow,
    required this.addresses,
    required this.paymentMethods,
    required this.settings,
    required this.availability,
  });

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      userType: json['user_type'] ?? '',
      specialty: json['specialty'] ?? '',
      qualification: json['qualification'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      languages: List<String>.from(json['languages'] ?? []),
      clinics: List<String>.from(json['clinics'] ?? []),
      consultationTypes: List<String>.from(json['consultation_types'] ?? []),
      specializations: List<String>.from(json['specializations'] ?? []),
      services:
          (json['services'] as List<dynamic>? ?? [])
              .map((e) => DoctorService.fromJson(e))
              .toList(),
      education: List<String>.from(json['education'] ?? []),
      experience: List<String>.from(json['experience'] ?? []),
      awards: List<String>.from(json['awards'] ?? []),
      availableSlots: json['available_slots'] ?? 0,
      isAvailableNow: json['is_available_now'] ?? false,
      addresses:
          (json['addresses'] as List<dynamic>? ?? [])
              .map((e) => DoctorAddress.fromJson(e))
              .toList(),
      paymentMethods:
          (json['payment_methods'] as List<dynamic>? ?? [])
              .map((e) => PaymentMethod.fromJson(e))
              .toList(),
      settings: DoctorSettings.fromJson(json['settings'] ?? {}),
      availability: DoctorAvailability.fromJson(json['availability'] ?? {}),
    );
  }
}

// Update the NearbyDoctorAddress class to match the actual API response
class NearbyDoctorAddress {
  final String name;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final double latitude;
  final double longitude;
  final String placeId;
  final bool isDefault;
  final String id;

  NearbyDoctorAddress({
    required this.name,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.placeId,
    required this.isDefault,
    required this.id,
  });

  factory NearbyDoctorAddress.fromJson(Map<String, dynamic> json) {
    return NearbyDoctorAddress(
      name: json['name'] ?? '',
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postalCode'] ?? '',
      country: json['country'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      placeId: json['placeId'] ?? '',
      isDefault: json['isDefault'] ?? false,
      id: json['_id'] ?? '',
    );
  }
}

// Update the NearbyDoctorConsultationType class
class NearbyDoctorConsultationType {
  final String type;
  final double fee;
  final int duration;

  NearbyDoctorConsultationType({
    required this.type,
    required this.fee,
    required this.duration,
  });

  factory NearbyDoctorConsultationType.fromJson(Map<String, dynamic> json) {
    return NearbyDoctorConsultationType(
      type: json['type'] ?? '',
      fee: (json['fee'] ?? 0.0).toDouble(),
      duration: json['duration'] ?? 0,
    );
  }
}

// Update the NearbyDoctor class to match the actual API response
class NearbyDoctor {
  final String id;
  final String name;
  final String email;
  final String specialty;
  final String phoneNumber;
  final List<String> languages;
  final List<String> specializations;
  final List<String> qualification;
  final double rating;
  final int reviewCount;
  final List<NearbyDoctorConsultationType> consultationTypes;
  final bool isAvailableNow;
  final double distance;
  final List<NearbyDoctorAddress> addresses;
  final List<NearbyDoctorService> services; // Changed from List<String>
  final List<String> education; // Keep as List<String> for now since it's empty
  final List<String>
  experience; // Keep as List<String> for now since it's empty
  final List<String> awards; // Keep as List<String> for now since it's empty
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profilePhoto;

  NearbyDoctor({
    required this.id,
    required this.name,
    required this.email,
    required this.specialty,
    required this.phoneNumber,
    required this.languages,
    required this.specializations,
    required this.qualification,
    required this.rating,
    required this.reviewCount,
    required this.consultationTypes,
    required this.isAvailableNow,
    required this.distance,
    required this.addresses,
    required this.services,
    required this.education,
    required this.experience,
    required this.awards,
    required this.createdAt,
    required this.updatedAt,
    this.profilePhoto, // Add this parameter
  });

  factory NearbyDoctor.fromJson(Map<String, dynamic> json) {
    return NearbyDoctor(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      specialty: json['specialty'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      languages: List<String>.from(json['languages'] ?? []),
      specializations: List<String>.from(json['specializations'] ?? []),
      qualification: List<String>.from(json['qualification'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      consultationTypes:
          (json['consultation_types'] as List<dynamic>? ?? [])
              .map((e) => NearbyDoctorConsultationType.fromJson(e))
              .toList(),
      isAvailableNow: json['is_available_now'] ?? false,
      distance: (json['distance'] ?? 0.0).toDouble(),
      addresses:
          (json['addresses'] as List<dynamic>? ?? [])
              .map((e) => NearbyDoctorAddress.fromJson(e))
              .toList(),
      services:
          (json['services'] as List<dynamic>? ?? []) // Fixed this line
              .map((e) => NearbyDoctorService.fromJson(e))
              .toList(),
      education: List<String>.from(json['education'] ?? []),
      experience: List<String>.from(json['experience'] ?? []),
      awards: List<String>.from(json['awards'] ?? []),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      profilePhoto:
          json['profile_photo'] ??
          json['profilePhoto'] ??
          json['profile_image_url'],
    );
  }
}

// Update the NearbyDoctorsResponse class to match the actual API response
class NearbyDoctorsResponse {
  final bool success;
  final List<NearbyDoctor> doctors;
  final Map<String, dynamic> pagination;
  final Map<String, dynamic> searchParams;

  NearbyDoctorsResponse({
    required this.success,
    required this.doctors,
    required this.pagination,
    required this.searchParams,
  });

  factory NearbyDoctorsResponse.fromJson(Map<String, dynamic> json) {
    return NearbyDoctorsResponse(
      success: json['success'] ?? false,
      doctors:
          (json['data']['doctors'] as List<dynamic>? ?? [])
              .map((e) => NearbyDoctor.fromJson(e))
              .toList(),
      pagination: json['data']['pagination'] ?? {},
      searchParams: json['data']['searchParams'] ?? {},
    );
  }
}
