import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidhya_front_end/screens/subscription_success_screen.dart';
import 'package:vaidhya_front_end/services/api_service.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';
import 'package:vaidhya_front_end/services/api_providers.dart';
import 'package:vaidhya_front_end/models/payment_models.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart'; // Add this import

class SubscriptionScreen extends ConsumerStatefulWidget {
  final String userType;

  const SubscriptionScreen({Key? key, required this.userType})
    : super(key: key);

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isLoading = false;
  int _selectedPaymentMethod = 0;
  late Razorpay _razorpay; // Add this
  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Credit/Debit Card', 'icon': Icons.credit_card},
    {'name': 'UPI', 'icon': Icons.account_balance},
    {'name': 'Net Banking', 'icon': Icons.account_balance_wallet},
  ];
  
  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  
  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }
  
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment success: ${response.paymentId}');
    // Verify payment with backend
    _verifyPayment(
      orderId: response.orderId ?? '',
      paymentId: response.paymentId ?? '',
      signature: response.signature ?? '',
    );
  }
  
  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment error: ${response.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}'))
    );
  }
  
  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External wallet: ${response.walletName}');
  }
  
  void _verifyPayment({required String orderId, required String paymentId, required String signature}) async {
    try {
      final userProfile = await ref.read(userProfileProvider.future);
      final user = userProfile['user'];
      final userId = user != null ? (user['_id'] ?? user['id']) : null;
      
      if (userId == null) {
        throw Exception('User ID not found');
      }
      
      final result = await ref.read(verifyPaymentProvider({
        'orderId': orderId,
        'paymentId': paymentId,
        'signature': signature,
        'userId': userId,
      }).future);
      
      print('Payment verified: $result');
      
      // Navigate to success screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SubscriptionSuccessScreen(userType: widget.userType),
          ),
        );
      }
    } catch (e) {
      print('Error verifying payment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error verifying payment: ${e.toString()}'))
        );
      }
    }
  }

  void _processPayment() async {
    // Add validation before processing
    if (!['doctor', 'hospital', 'vendor'].contains(widget.userType)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subscription not available for ${widget.userType}s'))
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
  
    try {
      // Get the current user ID from the profile
      try {
        print('Attempting to get user profile');
        final userProfile = await ref.read(userProfileProvider.future);
        print('User profile received: $userProfile');
        
        // Access the user object first, then get the ID
        final user = userProfile['user'];
        final userId = user != null ? (user['_id'] ?? user['id']) : null;
        
        if (userId == null) {
          print('User ID is null in profile');
          throw Exception('User ID not found');
        }
        
        print('Creating payment order with user ID: $userId');
        final result = await ref.read(createPaymentOrderProvider(userId).future);
        print('Payment order created: $result');
        
        // Open Razorpay checkout
        var options = {
          'key': result['key_id'],
          'amount': result['order']['amount'], // amount in paise
          'name': 'Vaidhya',
          'order_id': result['order']['id'],
          'description': 'Premium Subscription',
          'prefill': {
            'contact': '',
            'email': ''
          }
        };
        
        _razorpay.open(options);
        
      } catch (e) {
        print('Error in payment processing: $e');
        // Handle authentication errors
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Authentication error: ${e.toString()}'))
          );
          
          // Clear the token and navigate to login
          await ApiService().clearAuthToken();
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String userTypeDisplay =
        widget.userType.substring(0, 1).toUpperCase() +
        widget.userType.substring(1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryBlue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '$userTypeDisplay Subscription',
          style: const TextStyle(color: AppTheme.primaryBlue),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Subscription Card
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Premium Plan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'RECOMMENDED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '₹2,000',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'per year',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    _buildFeatureItem('Unlimited appointments'),
                    _buildFeatureItem('Priority listing'),
                    _buildFeatureItem('24/7 customer support'),
                    _buildFeatureItem('Detailed analytics'),
                    _buildFeatureItem('No commission fees'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Payment Methods
              const Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              // Payment Method Options
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _paymentMethods.length,
                itemBuilder: (context, index) {
                  return _buildPaymentMethodItem(index);
                },
              ),
              const SizedBox(height: 32),
              // Pay Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Pay ₹2,000',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),
              // Secure Payment Note
              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, size: 16, color: AppTheme.textSecondary),
                    SizedBox(width: 4),
                    Text(
                      'Secure Payment',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem(int index) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color:
              _selectedPaymentMethod == index
                  ? AppTheme.primaryBlue
                  : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = index;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                _paymentMethods[index]['icon'],
                color: AppTheme.primaryBlue,
                size: 28,
              ),
              const SizedBox(width: 16),
              Text(
                _paymentMethods[index]['name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Radio(
                value: index,
                groupValue: _selectedPaymentMethod,
                activeColor: AppTheme.primaryBlue,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value as int;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
