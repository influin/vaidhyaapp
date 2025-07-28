import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidhya_front_end/services/api_service.dart';
import 'package:vaidhya_front_end/models/doctor_models.dart';
import 'package:vaidhya_front_end/models/hospital_models.dart';
import 'package:vaidhya_front_end/models/appointment_models.dart';
import 'package:vaidhya_front_end/models/service_models.dart';
import 'package:vaidhya_front_end/models/user_models.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the API service
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Provider for user registration
final registerUserProvider = FutureProvider.family<
  Map<String, dynamic>,
  Map<String, dynamic>
>((ref, userData) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.registerUser(
    name: userData['name'] as String,
    mobileNumber: userData['mobileNumber'] as String,
    email: userData['email'] as String,
    password: userData['password'] as String,
    role: userData['role'] as String,
    preferredLanguage: userData['preferredLanguage'] as String? ?? 'english',
    // Additional fields with proper type casting
    specialty: userData['specialty'] as String?,
    category: userData['category'] as String?,
    facilityDetails: userData['facilityDetails'] as String?,
    address: userData['address'] as String?,
    addressData: userData['addressData'] as Map<String, dynamic>?,
    addressDataJson: userData['addressDataJson'] as String?,
    type: userData['type'] as String?,
    placeData: userData['placeData'] as String?,
    // Add missing address fields for all user types
    city: userData['city'] as String?,
    state: userData['state'] as String?,
    postalCode: userData['postalCode'] as String?,
  );
});

// Provider for sending OTP
final sendOTPProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((
      ref,
      otpData,
    ) async {
      final apiService = ref.watch(apiServiceProvider);
      return apiService.sendOTP(mobileNumber: otpData['mobileNumber']);
    });

// Provider for verifying OTP
final verifyOTPProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((
      ref,
      verifyData,
    ) async {
      final apiService = ref.watch(apiServiceProvider);
      return apiService.verifyOTP(
        mobileNumber: verifyData['mobileNumber'],
        otp: verifyData['otp'],
      );
    });

// Provider for user profile
final userProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getUserProfile();
});

// Provider for updating user profile
final updateUserProfileProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((
      ref,
      profileData,
    ) async {
      final apiService = ref.watch(apiServiceProvider);
      return apiService.updateUserProfile(profileData);
    });

// Provider for user login with mobile (OTP)
final loginWithMobileProvider =
    FutureProvider.family<Map<String, dynamic>, String>((
      ref,
      mobileNumber,
    ) async {
      final apiService = ref.watch(apiServiceProvider);
      return apiService.loginWithMobile(mobileNumber: mobileNumber);
    });

// Provider for user login with password
final loginWithPasswordProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((
      ref,
      loginData,
    ) async {
      final apiService = ref.watch(apiServiceProvider);
      return apiService.loginWithPassword(
        email: loginData['email'],
        password: loginData['password'],
      );
    });

// Provider for creating payment order
final createPaymentOrderProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
      final apiService = ref.watch(apiServiceProvider);
      return apiService.createPaymentOrder(userId: userId);
    });

// Provider for verifying payment
final verifyPaymentProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, String>>((
      ref,
      paymentData,
    ) async {
      final apiService = ref.watch(apiServiceProvider);
      return apiService.verifyPayment(
        orderId: paymentData['orderId']!,
        paymentId: paymentData['paymentId']!,
        signature: paymentData['signature']!,
        userId: paymentData['userId']!,
      );
    });

// Provider for doctor appointments
final doctorAppointmentsProvider =
    FutureProvider.family<List<dynamic>, String?>((ref, status) async {
      final apiService = ref.watch(apiServiceProvider);
      return apiService.getDoctorAppointments(status: status);
    });

// Provider for responding to appointments
final respondToAppointmentProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((
      ref,
      data,
    ) async {
      final apiService = ref.watch(apiServiceProvider);
      return apiService.respondToAppointment(
        appointmentId: data['appointmentId'],
        action: data['action'],
        reason: data['reason'],
      );
    });

// Provider for doctor earnings
final doctorEarningsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getDoctorEarnings();
});

// Provider for payout history
final payoutHistoryProvider = FutureProvider<List<dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getPayoutHistory();
});

// Provider for updating bank details
final updateBankDetailsProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((
      ref,
      bankDetails,
    ) async {
      final apiService = ref.watch(apiServiceProvider);
      return apiService.updateBankDetails(bankDetails);
    });

// Provider for doctor dashboard stats
final doctorDashboardStatsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getDoctorDashboardStats();
});

// Provider for doctor service overview
final doctorServiceOverviewProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getDoctorServiceOverview();
});

// Provider for doctor services list
final doctorServicesProvider = FutureProvider<List<dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getDoctorServices();
});

// Provider for updating service status
final updateServiceStatusProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((
      ref,
      data,
    ) async {
      final apiService = ref.watch(apiServiceProvider);
      return apiService.updateDoctorServiceStatus(
        data['serviceId'],
        data['isActive'],
      );
    });

