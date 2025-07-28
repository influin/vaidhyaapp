import 'package:flutter/material.dart';

enum AppointmentStatus {
  pending,
  upcoming,
  completed,
  cancelled,
  rescheduled,
  noShow
}

enum AppointmentType {
  doctor,
  hospital,
  service
}

class Appointment {
  final String id;
  final String userId;
  final AppointmentType type;
  final String? doctorId;
  final String? hospitalId;
  final String? serviceVendorId;
  final DateTime dateTime;
  final String? consultationType;
  final double amount;
  final String? currency;
  final AppointmentStatus status;
  final String? notes;
  final String? paymentId;
  final DateTime bookedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final bool isPaid;
  
  // Add these new fields to match the API response
  final String? doctorName;
  final String? specialty;
  final String? clinicName;
  final String? clinicAddress;
  final String? serviceType;
  final double? originalServicePrice;

  Appointment({
    required this.id,
    required this.userId,
    required this.type,
    this.doctorId,
    this.hospitalId,
    this.serviceVendorId,
    required this.dateTime,
    this.consultationType,
    required this.amount,
    this.currency,
    required this.status,
    this.notes,
    this.paymentId,
    required this.bookedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.isPaid = false,
    // Add new fields
    this.doctorName,
    this.specialty,
    this.clinicName,
    this.clinicAddress,
    this.serviceType,
    this.originalServicePrice,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      userId: json['user_id'],
      type: AppointmentType.values.byName(json['type']),
      doctorId: json['doctor_id'],
      hospitalId: json['hospital_id'],
      serviceVendorId: json['service_vendor_id'],
      dateTime: DateTime.parse(json['date_time']),
      consultationType: json['consultation_type'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      status: AppointmentStatus.values.byName(json['status']),
      notes: json['notes'],
      paymentId: json['payment_id'],
      bookedAt: DateTime.parse(json['booked_at']),
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      cancellationReason: json['cancellation_reason'],
      isPaid: json['is_paid'] ?? false,
      // Add new fields
      doctorName: json['doctor_name'],
      specialty: json['specialty'],
      clinicName: json['clinic_name'],
      clinicAddress: json['clinic_address'],
      serviceType: json['service_type'],
      originalServicePrice: json['original_service_price']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'doctor_id': doctorId,
      'hospital_id': hospitalId,
      'service_vendor_id': serviceVendorId,
      'date_time': dateTime.toIso8601String(),
      'consultation_type': consultationType,
      'amount': amount,
      'currency': currency,
      'status': status.name,
      'notes': notes,
      'payment_id': paymentId,
      'booked_at': bookedAt.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancellation_reason': cancellationReason,
      'is_paid': isPaid,
    };
  }
}

class DoctorAppointment extends Appointment {
  final String doctorName;
  final String specialty;
  final String? clinicName;
  final String? clinicAddress;

  DoctorAppointment({
    required super.id,
    required super.userId,
    required super.dateTime,
    required super.amount,
    required super.status,
    required super.bookedAt,
    required this.doctorName,
    required this.specialty,
    this.clinicName,
    this.clinicAddress,
    super.doctorId,
    super.consultationType,
    super.currency,
    super.notes,
    super.paymentId,
    super.cancelledAt,
    super.cancellationReason,
    super.isPaid,
  }) : super(type: AppointmentType.doctor);

  factory DoctorAppointment.fromJson(Map<String, dynamic> json) {
    return DoctorAppointment(
      id: json['id'],
      userId: json['user_id'],
      doctorId: json['doctor_id'],
      dateTime: DateTime.parse(json['date_time']),
      consultationType: json['consultation_type'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      status: AppointmentStatus.values.byName(json['status']),
      notes: json['notes'],
      paymentId: json['payment_id'],
      bookedAt: DateTime.parse(json['booked_at']),
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      cancellationReason: json['cancellation_reason'],
      isPaid: json['is_paid'] ?? false,
      doctorName: json['doctor_name'],
      specialty: json['specialty'],
      clinicName: json['clinic_name'],
      clinicAddress: json['clinic_address'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'doctor_name': doctorName,
      'specialty': specialty,
      'clinic_name': clinicName,
      'clinic_address': clinicAddress,
    });
    return json;
  }
}

class HospitalAppointment extends Appointment {
  final String hospitalName;
  final String department;
  final String service;
  final String? hospitalAddress;

