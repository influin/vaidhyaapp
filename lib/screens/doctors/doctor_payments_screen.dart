import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidhya_front_end/services/api_providers.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';

// Update the class to use ConsumerStatefulWidget
class DoctorPaymentsScreen extends ConsumerStatefulWidget {
  const DoctorPaymentsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DoctorPaymentsScreen> createState() =>
      _DoctorPaymentsScreenState();
}

class _DoctorPaymentsScreenState extends ConsumerState<DoctorPaymentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Earnings', 'Transactions', 'Payouts'];

  // Mock data for demonstration
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'TXN123456',
      'patientName': 'Rahul Sharma',
      'amount': 500.0,
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'Completed',
      'type': 'Video Consultation',
    },
    {
      'id': 'TXN123457',
      'patientName': 'Priya Patel',
      'amount': 1000.0,
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'Completed',
      'type': 'In-person Consultation',
    },
    {
      'id': 'TXN123458',
      'patientName': 'Amit Kumar',
      'amount': 300.0,
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'status': 'Completed',
      'type': 'Follow-up Consultation',
    },
    {
      'id': 'TXN123459',
      'patientName': 'Neha Singh',
      'amount': 500.0,
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'status': 'Refunded',
      'type': 'Video Consultation',
    },
  ];

  final List<Map<String, dynamic>> _payouts = [
    {
      'id': 'PYT123456',
      'amount': 1700.0,
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'status': 'Processed',
      'accountNumber': 'XXXX1234',
    },
    {
      'id': 'PYT123457',
      'amount': 2500.0,
      'date': DateTime.now().subtract(const Duration(days: 14)),
      'status': 'Processed',
      'accountNumber': 'XXXX1234',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEarningsTab(),
          _buildTransactionsTab(),
          _buildPayoutsTab(),
        ],
      ),
    );
  }

  Widget _buildEarningsTab() {
    final earningsAsync = ref.watch(doctorEarningsProvider);

    return earningsAsync.when(
      data: (earnings) {
        // Convert to double explicitly to handle both int and double from API
        final double totalEarnings =
            (earnings['totalEarnings'] is int)
                ? (earnings['totalEarnings'] as int).toDouble()
                : earnings['totalEarnings'] ?? 0.0;
        final double availableBalance =
            (earnings['availableBalance'] is int)
                ? (earnings['availableBalance'] as int).toDouble()
                : earnings['availableBalance'] ?? 0.0;
        final List<dynamic> recentTransactions =
            earnings['recentTransactions'] ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEarningsSummary(totalEarnings, availableBalance),
              const SizedBox(height: 24),
              const Text(
                'Earnings Breakdown',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildEarningsChart(earnings['earningsByType']),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      _tabController.animateTo(1); // Switch to Transactions tab
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...recentTransactions
                  .take(3)
                  .map((transaction) => _buildTransactionCard(transaction))
                  .toList(),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildEarningsSummary(double totalEarnings, double availableBalance) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Total Earnings',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            '₹$totalEarnings',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildEarningsStat(
                'Available',
                '₹$availableBalance',
                AppTheme.primaryGreen,
              ),
              _buildEarningsStat(
                'Pending',
                '₹${totalEarnings - availableBalance}',
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsChart(Map<String, dynamic>? earningsByType) {
    // In a real app, this would be a chart showing earnings by type
    if (earningsByType == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(child: Text('No earnings data available')),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Earnings by Consultation Type'),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children:
                    earningsByType.entries
                        .map(
                          (entry) => ListTile(
                            title: Text(entry.key),
                            trailing: Text(
                              '₹${entry.value is int ? (entry.value as int).toDouble() : entry.value}',
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        return _buildTransactionCard(_transactions[index]);
      },
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final DateTime date = transaction['date'];
    final String formattedDate = '${date.day}/${date.month}/${date.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.medical_services,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction['id'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${transaction['type']} - ${transaction['patientName']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${transaction['amount']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      transaction['status'],
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    transaction['status'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(transaction['status']),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppTheme.primaryGreen;
      case 'Pending':
        return Colors.orange;
      case 'Refunded':
        return Colors.red;
      default:
        return AppTheme.textSecondary;
    }
  }

  Widget _buildPayoutsTab() {
    final payoutHistoryAsync = ref.watch(payoutHistoryProvider);

    return payoutHistoryAsync.when(
      data: (payouts) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: payouts.length + 1, // +1 for the request payout card
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildRequestPayoutCard();
            }
            return _buildPayoutCard(payouts[index - 1]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildPayoutCard(Map<String, dynamic> payout) {
    final DateTime date = payout['date'];
    final String formattedDate = '${date.day}/${date.month}/${date.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payout['id'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Account: ${payout['accountNumber']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${payout['amount']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPayoutStatusColor(
                      payout['status'],
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    payout['status'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getPayoutStatusColor(payout['status']),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPayoutStatusColor(String status) {
    switch (status) {
      case 'Processed':
        return AppTheme.primaryGreen;
      case 'Pending':
        return Colors.orange;
      case 'Failed':
        return Colors.red;
      default:
        return AppTheme.textSecondary;
    }
  }

  // Add a method to update bank details
  void _showBankDetailsDialog() {
    final TextEditingController accountHolderNameController =
        TextEditingController();
    final TextEditingController accountNumberController =
        TextEditingController();
    final TextEditingController ifscCodeController = TextEditingController();
    final TextEditingController bankNameController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Update Bank Details'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: accountHolderNameController,
                    decoration: const InputDecoration(
                      labelText: 'Account Holder Name',
                    ),
                  ),
                  TextField(
                    controller: accountNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Account Number',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: ifscCodeController,
                    decoration: const InputDecoration(labelText: 'IFSC Code'),
                  ),
                  TextField(
                    controller: bankNameController,
                    decoration: const InputDecoration(labelText: 'Bank Name'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  // Call the provider to update bank details
                  ref
                      .read(
                        updateBankDetailsProvider({
                          'accountHolderName': accountHolderNameController.text,
                          'accountNumber': accountNumberController.text,
                          'ifscCode': ifscCodeController.text,
                          'bankName': bankNameController.text,
                        }).future,
                      )
                      .then((response) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              response['message'] ?? 'Bank details updated',
                            ),
                          ),
                        );
                      })
                      .catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $error')),
                        );
                      });
                },
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  // Update the request payout card to include a button to update bank details
  Widget _buildRequestPayoutCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available for Payout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '₹1,200.00',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Request payout logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Request Payout'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _showBankDetailsDialog,
              child: const Text('Update Bank Details'),
            ),
          ],
        ),
      ),
    );
  }
}