// Provider for getting service by ID
final doctorServiceByIdProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, serviceId) async {
      final apiService = ref.watch(apiServiceProvider);
      return apiService.getDoctorServiceById(serviceId);
    });

// Provider for updating a service
final updateDoctorServiceProvider = FutureProvider.family<
  Map<String, dynamic>,
  Map<String, dynamic>
>((ref, data) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.updateDoctorService(data['serviceId'], data['serviceData']);
});

// Provider for adding a new service
final addDoctorServiceProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((
      ref,
      serviceData,
    ) async {
      final apiService = ref.watch(apiServiceProvider);
      return apiService.addDoctorService(serviceData);
    });

// Provider for getting appointments by service
final appointmentsByServiceProvider =
    FutureProvider.family<List<dynamic>, Map<String, dynamic>>((
      ref,
      data,
    ) async {
      final apiService = ref.watch(apiServiceProvider);
      return apiService.getAppointmentsByService(
        data['serviceId'],
        status: data['status'],
      );
    });

// Provider for deleting a service
final deleteDoctorServiceProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, serviceId) async {
      final apiService = ref.watch(apiServiceProvider);
      return apiService.deleteDoctorService(serviceId);
    });

// Provider for updating doctor profile
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

// Provider for getting doctor profile by ID
final doctorProfileProvider = FutureProvider.autoDispose.family<DoctorProfile, String>((ref, doctorId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getDoctorProfile(doctorId);
});

// Provider for latest customer appointment
final latestCustomerAppointmentProvider = FutureProvider<DoctorAppointment?>((
  ref,
) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getLatestCustomerAppointment();
});

// Add new provider for all customer appointments
final customerAppointmentsProvider = FutureProvider<List<Appointment>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getCustomerAppointments();
});

// Provider for getting doctor availability
final doctorAvailabilityProvider = FutureProvider.family<DoctorAvailability?, String>((ref, doctorId) async {
  final apiService = ApiService();
  return apiService.getDoctorAvailability(doctorId);
});


// Provider for booking doctor appointment
final bookDoctorAppointmentProvider = FutureProvider.family<DoctorBookingResponse, DoctorBookingRequest>((ref, request) async {
  final apiService = ApiService();
  return apiService.bookDoctorAppointment(request);
});

// Provider for payment verification
final verifyAppointmentPaymentProvider = FutureProvider.family<PaymentVerificationResponse, PaymentVerificationRequest>((ref, request) async {
  final apiService = ApiService();
  return apiService.verifyAppointmentPayment(request);
});


// Updated provider with stable parameters
final nearbyDoctorsProvider =
    FutureProvider.autoDispose.family<NearbyDoctorsResponse, NearbyDoctorsParams>((ref, params) async {
      final apiService = ref.watch(apiServiceProvider);
      return apiService.getNearbyDoctors(
        latitude: params.latitude,
        longitude: params.longitude,
        radius: params.radius,
        limit: params.limit,
        page: params.page,
        specialty: params.specialty,
      );
    });



class NearbyDoctorsParams {
  final double latitude;
  final double longitude;
  final double radius;
  final int limit;
  final int page;
  final String? specialty;

  const NearbyDoctorsParams({
    required this.latitude,
    required this.longitude,
    this.radius = 10.0,
    this.limit = 20,
    this.page = 1,
    this.specialty,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NearbyDoctorsParams &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.radius == radius &&
        other.limit == limit &&
        other.page == page &&
        other.specialty == specialty;
  }

  @override
  int get hashCode {
    return latitude.hashCode ^
        longitude.hashCode ^
        radius.hashCode ^
        limit.hashCode ^
        page.hashCode ^
        specialty.hashCode;
  }
}


// Provider for nearby hospitals
final nearbyHospitalsProvider =
    FutureProvider.autoDispose.family<NearbyHospitalsResponse, NearbyHospitalsParams>((ref, params) async {
      final apiService = ref.watch(apiServiceProvider);
      return apiService.getNearbyHospitals(
        latitude: params.latitude,
        longitude: params.longitude,
        radius: params.radius,
        limit: params.limit,
        page: params.page,
        type: params.type,
        specialty: params.specialty,
      );
    });

class NearbyHospitalsParams {
  final double latitude;
  final double longitude;
  final double radius;
  final int limit;
  final int page;
  final String? type;
  final String? specialty;

  const NearbyHospitalsParams({
    required this.latitude,
    required this.longitude,
    this.radius = 10.0,
    this.limit = 20,
    this.page = 1,
    this.type,
    this.specialty,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NearbyHospitalsParams &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.radius == radius &&
        other.limit == limit &&
        other.page == page &&
        other.type == type &&
        other.specialty == specialty;
  }

  @override
  int get hashCode {
    return latitude.hashCode ^
        longitude.hashCode ^
        radius.hashCode ^
        limit.hashCode ^
        page.hashCode ^
        type.hashCode ^
        specialty.hashCode;
  }
}


// Provider for doctor availability
