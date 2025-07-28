import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vaidhya_front_end/models/doctor_models.dart';
import 'package:vaidhya_front_end/models/hospital_models.dart';
import 'package:vaidhya_front_end/models/appointment_models.dart';
import 'package:vaidhya_front_end/models/service_models.dart';
import 'package:vaidhya_front_end/models/user_models.dart';
import 'package:vaidhya_front_end/models/vendor_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// API service for handling all network requests in the Vaidhya app.
/// Currently uses dummy data, but structured for easy integration with real APIs.
class ApiService {
  // Base URL for the API
  static const String baseUrl = 'https://vaidhyaback.onrender.com/api';

  // Singleton instance
  static final ApiService _instance = ApiService._internal();

  // HTTP client
  final http.Client _client = http.Client();

  // Auth token
  String? _authToken;

  // Factory constructor
  factory ApiService() {
    return _instance;
  }

  // Internal constructor
  ApiService._internal();

  // Headers for API requests
  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  // Set auth token
  Future<void> setAuthToken(String token) async {
    print('Setting auth token: $token'); // Add this line
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Load auth token from storage
  Future<void> loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      _authToken = token;
      print('Loaded auth token from storage: $token'); // Add this line
    } else {
      print('No auth token found in storage'); // Add this line
    }
  }

  // Clear auth token
  Future<void> clearAuthToken() async {
    _authToken = null; // Clears the token from memory
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(
      'auth_token',
    ); // Removes the token from persistent storage
  }

  // Load auth token from storage

  // Generic GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generic POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generic PUT request
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generic DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generic PATCH request
  // Generic PATCH request
  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _client.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      return json.decode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }

  // Register user
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String mobileNumber,
    required String email,
    required String password,
    required String role,
    String preferredLanguage = 'english',
    String? specialty,
    String? category,
    String? facilityDetails,
    String? address,
    Map<String, dynamic>? addressData,
    String? addressDataJson,
    String? type,
    String? placeData,
    // Add missing address parameters
    String? city,
    String? state,
    String? postalCode,
  }) async {
    final Map<String, dynamic> requestData = {
      'name': name,
      'mobileNumber': mobileNumber,
      'email': email,
      'password': password,
      'role': role,
      'preferredLanguage': preferredLanguage,
    };

    // Add role-specific fields
    if (role == 'doctor') {
      if (specialty != null) requestData['specialty'] = specialty;
      if (category != null) requestData['category'] = category;
    }

    // Add hospital type if provided
    if (role == 'hospital' && type != null) {
      requestData['type'] = type;
    }

    // Add facilityDetails for both hospital and vendor users
    if ((role == 'hospital' || role == 'vendor') && facilityDetails != null) {
      requestData['facilityDetails'] = facilityDetails;
    }

    // Add basic address for all user types
    if (address != null) {
      requestData['address'] = address;
    }

    // Add individual address fields for all user types (passed from register screen)
    if (city != null) requestData['city'] = city;
    if (state != null) requestData['state'] = state;
    if (postalCode != null) requestData['postalCode'] = postalCode;

    // Handle placeData for all user types (using hospital logic)
    if (placeData != null) {
      // Parse the JSON string to a map
      final placeDataMap = json.decode(placeData) as Map<String, dynamic>;

      // Extract required address fields from placeDataMap (override if not already set)
      final extractedPostalCode = placeDataMap['postal_code'] ?? '';
      if (extractedPostalCode.isEmpty) {
        throw Exception('Postal code is required in place data');
      }

      // Only override if not already set from register screen
      if (requestData['city'] == null || requestData['city'] == '') {
        requestData['city'] = placeDataMap['city'] ?? '';
      }
      if (requestData['state'] == null || requestData['state'] == '') {
        requestData['state'] = placeDataMap['state'] ?? '';
      }
      if (requestData['postalCode'] == null ||
          requestData['postalCode'] == '') {
        requestData['postalCode'] = extractedPostalCode;
      }

      // Add the already encoded placeData string
      requestData['placeData'] = placeData;
    }

    // Add detailed address data for all user types
    if (addressData != null) {
      requestData['addressData'] = addressData;

      // Extract required address fields and add them at the top level
      if (requestData['city'] == null || requestData['city'] == '') {
        requestData['city'] = addressData['city'] ?? '';
        requestData['state'] = addressData['state'] ?? '';
        requestData['postalCode'] = addressData['postalCode'] ?? '';
      }
    }

    // Handle addressDataJson for all user types
    if (addressDataJson != null) {
      requestData['addressDataJson'] = addressDataJson;

      // If addressData wasn't provided but addressDataJson was, extract from JSON
      if (addressData == null &&
          (requestData['city'] == null || requestData['city'] == '')) {
        try {
          final parsedJson = json.decode(addressDataJson);
          requestData['city'] = parsedJson['city'] ?? '';
          requestData['state'] = parsedJson['state'] ?? '';
          requestData['postalCode'] = parsedJson['postalCode'] ?? '';
        } catch (e) {
          print('Error parsing addressDataJson: $e');
        }
      }
    }

    // Inside the registerUser method, before the post call
    print('Type parameter received: $type');
    print('Final request data: $requestData');
    final data = await post('/auth/register', requestData);
    return data;
  }

  // Login user
  // Login user with OTP (Mobile Number)
  Future<Map<String, dynamic>> loginWithMobile({
    required String mobileNumber,
  }) async {
    final data = await post('/auth/login', {'mobileNumber': mobileNumber});

    return data;
  }

  // Login user with Password
  Future<Map<String, dynamic>> loginWithPassword({
    required String email,
    required String password,
  }) async {
    print('Attempting login with email: $email'); // Debug
    final data = await post('/auth/login-password', {
      'email': email,
      'password': password,
    });

    print('Login response: $data'); // Debug
    if (data['token'] != null) {
      print('Token received, setting auth token'); // Debug
      setAuthToken(data['token']);
    } else {
      print('No token received in login response'); // Debug
    }

    return data;
  }

  // The existing loginUser method can be deprecated or removed
  // Future<Map<String, dynamic>> loginUser({...}) async {...}
  // Send OTP
  Future<Map<String, dynamic>> sendOTP({required String mobileNumber}) async {
    final data = await post('/auth/resend-otp', {'mobileNumber': mobileNumber});

    return data;
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOTP({
    required String mobileNumber,
    required String otp,
  }) async {
    final data = await post('/auth/verify-otp', {
      'mobileNumber': mobileNumber,
      'otp': otp,
    });

    if (data['token'] != null) {
      setAuthToken(data['token']);
    }

    return data;
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      print('Getting user profile with token: $_authToken');
      final data = await get('/auth/profile');
      print('User profile response: $data');
      return data;
    } catch (e) {
      print('Error getting user profile: $e');
      throw e;
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> profileData,
  ) async {
    final data = await put('/user/profile', profileData);
    return data;
  }

  // Create payment order
  Future<Map<String, dynamic>> createPaymentOrder({
    required String userId,
  }) async {
    final data = await post('/payments/create-order', {'userId': userId});

    return data;
  }

  // Verify payment and activate subscription
  Future<Map<String, dynamic>> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
    required String userId,
  }) async {
    final data = await post('/payments/verify', {
      'orderId': orderId,
      'paymentId': paymentId,
      'signature': signature,
      'userId': userId,
    });

    return data;
  }

  // Get doctor appointments
  Future<List<dynamic>> getDoctorAppointments({String? status}) async {
    String endpoint = '/appointments/provider';
    if (status != null) {
      endpoint += '?status=$status';
    }

    final data = await get(endpoint);
    return data as List<dynamic>;
  }

  // Respond to appointment (confirm or reject)
  Future<Map<String, dynamic>> respondToAppointment({
    required String appointmentId,
    required String action,
    String? reason,
  }) async {
    final Map<String, dynamic> requestData = {
      'appointmentId': appointmentId,
      'action': action,
    };

    if (action == 'reject' && reason != null) {
      requestData['reason'] = reason;
    }

    final data = await post('/appointments/respond', requestData);
    return data;
  }

  // Get doctor earnings
  Future<Map<String, dynamic>> getDoctorEarnings() async {
    final data = await get('/transactions/earnings');
    return data;
  }

  // Get doctor dashboard stats
  Future<Map<String, dynamic>> getDoctorDashboardStats() async {
    final data = await get('/doctors/dashboard-stats');
    return data;
  }

  // Get payout history
  Future<List<dynamic>> getPayoutHistory() async {
    final data = await get('/transactions/payout/history');
    return data as List<dynamic>;
  }

  // Update bank details
  Future<Map<String, dynamic>> updateBankDetails(
    Map<String, dynamic> bankDetails,
  ) async {
    final data = await put('/transactions/bank-details', bankDetails);
    return data;
  }

  Future<Map<String, dynamic>> getDoctorServiceOverview() async {
    // Add timestamp to prevent caching
    final data = await get('/doctors/service-overview');

    // Map the API response fields to what the UI expects
    return {
      'totalServices': data['total'],
      'activeServices': data['active'],
      'inactiveServices': data['inactive'],
    };
  }

  // Get doctor services
  Future<List<dynamic>> getDoctorServices() async {
    final data = await get('/doctors/services');
    return data['services'] as List<dynamic>;
  }

  // Update service status
  // Update service status
  Future<Map<String, dynamic>> updateDoctorServiceStatus(
    String serviceId,
    bool isActive,
  ) async {
    final data = await patch('/doctors/services/$serviceId/status', {
      'isActive': isActive,
    });
    return data;
  }

  // Get service by ID
  Future<Map<String, dynamic>> getDoctorServiceById(String serviceId) async {
    final data = await get('/doctors/services/$serviceId');
    return data;
  }

  // Update service
  Future<Map<String, dynamic>> updateDoctorService(
    String serviceId,
    Map<String, dynamic> serviceData,
  ) async {
    final data = await put('/doctors/services/$serviceId', serviceData);
    return data;
  }

  // Add new service
  Future<Map<String, dynamic>> addDoctorService(
    Map<String, dynamic> serviceData,
  ) async {
    final data = await post('/doctors/services', serviceData);
    return data;
  }

  // Get appointments by service
  Future<List<dynamic>> getAppointmentsByService(
    String serviceId, {
    String? status,
  }) async {
    String endpoint = '/appointments/doctor/by-service?serviceId=$serviceId';
    if (status != null) {
      endpoint += '&status=$status';
    }
    final data = await get(endpoint);
    return data as List<dynamic>;
  }

  // Delete service
  Future<Map<String, dynamic>> deleteDoctorService(String serviceId) async {
    final data = await delete('/doctors/services/$serviceId');
    return data;
  }

  // Update doctor profile
  Future<Map<String, dynamic>> updateDoctorProfile(
    Map<String, dynamic> profileData, {
    String? imagePath,
  }) async {
    try {
      // If image path is provided, we need to upload the image first
      if (imagePath != null) {
        // Create multipart request
        final request = http.MultipartRequest(
          'PUT',
          Uri.parse('$baseUrl/doctors/profile'),
        );

        // Add auth token
        if (_authToken != null) {
          request.headers['Authorization'] = 'Bearer $_authToken';
        }

        // Add file
        request.files.add(
          await http.MultipartFile.fromPath('profilePhoto', imagePath),
        );

        // Add other fields
        profileData.forEach((key, value) {
          if (value != null) {
            if (value is List) {
              // Handle arrays like qualifications and specialtyTags
              request.fields[key] = json.encode(value);
            } else {
              request.fields[key] = value.toString();
            }
          }
        });

        // Send request
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        return _handleResponse(response);
      } else {
        // If no image, use regular PUT request
        return await put('/doctors/profile', profileData);
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Check if auth token exists
  bool get hasAuthToken => _authToken != null;

  // Hospital Services Management APIs

  // Get hospital profile including services
  Future<Map<String, dynamic>> getHospitalProfile() async {
    try {
      final response = await get('/hospitals/profile');
      return response;
    } catch (e) {
      throw Exception('Failed to get hospital profile: $e');
    }
  }

  // Get specific hospital profile by ID
  Future<Map<String, dynamic>> getHospitalProfileById(String hospitalId) async {
    try {
      final response = await get('/hospitals/profile/$hospitalId');
      return response;
    } catch (e) {
      throw Exception('Failed to get hospital profile: $e');
    }
  }

  // Vendor APIs
  Future<VendorSearchResponse> getNearbyVendors({
    required double latitude,
    required double longitude,
    int radius = 10,
    int limit = 20,
    String? serviceType,
    int page = 1,
  }) async {
    try {
      final queryParams = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': radius.toString(),
        'limit': limit.toString(),
        'page': page.toString(),
      };
      
      if (serviceType != null && serviceType.isNotEmpty) {
        queryParams['serviceType'] = serviceType;
      }
      
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      
      final response = await get('/vendors/nearby?$queryString');
      return VendorSearchResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get nearby vendors: $e');
    }
  }

  // Get vendor profile by ID
  Future<Map<String, dynamic>> getVendorProfileById(String vendorId) async {
    try {
      final response = await get('/vendors/profile/$vendorId');
      return response;
    } catch (e) {
      throw Exception('Failed to get vendor profile: $e');
    }
  }

  // Update hospital services
  Future<Map<String, dynamic>> updateHospitalServices(
    List<Map<String, dynamic>> services,
  ) async {
    try {
      final response = await put('/hospitals/services', {'services': services});
      return response;
    } catch (e) {
      throw Exception('Failed to update hospital services: $e');
    }
  }

  // Update hospital profile settings
  Future<Map<String, dynamic>> updateHospitalProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await put('/hospitals/profile', profileData);
      return response;
    } catch (e) {
      throw Exception('Failed to update hospital profile: $e');
    }
  }

  // Create address data map with Google Places information
  Map<String, dynamic> createAddressData({
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    String? placeId,
    double? latitude,
    double? longitude,
    String? formattedAddress,
  }) {
    return {
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      // Google Places fields
      'place_id': placeId,
      'latitude': latitude,
      'longitude': longitude,
      'formatted_address': formattedAddress,
    };
  }

  Future<NearbyHospitalsResponse> getNearbyHospitals({
    required double latitude,
    required double longitude,
    double radius = 10,
    int limit = 20,
    int page = 1,
    String? type,
    String? specialty,
  }) async {
    try {
      final queryParams = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': radius.toString(),
        'limit': limit.toString(),
        'page': page.toString(),
      };

      if (type != null && type.isNotEmpty && type != 'all') {
        queryParams['type'] = type;
      }

      if (specialty != null && specialty.isNotEmpty && specialty != 'all') {
        queryParams['specialty'] = specialty;
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      print('=== NEARBY HOSPITALS API REQUEST ===');
      print('URL: /hospitals/nearby?$queryString');
      print('Query Params: $queryParams');

      final response = await get('/hospitals/nearby?$queryString');

      print('=== NEARBY HOSPITALS API RESPONSE ===');
      print('Raw Response: $response');

      final parsedResponse = NearbyHospitalsResponse.fromJson(response);

      print('Parsed Response:');
      print('Success: ${parsedResponse.success}');
      print('Total Hospitals: ${parsedResponse.hospitals.length}');
      print('Pagination: ${parsedResponse.pagination}');
      print('Search Params: ${parsedResponse.searchParams}');

      for (int i = 0; i < parsedResponse.hospitals.length; i++) {
        final hospital = parsedResponse.hospitals[i];
        print('\nHospital ${i + 1}:');
        print('  ID: ${hospital.id}');
        print('  Name: ${hospital.name}');
        print('  Email: ${hospital.email}');
        print('  Type: ${hospital.type}');
        print('  Phone: ${hospital.phoneNumber}');
        print('  Rating: ${hospital.rating}');
        print('  Review Count: ${hospital.reviewCount}');
        print('  Distance: ${hospital.distance} km');
        print('  Bed Count: ${hospital.bedCount}');
        print('  Doctor Count: ${hospital.doctorCount}');
        print('  Is Open 24x7: ${hospital.isOpen24x7}');
      }

      print('=== END OF RESPONSE ===\n');

      return parsedResponse;
    } catch (e) {
      print('\n=== ERROR FETCHING NEARBY HOSPITALS ===');
      print('Error Type: ${e.runtimeType}');
      print('Error Message: $e');
      print('Stack Trace:');
      print(StackTrace.current);
      print('=== END OF ERROR ===\n');
      throw Exception('Failed to fetch nearby hospitals: $e');
    }
  }

  Future<NearbyDoctorsResponse> getNearbyDoctors({
    required double latitude,
    required double longitude,
    double radius = 10,
    int limit = 20,
    int page = 1,
    String? specialty,
    String? category,
  }) async {
    try {
      final queryParams = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': radius.toString(),
        'limit': limit.toString(),
        'page': page.toString(),
      };

      if (specialty != null && specialty.isNotEmpty && specialty != 'all') {
        queryParams['specialty'] = specialty;
      }

      if (category != null && category.isNotEmpty && category != 'all') {
        queryParams['category'] = category;
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      print('=== NEARBY DOCTORS API REQUEST ===');
      print('URL: /doctors/nearby?$queryString');
      print('Query Params: $queryParams');

      final response = await get('/doctors/nearby?$queryString');

      print('=== NEARBY DOCTORS API RESPONSE ===');
      print('Raw Response: $response');

      final parsedResponse = NearbyDoctorsResponse.fromJson(response);

      print('Parsed Response:');
      print('Success: ${parsedResponse.success}');
      print('Total Doctors: ${parsedResponse.doctors.length}');
      print('=== END OF RESPONSE ===\n');

      return parsedResponse;
    } catch (e) {
      print('\n=== ERROR FETCHING NEARBY DOCTORS ===');
      print('Error Type: ${e.runtimeType}');
      print('Error Message: $e');
      print('Stack Trace:');
      print(StackTrace.current);
      print('=== END OF ERROR ===\n');
      throw Exception('Failed to fetch nearby doctors: $e');
    }
  }

  Future<DoctorProfile> getDoctorProfile(String doctorId) async {
    try {
      final data = await get('/doctors/profile/$doctorId');
      return DoctorProfile.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get doctor profile: $e');
    }
  }

  Future<DoctorAppointment?> getLatestCustomerAppointment() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/appointments/customer/latest'),
        headers: _headers,
      );

      // Handle 404 as "no appointments found" - this is expected behavior
      if (response.statusCode == 404) {
        print(
          'No appointments found (404) - this is expected when user has no appointments',
        );
        return null;
      }

      // Handle other successful responses
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return null;
        }
        final data = json.decode(response.body);
        return DoctorAppointment.fromJson(data);
      }

      // Handle other error status codes
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    } catch (e) {
      // Only log actual errors, not 404s
      if (!e.toString().contains('404')) {
        print('Error getting latest appointment: $e');
      }
      return null;
    }
  }

  // Get doctor availability
  Future<DoctorAvailability?> getDoctorAvailability(String doctorId) async {
    try {
      final response = await get('/doctors/availability/$doctorId');

      // Handle new API response format with availableSlots array
      if (response is Map<String, dynamic> &&
          response.containsKey('availableSlots')) {
        final availableSlots = response['availableSlots'] as List<dynamic>;

        final transformedResponse = {
          'unavailablePeriods': [],
          'workingDays':
              availableSlots
                  .map(
                    (daySlot) => {
                      'day': daySlot['day'] ?? '',
                      'isAvailable':
                          (daySlot['slots'] as List?)?.isNotEmpty ?? false,
                      'slots':
                          (daySlot['slots'] as List?)
                              ?.map(
                                (slot) => {
                                  'startTime': slot['startTime'],
                                  'endTime': slot['endTime'],
                                  'isBooked':
                                      false, // Default to available since API doesn't provide this
                                  '_id': '', // Generate or use a default ID
                                },
                              )
                              .toList() ??
                          [],
                      '_id': '',
                    },
                  )
                  .toList(),
        };
        return DoctorAvailability.fromJson(transformedResponse);
      }

      // Fallback for old single day format
      if (response is Map<String, dynamic> && response.containsKey('slots')) {
        final transformedResponse = {
          'unavailablePeriods': [],
          'workingDays': [
            {
              'day': response['day'] ?? '',
              'isAvailable': (response['slots'] as List?)?.isNotEmpty ?? false,
              'slots':
                  (response['slots'] as List?)
                      ?.map(
                        (slot) => {
                          'startTime': slot['startTime'],
                          'endTime': slot['endTime'],
                          'isBooked': false,
                          '_id': '',
                        },
                      )
                      .toList() ??
                  [],
              '_id': '',
            },
          ],
        };
        return DoctorAvailability.fromJson(transformedResponse);
      }

      return DoctorAvailability.fromJson(response);
    } catch (e) {
      print('Error getting doctor availability: $e');
      return null;
    }
  }

  Future<List<Appointment>> getCustomerAppointments() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/appointments/customer'),
        headers: _headers,
      );

      // Handle 404 as "no appointments found" - this is expected behavior
      if (response.statusCode == 404) {
        print(
          'No appointments found (404) - this is expected when user has no appointments',
        );
        return [];
      }

      // Handle other successful responses
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return [];
        }
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Appointment.fromJson(json)).toList();
      }

      // Handle other error status codes
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Error fetching customer appointments: $e');
      throw Exception('Failed to fetch appointments: $e');
    }
  }

  // Book doctor appointment
  Future<DoctorBookingResponse> bookDoctorAppointment(
    DoctorBookingRequest request,
  ) async {
    try {
      final response = await post(
        '/appointments/book/doctor',
        request.toJson(),
      );

      // Since _handleResponse already processes the response and returns decoded JSON,
      // we don't need to check statusCode or decode again
      return DoctorBookingResponse.fromJson(response);
    } catch (e) {
      print('Error booking appointment: $e');
      rethrow;
    }
  }

  // Verify appointment payment (separate from subscription payment)
  Future<PaymentVerificationResponse> verifyAppointmentPayment(
    PaymentVerificationRequest request,
  ) async {
    try {
      final data = await post('/appointments/verify-payment', request.toJson());

      // The post method already handles status codes and returns decoded JSON
      // No need to check statusCode or decode again
      return PaymentVerificationResponse.fromJson(data);
    } catch (e) {
      print('Error verifying appointment payment: $e');
      rethrow;
    }
  }
}

// Get latest customer appointment

// Add this method to the ApiService class

// Get nearby doctors

  // Add new method for getting all customer appointments
  

