import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/business_header_widget.dart';
import './widgets/metric_card_widget.dart';
import './widgets/quick_action_fab_widget.dart';
import './widgets/recent_transaction_widget.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _isOnline = true;
  DateTime _lastSyncTime = DateTime.now();
  int _currentBottomNavIndex = 0;

  // Mock business data
  final String _businessName = "Shiv Satya Enterprises";

  // Mock metrics data
  final List<Map<String, dynamic>> _metricsData = [
    {
      'title': 'Total Sales',
      'value': '₹2,45,680',
      'subtitle': '+12.5% this month',
      'color': AppTheme.successLight,
      'icon': Icons.trending_up,
    },
    {
      'title': 'Profit',
      'value': '18.2%',
      'subtitle': '₹44,723 earned',
      'color': AppTheme.primaryLight,
      'icon': Icons.account_balance_wallet,
    },
    {
      'title': 'Outstanding',
      'value': '₹18,450',
      'subtitle': '12 pending payments',
      'color': AppTheme.warningLight,
      'icon': Icons.payment,
    },
    {
      'title': 'Low Stock',
      'value': '8 Items',
      'subtitle': 'Need restocking',
      'color': AppTheme.errorLight,
      'icon': Icons.inventory,
    },
  ];

  // Mock transactions data
  final List<Map<String, dynamic>> _recentTransactions = [
    {
      'id': 1,
      'type': 'sale',
      'customerName': 'Rajesh Kumar',
      'amount': 15600.0,
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'paid',
      'paymentMethod': 'UPI',
    },
    {
      'id': 2,
      'type': 'sale',
      'customerName': 'Priya Sharma',
      'amount': 8900.0,
      'date': DateTime.now().subtract(const Duration(hours: 5)),
      'status': 'pending',
      'paymentMethod': null,
    },
    {
      'id': 3,
      'type': 'payment',
      'customerName': 'Amit Patel',
      'amount': 12300.0,
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'paid',
      'paymentMethod': 'Cash',
    },
    {
      'id': 4,
      'type': 'sale',
      'customerName': 'Sunita Devi',
      'amount': 5400.0,
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'overdue',
      'paymentMethod': null,
    },
    {
      'id': 5,
      'type': 'purchase',
      'customerName': 'Stock Purchase',
      'amount': 25000.0,
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'paid',
      'paymentMethod': 'NEFT',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppTheme.lightTheme.colorScheme.primary,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: BusinessHeaderWidget(
                businessName: _businessName,
                lastSyncTime: _lastSyncTime,
                isOnline: _isOnline,
                onSyncTap: _handleSync,
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 2.h),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  'Business Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                      ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 2.h),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 2.w,
                      mainAxisSpacing: 2.h,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _metricsData.length,
                    itemBuilder: (context, index) {
                      final metric = _metricsData[index];
                      return MetricCardWidget(
                        title: metric['title'],
                        value: metric['value'],
                        subtitle: metric['subtitle'],
                        indicatorColor: metric['color'],
                        icon: metric['icon'],
                        isLoading: _isLoading,
                        onTap: () => _showMetricDetails(context, metric),
                      );
                    },
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 3.h),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 18.sp,
                          ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/financial-reports'),
                      child: Text(
                        'View All',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 1.h),
            ),
            _recentTransactions.isEmpty
                ? SliverToBoxAdapter(
                    child: _buildEmptyState(context),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final transaction = _recentTransactions[index];
                        return RecentTransactionWidget(
                          transaction: transaction,
                          onEdit: () => _editTransaction(transaction),
                          onMarkPaid: () => _markTransactionPaid(transaction),
                        );
                      },
                      childCount: _recentTransactions.length > 5
                          ? 5
                          : _recentTransactions.length,
                    ),
                  ),
            SliverToBoxAdapter(
              child: SizedBox(height: 10.h),
            ),
          ],
        ),
      ),
      floatingActionButton: QuickActionFabWidget(
        onAddSale: _handleAddSale,
        onRecordPayment: _handleRecordPayment,
        onUpdateStock: _handleUpdateStock,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 8.h,
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(0, 'Dashboard', 'dashboard', '/dashboard'),
              _buildBottomNavItem(
                  1, 'Customers', 'people', '/customer-management'),
              _buildBottomNavItem(
                  2, 'Inventory', 'inventory', '/inventory-management'),
              _buildBottomNavItem(
                  3, 'Payments', 'payment', '/payment-tracking'),
              _buildBottomNavItem(
                  4, 'Reports', 'analytics', '/financial-reports'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
      int index, String label, String iconName, String route) {
    final theme = Theme.of(context);
    final isSelected = index == _currentBottomNavIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onBottomNavTap(index, route),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: iconName,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 6.w,
              ),
              SizedBox(height: 0.5.h),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 10.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 30.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.w),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'receipt_long',
                color: theme.colorScheme.primary,
                size: 10.w,
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'No Transactions Yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Start by adding your first sale or recording a payment',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: _handleAddSale,
            child: Text('Add First Sale'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network request
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _lastSyncTime = DateTime.now();
      _isOnline = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data refreshed successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleSync() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate sync operation
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _lastSyncTime = DateTime.now();
      _isOnline = true;
    });
  }

  void _onBottomNavTap(int index, String route) {
    if (index != _currentBottomNavIndex) {
      setState(() {
        _currentBottomNavIndex = index;
      });

      if (route != '/dashboard') {
        Navigator.pushNamed(context, route);
      }
    }
  }

  void _showMetricDetails(BuildContext context, Map<String, dynamic> metric) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 10.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                '${metric['title']} Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Current Value: ${metric['value']}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 1.h),
              Text(
                metric['subtitle'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: metric['color'],
                    ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Tap and hold on metric cards to select custom date ranges for analysis.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editTransaction(Map<String, dynamic> transaction) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit transaction for ${transaction['customerName']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _markTransactionPaid(Map<String, dynamic> transaction) {
    setState(() {
      final index =
          _recentTransactions.indexWhere((t) => t['id'] == transaction['id']);
      if (index != -1) {
        _recentTransactions[index]['status'] = 'paid';
        _recentTransactions[index]['paymentMethod'] = 'UPI';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment marked for ${transaction['customerName']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleAddSale() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add Sale feature - Navigate to sales screen'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleRecordPayment() {
    Navigator.pushNamed(context, '/payment-tracking');
  }

  void _handleUpdateStock() {
    Navigator.pushNamed(context, '/inventory-management');
  }
}
