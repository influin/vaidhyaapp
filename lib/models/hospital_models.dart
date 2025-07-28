import 'package:flutter/material.dart';
import 'doctor_models.dart';

class HospitalCategory {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  final Color? color;

  HospitalCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    this.color,
  });

  factory HospitalCategory.fromJson(Map<String, dynamic> json) {
    return HospitalCategory(
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

class Hospital {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String userType;
  final String type;
  final double rating;
  final int reviewCount;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final double latitude;
  final double longitude;
  final String? website;
  final int bedCount;
  final int doctorCount;
  final List<String> facilities;
  final List<HospitalService> services;
  final List<String> specialties;
  final List<String> insuranceAccepted;
  final List<String> images;
  final bool isOpen24x7;
  final double distance;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String>? doctorIds;

  Hospital({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.userType,
    required this.type,
    required this.rating,
    required this.reviewCount,
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    this.website,
    required this.bedCount,
    required this.doctorCount,
    required this.facilities,
    required this.services,
    required this.specialties,
    required this.insuranceAccepted,
    required this.images,
    required this.isOpen24x7,
    required this.distance,
    required this.createdAt,
    required this.updatedAt,
    this.doctorIds,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      userType: json['user_type'] ?? '',
      type: json['type'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postal_code'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      website: json['website'],
      bedCount: json['bed_count'] ?? 0,
      doctorCount: json['doctor_count'] ?? 0,
      facilities: List<String>.from(json['facilities'] ?? []),
      services: (json['services'] as List<dynamic>? ?? [])
          .map((service) => HospitalService.fromJson(service))
          .toList(),
      specialties: List<String>.from(json['specialties'] ?? []),
      insuranceAccepted: List<String>.from(json['insurance_accepted'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      isOpen24x7: json['is_open_24x7'] ?? false,
      distance: (json['distance'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      doctorIds: (json['doctor_ids'] as List?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'user_type': userType,
      'type': type,
      'rating': rating,
      'review_count': reviewCount,
      'address': address,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'website': website,
      'bed_count': bedCount,
      'doctor_count': doctorCount,
      'facilities': facilities,
      'services': services.map((e) => e.toJson()).toList(),
      'specialties': specialties,
      'insurance_accepted': insuranceAccepted,
      'images': images,
      'is_open_24x7': isOpen24x7,
      'distance': distance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'doctor_ids': doctorIds,
    };
  }
}

class HospitalService {
  final String id;
  final String name;
  final String description;
  final double minPrice;
  final double maxPrice;
  final String currency;
  final IconData? icon;

  HospitalService({
    required this.id,
    required this.name,
    required this.description,
    required this.minPrice,
    required this.maxPrice,
    required this.currency,
    this.icon,
  });

  factory HospitalService.fromJson(Map<String, dynamic> json) {
    return HospitalService(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Service',
      description: json['description']?.toString() ?? '',
      minPrice: (json['min_price'] ?? json['minPrice'] ?? 0).toDouble(),
      maxPrice: (json['max_price'] ?? json['maxPrice'] ?? 0).toDouble(),
      currency: json['currency']?.toString() ?? 'INR',
      icon: json['icon_code'] != null
          ? IconData(json['icon_code'], fontFamily: 'MaterialIcons')
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'min_price': minPrice,
      'max_price': maxPrice,
      'currency': currency,
      'icon_code': icon?.codePoint,
    };
  }
}

class NearbyHospitalsResponse {
  final bool success;
  final List<Hospital> hospitals;
  final Pagination pagination;
  final SearchParams searchParams;

  NearbyHospitalsResponse({
    required this.success,
    required this.hospitals,
    required this.pagination,
    required this.searchParams,
  });

  factory NearbyHospitalsResponse.fromJson(Map<String, dynamic> json) {
    return NearbyHospitalsResponse(
      success: json['success'] ?? false,
      hospitals: (json['data']['hospitals'] as List<dynamic>? ?? [])
          .map((hospital) => Hospital.fromJson(hospital))
          .toList(),
      pagination: Pagination.fromJson(json['data']['pagination'] ?? {}),
      searchParams: SearchParams.fromJson(json['data']['searchParams'] ?? {}),
    );
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNext;
  final bool hasPrevious;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalItems: json['totalItems'] ?? 0,
      itemsPerPage: json['itemsPerPage'] ?? 10,
      hasNext: json['hasNext'] ?? false,
      hasPrevious: json['hasPrevious'] ?? false,
    );
  }
}

class SearchParams {
  final double latitude;
  final double longitude;
  final double radius;
  final String? type;
  final String? specialty;
  final int limit;
  final int page;

  SearchParams({
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.type,
    this.specialty,
    required this.limit,
    required this.page,
  });

  factory SearchParams.fromJson(Map<String, dynamic> json) {
    return SearchParams(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      radius: (json['radius'] ?? 10).toDouble(),
      type: json['type'],
      specialty: json['specialty'],
      limit: json['limit'] ?? 10,
      page: json['page'] ?? 1,
    );
  }
}

