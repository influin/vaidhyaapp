import 'package:flutter/material.dart';

class Service {
  final String id;
  final String title;
  final String? description;
  final IconData icon;
  final Color color;
  final bool isQuickAction;
  final String? categoryId;

  Service({
    required this.id,
    required this.title,
    this.description,
    required this.icon,
    required this.color,
    this.isQuickAction = false,
    this.categoryId,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: IconData(json['icon_code'], fontFamily: 'MaterialIcons'),
      color: Color(json['color']),
      isQuickAction: json['is_quick_action'] ?? false,
      categoryId: json['category_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon_code': icon.codePoint,
      'color': color.value,
      'is_quick_action': isQuickAction,
      'category_id': categoryId,
    };
  }
}

class ServiceCategory {
  final String id;
  final String name;
  final String? description;
  final IconData? icon;
  final Color? color;
  final List<String>? serviceIds; // References to services in this category

  ServiceCategory({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.color,
    this.serviceIds,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon:
          json['icon_code'] != null
              ? IconData(json['icon_code'], fontFamily: 'MaterialIcons')
              : null,
      color: json['color'] != null ? Color(json['color']) : null,
      serviceIds: (json['service_ids'] as List?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_code': icon?.codePoint,
      'color': color?.value,
      'service_ids': serviceIds,
    };
  }
}

class ServiceVendor {
  final String id;
  final String name;
  final double rating;
  final int reviewCount;
  final String address;
  final String? city;
  final String? state;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final List<String> serviceTypes; // Types of services offered
  final List<VendorService> services; // Specific services with pricing
  final List<String>? images;
  final bool isAvailableNow;
  final List<TimeSlot>? availableSlots;

  ServiceVendor({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.address,
    this.city,
    this.state,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.email,
    this.website,
    required this.serviceTypes,
    required this.services,
    this.images,
    this.isAvailableNow = false,
    this.availableSlots,
  });

  factory ServiceVendor.fromJson(Map<String, dynamic> json) {
    return ServiceVendor(
      id: json['id'],
      name: json['name'],
      rating: json['rating'].toDouble(),
      reviewCount: json['review_count'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      website: json['website'],
      serviceTypes: (json['service_types'] as List).cast<String>(),
      services:
          (json['services'] as List)
              .map((e) => VendorService.fromJson(e))
              .toList(),
      images: (json['images'] as List?)?.cast<String>(),
      isAvailableNow: json['is_available_now'] ?? false,
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
      'rating': rating,
      'review_count': reviewCount,
      'address': address,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'phone_number': phoneNumber,
      'email': email,
      'website': website,
      'service_types': serviceTypes,
      'services': services.map((e) => e.toJson()).toList(),
      'images': images,
      'is_available_now': isAvailableNow,
      'available_slots': availableSlots?.map((e) => e.toJson()).toList(),
    };
  }
}

class VendorService {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? currency;
  final int? durationMinutes;
  final IconData? icon;

  VendorService({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.currency,
    this.durationMinutes,
    this.icon,
  });

  factory VendorService.fromJson(Map<String, dynamic> json) {
    return VendorService(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
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
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'duration_minutes': durationMinutes,
      'icon_code': icon?.codePoint,
    };
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

class DoctorService {
  final String id;
  final String name;
  final String description;
  final String serviceType;
  final double price;
  final bool isCommissionInclusive;
  final String currency;
  final int durationMinutes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final IconData? icon; // For UI purposes
  final Color? color; // For UI purposes

  DoctorService({
    required this.id,
    required this.name,
    required this.description,
    required this.serviceType,
    required this.price,
    required this.isCommissionInclusive,
    required this.currency,
    required this.durationMinutes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.icon,
    this.color,
  });

  factory DoctorService.fromJson(Map<String, dynamic> json) {
    // Create description by combining duration and service type
    final serviceType = json['serviceType'] ?? 'Clinical Visit';
    final durationMinutes = json['durationMinutes'] ?? 30;
    final description = "${durationMinutes}-minute ${serviceType}";

    return DoctorService(
      id: json['id'],
      name: serviceType, // Use serviceType as the name
      description: description, // Use the combined description
      serviceType: serviceType,
      price:
          (json['price'] is int)
              ? (json['price'] as int).toDouble()
              : json['price'],
      isCommissionInclusive: json['isCommissionInclusive'] ?? true,
      currency: json['currency'] ?? 'INR',
      durationMinutes: durationMinutes,
      isActive: json['isActive'] ?? true,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
      // UI properties not from API
      icon: null,
      color: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'serviceType': serviceType,
      'price': price,
      'isCommissionInclusive': isCommissionInclusive,
      'currency': currency,
      'durationMinutes': durationMinutes,
      'isActive': isActive,
    };
  }

  // Create a copy with UI properties
  DoctorService copyWithUI({IconData? icon, Color? color}) {
    return DoctorService(
      id: id,
      name: name,
      description: description,
      serviceType: serviceType,
      price: price,
      isCommissionInclusive: isCommissionInclusive,
      currency: currency,
      durationMinutes: durationMinutes,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}
