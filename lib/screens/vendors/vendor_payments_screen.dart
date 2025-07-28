import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';

class VendorPaymentsScreen extends StatefulWidget {
  const VendorPaymentsScreen({Key? key}) : super(key: key);

  @override
  State<VendorPaymentsScreen> createState() => _VendorPaymentsScreenState();
}

class _VendorPaymentsScreenState extends State<VendorPaymentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Earnings', 'Transactions', 'Payouts'];
  
  // Mock data for demonstration
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'TXN1001',
      'customerName': 'Rahul Sharma',
      'serviceName': 'Home Nursing Care',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'amount': 500.0,
      'status': 'Completed',
    },
    {
      'id': 'TXN1002',
      'customerName': 'Priya Patel',
      'serviceName': 'Physiotherapy Session',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'amount': 800.0,
      'status': 'Completed',
    },
    {
      'id': 'TXN1003',
      'customerName': 'Amit Kumar',
      'serviceName': 'Medical Equipment Rental',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'amount': 1200.0,
      'status': 'Completed',
    },
  ];
  
  final List<Map<String, dynamic>> _payouts = [
    {
      'id': 'PYT1001',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'amount': 2000.0,
      'status': 'Processed',
      'accountNumber': 'XXXX1234',
    },
    {
      'id': 'PYT1000',
      'date': DateTime.now().subtract(const Duration(days: 37)),
      'amount': 3500.0,
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
      appBar: AppBar(
        title: const Text('Payments'),
        backgroundColor: AppTheme.primaryBlue,
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
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
    // Calculate total earnings
    double totalEarnings = 0;
    for (var transaction in _transactions) {
      if (transaction['status'] == 'Completed') {
        totalEarnings += transaction['amount'];
      }
    }
    
    // Calculate available balance (earnings minus payouts)
    double totalPayouts = 0;
    for (var payout in _payouts) {
      if (payout['status'] == 'Processed') {
        totalPayouts += payout['amount'];
      }
    }
    
    double availableBalance = totalEarnings - totalPayouts;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Earnings summary card
          Container(
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
                    _buildEarningsStat('Available', '₹$availableBalance', AppTheme.primaryGreen),
                    _buildEarningsStat('Paid Out', '₹$totalPayouts', Colors.orange),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Earnings chart placeholder
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.lightGrey),
            ),
            child: const Center(
              child: Text('Earnings Chart'),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recent transactions
          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._transactions.take(3).map((transaction) => _buildTransactionCard(transaction)),
          
          if (_transactions.length > 3) ...[  
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  _tabController.animateTo(1); // Switch to Transactions tab
                },
                child: const Text('View All Transactions'),
              ),
            ),
          ],
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

  Widget _buildTransactionsTab() {
    return _transactions.isEmpty
        ? const Center(child: Text('No transactions found'))
        : ListView.builder(
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
                Icons.payment,
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
                    '${transaction['serviceName']} - ${transaction['customerName']}',
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    transaction['status'],
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
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

  Widget _buildPayoutsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRequestPayoutCard(),
          const SizedBox(height: 24),
          const Text(
            'Payout History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _payouts.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No payouts found'),
                  ),
                )
              : Column(
                  children: _payouts.map((payout) => _buildPayoutCard(payout)).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildRequestPayoutCard() {
    // Calculate available balance (earnings minus payouts)
    double totalEarnings = 0;
    for (var transaction in _transactions) {
      if (transaction['status'] == 'Completed') {
        totalEarnings += transaction['amount'];
      }
    }
    
    double totalPayouts = 0;
    for (var payout in _payouts) {
      if (payout['status'] == 'Processed') {
        totalPayouts += payout['amount'];
      }
    }
    
    double availableBalance = totalEarnings - totalPayouts;
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available for Payout',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              '₹$availableBalance',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: availableBalance > 0
                    ? () {
                        // Request payout logic
                      }
                    : null,
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
          ],
        ),
      ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPayoutStatusColor(payout['status']).withOpacity(0.1),
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
}