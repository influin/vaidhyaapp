import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vaidhya_front_end/models/appointment_models.dart';
import 'package:vaidhya_front_end/services/api_providers.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/widgets/custom_app_bar.dart';
import 'package:vaidhya_front_end/screens/appointment_success_screen.dart';

class PatientDetailsScreen extends ConsumerStatefulWidget {
  final String doctorId;
  final String doctorName;
  final DateTime selectedDateTime;
  final String consultationType;
  final String notes;

  const PatientDetailsScreen({
    Key? key,
    required this.doctorId,
    required this.doctorName,
    required this.selectedDateTime,
    required this.consultationType,
    required this.notes,
  }) : super(key: key);

  @override
  ConsumerState<PatientDetailsScreen> createState() =>
      _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends ConsumerState<PatientDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late Razorpay _razorpay;
  bool _isLoading = false;

  // Form controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _currentMedicationsController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedRelationship = 'self';

  DoctorBookingResponse? _bookingResponse;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: CustomAppBar(title: 'Patient Details', showBackButton: true),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildPatientForm(),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildPatientForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppointmentSummary(),
            const SizedBox(height: 24),
            _buildPatientDetailsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appointment Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Doctor', 'Dr. ${widget.doctorName}'),
          _buildSummaryRow(
            'Date',
            '${widget.selectedDateTime.day}/${widget.selectedDateTime.month}/${widget.selectedDateTime.year}',
          ),
          _buildSummaryRow(
            'Time',
            '${widget.selectedDateTime.hour.toString().padLeft(2, '0')}:${widget.selectedDateTime.minute.toString().padLeft(2, '0')}',
          ),
          _buildSummaryRow('Type', widget.consultationType.toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Enter patient full name',
            validator:
                (value) => value?.isEmpty == true ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _ageController,
                  label: 'Age',
                  hint: 'Enter age',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Age is required';
                    final age = int.tryParse(value!);
                    if (age == null || age < 1 || age > 120) {
                      return 'Enter valid age';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  label: 'Gender',
                  value: _selectedGender,
                  items: ['Male', 'Female', 'Other'],
                  onChanged:
                      (value) => setState(() => _selectedGender = value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: 'Enter phone number',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isEmpty == true) return 'Phone number is required';
              if (value!.length < 10) return 'Enter valid phone number';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'Enter email address',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty == true) return 'Email is required';
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value!)) {
                return 'Enter valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Relationship to Customer',
            value: _selectedRelationship,
            items: ['self', 'spouse', 'child', 'parent', 'sibling', 'other'],
            onChanged:
                (value) => setState(() => _selectedRelationship = value!),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _medicalHistoryController,
            label: 'Medical History',
            hint: 'Enter any relevant medical history',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _allergiesController,
            label: 'Allergies',
            hint: 'Enter any known allergies',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _currentMedicationsController,
            label: 'Current Medications',
            hint: 'Enter current medications',
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.primaryBlue),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items:
              items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item.toUpperCase()),
                );
              }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.primaryBlue),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _bookAppointment,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _isLoading ? 'Processing...' : 'Book Appointment & Pay',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _bookAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final patientDetails = PatientDetails(
        name: _nameController.text,
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        phone: _phoneController.text,
        email: _emailController.text,
        relationshipToCustomer: _selectedRelationship,
        medicalHistory:
            _medicalHistoryController.text.isEmpty
                ? 'None'
                : _medicalHistoryController.text,
        allergies:
            _allergiesController.text.isEmpty
                ? 'None'
                : _allergiesController.text,
        currentMedications:
            _currentMedicationsController.text.isEmpty
                ? 'None'
                : _currentMedicationsController.text,
      );

      final bookingRequest = DoctorBookingRequest(
        doctorId: widget.doctorId,
        consultationType: widget.consultationType,
        dateTime: widget.selectedDateTime,
        notes:
            widget.notes.isEmpty
                ? 'Appointment booking via mobile app'
                : widget.notes,
        patientDetails: patientDetails,
      );

      // Debug: Print booking request data
      print('=== BOOKING REQUEST DATA ===');
      print('Doctor ID: ${widget.doctorId}');
      print('Consultation Type: ${widget.consultationType}');
      print('Date Time: ${widget.selectedDateTime}');
      print(
        'Notes: ${widget.notes.isEmpty ? 'Appointment booking via mobile app' : widget.notes}',
      );
      print('Patient Details:');
      print('  Name: ${_nameController.text}');
      print('  Age: ${_ageController.text}');
      print('  Gender: $_selectedGender');
      print('  Phone: ${_phoneController.text}');
      print('  Email: ${_emailController.text}');
      print('  Relationship: $_selectedRelationship');
      print(
        '  Medical History: ${_medicalHistoryController.text.isEmpty ? 'None' : _medicalHistoryController.text}',
      );
      print(
        '  Allergies: ${_allergiesController.text.isEmpty ? 'None' : _allergiesController.text}',
      );
      print(
        '  Current Medications: ${_currentMedicationsController.text.isEmpty ? 'None' : _currentMedicationsController.text}',
      );
      print('========================');

      final response = await ref.read(
        bookDoctorAppointmentProvider(bookingRequest).future,
      );
      _bookingResponse = response;

      // Debug: Print booking response data
      print('=== BOOKING RESPONSE DATA ===');
      print('Message: ${response.message}');
      print('Appointment ID: ${response.appointment.id}');
      print('Appointment Status: ${response.appointment.status}');
      print('Order Details:');
      print('  Order ID: ${response.order.id}');
      print('  Amount: ${response.order.amount}');
      print('  Currency: ${response.order.currency}');
      print('  Status: ${response.order.status}');
      print('Key ID from response: ${response.keyId}'); // Update this line
      print('============================');

      // Open Razorpay payment
      _openRazorpayPayment(
        response,
      ); // Pass the full response instead of just the order
    } catch (e) {
      setState(() => _isLoading = false);
      print('=== BOOKING ERROR ===');
      print('Error: $e');
      print('Error Type: ${e.runtimeType}');
      print('==================');
      _showErrorDialog('Failed to book appointment: $e');
    }
  }

  void _openRazorpayPayment(DoctorBookingResponse response) {
    // Debug: Print payment options
    print('=== RAZORPAY PAYMENT OPTIONS ===');
    print('Key: ${response.keyId ?? 'rzp_test_Okqp9dPTY8vzdZ'}');
    print('Amount: ${response.order.amount}');
    print('Order ID: ${response.order.id}');
    print('Contact: ${_phoneController.text}');
    print('Email: ${_emailController.text}');
    print('===============================');

    var options = {
      'key':
          response.keyId ??
          'rzp_test_1DP5mmOlF5G5ag', // Use keyId from response
      'amount': response.order.amount,
      'name': 'Vaidhya',
      'description': 'Doctor Appointment Payment',
      'order_id': response.order.id,
      'prefill': {
        'contact': _phoneController.text,
        'email': _emailController.text,
      },
      'theme': {'color': '#2E7D32'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isLoading = false);
      print('=== RAZORPAY OPEN ERROR ===');
      print('Error: $e');
      print('Error Type: ${e.runtimeType}');
      print('=========================');
      _showErrorDialog('Failed to open payment: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isLoading = true);
    
    try {
      // Add debug logging
      print('=== PAYMENT VERIFICATION DEBUG ===');
      print('Appointment ID being sent: ${_bookingResponse!.appointment.id}');
      print('Razorpay Payment ID: ${response.paymentId}');
      print('Razorpay Order ID: ${response.orderId}');
      print('Razorpay Signature: ${response.signature}');
      
      final verificationRequest = PaymentVerificationRequest(
        appointmentId: _bookingResponse!.appointment.id,
        razorpayPaymentId: response.paymentId!,
        razorpayOrderId: response.orderId!,
        razorpaySignature: response.signature!,
      );
      
      // Log the complete request being sent
      print('Complete verification request: ${verificationRequest.toJson()}');
      
      final verificationResponse = await ref.read(
        verifyAppointmentPaymentProvider(verificationRequest).future,
      );
      
      setState(() => _isLoading = false);
      
      // Navigate to success screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => AppointmentSuccessScreen(
                appointmentId: verificationResponse.appointment.id,
                doctorName: widget.doctorName,
                appointmentDateTime: widget.selectedDateTime,
              ),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      print('Payment verification error details: $e');
      _showErrorDialog('Payment verification failed: $e');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isLoading = false);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Payment Failed'),
            content: Text(
              'Payment failed: ${response.message}\n\nWould you like to try again?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (_bookingResponse != null) {
                    _openRazorpayPayment(_bookingResponse!);
                  }
                },
                child: const Text('Retry'),
              ),
            ],
          ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _isLoading = false);
    _showErrorDialog('External wallet selected: ${response.walletName}');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _medicalHistoryController.dispose();
    _allergiesController.dispose();
    _currentMedicationsController.dispose();
    super.dispose();
  }
}
