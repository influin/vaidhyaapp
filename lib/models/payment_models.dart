import 'package:flutter/material.dart';

class PaymentOrder {
  final String id;
  final String entity;
  final int amount;
  final int amountPaid;
  final int amountDue;
  final String currency;
  final String receipt;
  final String status;
  final int attempts;
  final List<dynamic> notes;
  final int createdAt;
  final String keyId;

  PaymentOrder({
    required this.id,
    required this.entity,
    required this.amount,
    required this.amountPaid,
    required this.amountDue,
    required this.currency,
    required this.receipt,
    required this.status,
    required this.attempts,
    required this.notes,
    required this.createdAt,
    required this.keyId,
  });

  factory PaymentOrder.fromJson(Map<String, dynamic> json) {
    final orderData = json['order'];
    return PaymentOrder(
      id: orderData['id'],
      entity: orderData['entity'],
      amount: orderData['amount'],
      amountPaid: orderData['amount_paid'],
      amountDue: orderData['amount_due'],
      currency: orderData['currency'],
      receipt: orderData['receipt'],
      status: orderData['status'],
      attempts: orderData['attempts'],
      notes: orderData['notes'],
      createdAt: orderData['created_at'],
      keyId: json['key_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': {
        'id': id,
        'entity': entity,
        'amount': amount,
        'amount_paid': amountPaid,
        'amount_due': amountDue,
        'currency': currency,
        'receipt': receipt,
        'status': status,
        'attempts': attempts,
        'notes': notes,
        'created_at': createdAt,
      },
      'key_id': keyId,
    };
  }
}

class Subscription {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime expiryDate;
  final bool isActive;
  final String plan; // e.g., 'Premium'
  final double amount;
  final String currency;
  final String? paymentId;

  Subscription({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.expiryDate,
    required this.isActive,
    required this.plan,
    required this.amount,
    required this.currency,
    this.paymentId,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      userId: json['userId'],
      startDate: DateTime.parse(json['startDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      isActive: json['isActive'],
      plan: json['plan'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      paymentId: json['paymentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'startDate': startDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'isActive': isActive,
      'plan': plan,
      'amount': amount,
      'currency': currency,
      'paymentId': paymentId,
    };
  }
}