  HospitalAppointment({
    required super.id,
    required super.userId,
    required super.dateTime,
    required super.amount,
    required super.status,
    required super.bookedAt,
    required this.hospitalName,
    required this.department,
    required this.service,
    this.hospitalAddress,
    super.hospitalId,
    super.consultationType,
    super.currency,
    super.notes,
    super.paymentId,
    super.cancelledAt,
    super.cancellationReason,
    super.isPaid,
  }) : super(type: AppointmentType.hospital);

  factory HospitalAppointment.fromJson(Map<String, dynamic> json) {
    return HospitalAppointment(
      id: json['id'],
      userId: json['user_id'],
      hospitalId: json['hospital_id'],
      dateTime: DateTime.parse(json['date_time']),
      consultationType: json['consultation_type'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      status: AppointmentStatus.values.byName(json['status']),
      notes: json['notes'],
      paymentId: json['payment_id'],
      bookedAt: DateTime.parse(json['booked_at']),
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      cancellationReason: json['cancellation_reason'],
      isPaid: json['is_paid'] ?? false,
      hospitalName: json['hospital_name'],
      department: json['department'],
      service: json['service'],
      hospitalAddress: json['hospital_address'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'hospital_name': hospitalName,
      'department': department,
      'service': service,
      'hospital_address': hospitalAddress,
    });
    return json;
  }
}

class ServiceAppointment extends Appointment {
  final String vendorName;
  final String serviceType;
  final String serviceName;
  final String? vendorAddress;

  ServiceAppointment({
    required super.id,
    required super.userId,
    required super.dateTime,
    required super.amount,
    required super.status,
    required super.bookedAt,
    required this.vendorName,
    required this.serviceType,
    required this.serviceName,
    this.vendorAddress,
    super.serviceVendorId,
    super.consultationType,
    super.currency,
    super.notes,
    super.paymentId,
    super.cancelledAt,
    super.cancellationReason,
    super.isPaid,
  }) : super(type: AppointmentType.service);

  factory ServiceAppointment.fromJson(Map<String, dynamic> json) {
    return ServiceAppointment(
      id: json['id'],
      userId: json['user_id'],
      serviceVendorId: json['service_vendor_id'],
      dateTime: DateTime.parse(json['date_time']),
      consultationType: json['consultation_type'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      status: AppointmentStatus.values.byName(json['status']),
      notes: json['notes'],
      paymentId: json['payment_id'],
      bookedAt: DateTime.parse(json['booked_at']),
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      cancellationReason: json['cancellation_reason'],
      isPaid: json['is_paid'] ?? false,
      vendorName: json['vendor_name'],
      serviceType: json['service_type'],
      serviceName: json['service_name'],
      vendorAddress: json['vendor_address'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'vendor_name': vendorName,
      'service_type': serviceType,
      'service_name': serviceName,
      'vendor_address': vendorAddress,
    });
    return json;
  }
}

// Patient Details Model
class PatientDetails {
  final String name;
  final int age;
  final String gender; // 'Male', 'Female', 'Other'
  final String phone;
  final String email;
  final String relationshipToCustomer; // 'self', 'spouse', 'child', 'parent', 'sibling', 'other'
  final String medicalHistory;
  final String allergies;
  final String currentMedications;

  PatientDetails({
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.email,
    required this.relationshipToCustomer,
    required this.medicalHistory,
    required this.allergies,
    required this.currentMedications,
  });

