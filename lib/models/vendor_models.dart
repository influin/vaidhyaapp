class Vendor {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String userType;
  final double rating;
  final int reviewCount;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final double latitude;
  final double longitude;
  final String? website;
  final List<String> serviceTypes;
  final List<VendorService> services;
  final List<String> images;
  final bool isAvailableNow;
  final List<String> availableSlots;
  final double distance;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vendor({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.userType,
    required this.rating,
    required this.reviewCount,
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    this.website,
    required this.serviceTypes,
    required this.services,
    required this.images,
    required this.isAvailableNow,
    required this.availableSlots,
    required this.distance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      userType: json['user_type'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postal_code'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      website: json['website'],
      serviceTypes: List<String>.from(json['service_types'] ?? []),
      services: (json['services'] as List<dynamic>? ?? [])
          .map((service) => VendorService.fromJson(service))
          .toList(),
      images: List<String>.from(json['images'] ?? []),
      isAvailableNow: json['is_available_now'] ?? false,
      availableSlots: List<String>.from(json['available_slots'] ?? []),
      distance: (json['distance'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'user_type': userType,
      'rating': rating,
      'review_count': reviewCount,
      'address': address,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'website': website,
      'service_types': serviceTypes,
      'services': services.map((service) => service.toJson()).toList(),
      'images': images,
      'is_available_now': isAvailableNow,
      'available_slots': availableSlots,
      'distance': distance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class VendorService {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final int durationMinutes;
  final String iconCode;

  VendorService({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.durationMinutes,
    required this.iconCode,
  });

  factory VendorService.fromJson(Map<String, dynamic> json) {
    return VendorService(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'INR',
      durationMinutes: json['durationMinutes'] ?? 0,
      iconCode: json['iconCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'durationMinutes': durationMinutes,
      'iconCode': iconCode,
    };
  }
}

class VendorSearchResponse {
  final bool success;
  final VendorSearchData data;

  VendorSearchResponse({
    required this.success,
    required this.data,
  });

  factory VendorSearchResponse.fromJson(Map<String, dynamic> json) {
    return VendorSearchResponse(
      success: json['success'] ?? false,
      data: VendorSearchData.fromJson(json['data'] ?? {}),
    );
  }
}

class VendorSearchData {
  final List<Vendor> vendors;
  final VendorPagination pagination;
  final VendorSearchParams searchParams;

  VendorSearchData({
    required this.vendors,
    required this.pagination,
    required this.searchParams,
  });

  factory VendorSearchData.fromJson(Map<String, dynamic> json) {
    return VendorSearchData(
      vendors: (json['vendors'] as List<dynamic>? ?? [])
          .map((vendor) => Vendor.fromJson(vendor))
          .toList(),
      pagination: VendorPagination.fromJson(json['pagination'] ?? {}),
      searchParams: VendorSearchParams.fromJson(json['searchParams'] ?? {}),
    );
  }
}

class VendorPagination {
  final int total;
  final int page;
  final int limit;
  final int pages;
  final bool hasNext;
  final bool hasPrev;

  VendorPagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory VendorPagination.fromJson(Map<String, dynamic> json) {
    return VendorPagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      pages: json['pages'] ?? 1,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }
}

class VendorSearchParams {
  final double latitude;
  final double longitude;
  final int radius;
  final String serviceType;

  VendorSearchParams({
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.serviceType,
  });

  factory VendorSearchParams.fromJson(Map<String, dynamic> json) {
    return VendorSearchParams(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      radius: json['radius'] ?? 10,
      serviceType: json['serviceType'] ?? '',
    );
  }
}