  factory PatientDetails.fromJson(Map<String, dynamic> json) {
    return PatientDetails(
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      phone: json['phone'],
      email: json['email'],
      relationshipToCustomer: json['relationship_to_customer'],
      medicalHistory: json['medical_history'],
      allergies: json['allergies'],
      currentMedications: json['current_medications'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'email': email,
      'relationshipToCustomer': relationshipToCustomer,
      'medicalHistory': medicalHistory,
      'allergies': allergies,
      'currentMedications': currentMedications,
    };
  }
}

// Doctor Booking Request Model
class DoctorBookingRequest {
  final String doctorId;
  final String consultationType;
  final DateTime dateTime;
  final String notes;
  final PatientDetails patientDetails;

  DoctorBookingRequest({
    required this.doctorId,
    required this.consultationType,
    required this.dateTime,
    required this.notes,
    required this.patientDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'doctorId': doctorId,
      'consultationType': consultationType,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
      'patientDetails': patientDetails.toJson(),
    };
  }
}

// Razorpay Order Model
class RazorpayOrder {
  final int amount;
  final int amountDue;
  final int amountPaid;
  final int attempts;
  final int createdAt;
  final String currency;
  final String entity;
  final String id;
  final List<dynamic> notes;
  final String? offerId;
  final String receipt;
  final String status;
  final String? keyId; // Make this nullable

  RazorpayOrder({
    required this.amount,
    required this.amountDue,
    required this.amountPaid,
    required this.attempts,
    required this.createdAt,
    required this.currency,
    required this.entity,
    required this.id,
    required this.notes,
    this.offerId,
    required this.receipt,
    required this.status,
    this.keyId, // Make this optional
  });

  factory RazorpayOrder.fromJson(Map<String, dynamic> json) {
    return RazorpayOrder(
      amount: json['amount'],
      amountDue: json['amount_due'],
      amountPaid: json['amount_paid'],
      attempts: json['attempts'],
      createdAt: json['created_at'],
      currency: json['currency'],
      entity: json['entity'],
      id: json['id'],
      notes: json['notes'],
      offerId: json['offer_id'],
      receipt: json['receipt'],
      status: json['status'],
      keyId: json['key_id'], // This can be null
    );
  }
}

// Doctor Booking Response Model
class DoctorBookingResponse {
  final String message;
  final DoctorAppointment appointment;
  final PatientDetails patient;
  final RazorpayOrder order;
  final String? keyId; // Add this field

  DoctorBookingResponse({
    required this.message,
    required this.appointment,
    required this.patient,
    required this.order,
    this.keyId, // Add this parameter
  });

  factory DoctorBookingResponse.fromJson(Map<String, dynamic> json) {
    return DoctorBookingResponse(
      message: json['message'],
      appointment: DoctorAppointment.fromJson(json['appointment']),
      patient: PatientDetails.fromJson(json['patient']),
      order: RazorpayOrder.fromJson(json['order']),
      keyId: json['key_id'], // Add this line
    );
  }
}

// Payment Verification Request Model
class PaymentVerificationRequest {
  final String appointmentId;
  final String razorpayPaymentId;
  final String razorpayOrderId;
  final String razorpaySignature;

  PaymentVerificationRequest({
    required this.appointmentId,
    required this.razorpayPaymentId,
    required this.razorpayOrderId,
    required this.razorpaySignature,
  });

  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_signature': razorpaySignature,
    };
  }
}

// Payment Verification Response Model
class PaymentVerificationResponse {
  final String message;
  final AppointmentPaymentInfo appointment;

  PaymentVerificationResponse({
    required this.message,
    required this.appointment,
  });

  factory PaymentVerificationResponse.fromJson(Map<String, dynamic> json) {
    return PaymentVerificationResponse(
      message: json['message'],
      appointment: AppointmentPaymentInfo.fromJson(json['appointment']),
    );
  }
}

class AppointmentPaymentInfo {
  final String id;
  final String status;
  final bool isPaid;
  final String paymentId;

  AppointmentPaymentInfo({
    required this.id,
    required this.status,
    required this.isPaid,
    required this.paymentId,
  });

  factory AppointmentPaymentInfo.fromJson(Map<String, dynamic> json) {
    return AppointmentPaymentInfo(
      id: json['id'],
      status: json['status'],
      isPaid: json['is_paid'],
      paymentId: json['payment_id'],
    );
  }
}