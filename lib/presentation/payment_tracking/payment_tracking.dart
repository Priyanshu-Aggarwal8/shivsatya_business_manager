import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/payment_detail_view.dart';
import './widgets/payment_filter_bar.dart';
import './widgets/payment_list_item.dart';
import './widgets/payment_summary_cards.dart';
import './widgets/quick_payment_dialog.dart';

class PaymentTracking extends StatefulWidget {
  const PaymentTracking({super.key});

  @override
  State<PaymentTracking> createState() => _PaymentTrackingState();
}

class _PaymentTrackingState extends State<PaymentTracking> {
  PaymentStatus _selectedStatus = PaymentStatus.all;
  PaymentMethod _selectedMethod = PaymentMethod.all;
  SortOption _selectedSort = SortOption.dueDate;
  DateTimeRange? _selectedDateRange;
  String? _selectedCustomer;

  final Set<int> _selectedPayments = <int>{};
  bool _isMultiSelectMode = false;

  final List<Map<String, dynamic>> _mockPayments = [
    {
      'id': 1,
      'customerName': 'Rajesh Kumar',
      'saleDate': DateTime.now().subtract(const Duration(days: 45)),
      'dueAmount': 85000.0,
      'paidAmount': 25000.0,
      'paymentMethod': 'UPI',
      'daysOverdue': 15,
      'status': 'partial',
    },
    {
      'id': 2,
      'customerName': 'Priya Sharma',
      'saleDate': DateTime.now().subtract(const Duration(days: 30)),
      'dueAmount': 125000.0,
      'paidAmount': 0.0,
      'paymentMethod': 'NEFT',
      'daysOverdue': 30,
      'status': 'pending',
    },
    {
      'id': 3,
      'customerName': 'Amit Patel',
      'saleDate': DateTime.now().subtract(const Duration(days: 20)),
      'dueAmount': 65000.0,
      'paidAmount': 65000.0,
      'paymentMethod': 'Cash',
      'daysOverdue': 0,
      'status': 'complete',
    },
    {
      'id': 4,
      'customerName': 'Sunita Gupta',
      'saleDate': DateTime.now().subtract(const Duration(days: 60)),
      'dueAmount': 95000.0,
      'paidAmount': 0.0,
      'paymentMethod': 'Cheque',
      'daysOverdue': 45,
      'status': 'pending',
    },
    {
      'id': 5,
      'customerName': 'Vikram Singh',
      'saleDate': DateTime.now().subtract(const Duration(days: 25)),
      'dueAmount': 75000.0,
      'paidAmount': 35000.0,
      'paymentMethod': 'UPI',
      'daysOverdue': 10,
      'status': 'partial',
    },
    {
      'id': 6,
      'customerName': 'Meera Joshi',
      'saleDate': DateTime.now().subtract(const Duration(days: 15)),
      'dueAmount': 110000.0,
      'paidAmount': 110000.0,
      'paymentMethod': 'NEFT',
      'daysOverdue': 0,
      'status': 'complete',
    },
    {
      'id': 7,
      'customerName': 'Ravi Agarwal',
      'saleDate': DateTime.now().subtract(const Duration(days: 35)),
      'dueAmount': 55000.0,
      'paidAmount': 0.0,
      'paymentMethod': 'Cash',
      'daysOverdue': 20,
      'status': 'pending',
    },
    {
      'id': 8,
      'customerName': 'Kavita Reddy',
      'saleDate': DateTime.now().subtract(const Duration(days: 40)),
      'dueAmount': 145000.0,
      'paidAmount': 50000.0,
      'paymentMethod': 'UPI',
      'daysOverdue': 25,
      'status': 'partial',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredPayments = _getFilteredPayments();
    final summaryData = _calculateSummaryData();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Payment Tracking',
        variant: CustomAppBarVariant.standard,
        actions: [
          if (_isMultiSelectMode) ...[
            IconButton(
              onPressed:
                  _selectedPayments.isNotEmpty ? _sendBulkReminders : null,
              icon: CustomIconWidget(
                iconName: 'send',
                color: _selectedPayments.isNotEmpty
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              tooltip: 'Send Reminders',
            ),
            IconButton(
              onPressed:
                  _selectedPayments.isNotEmpty ? _processBulkPayments : null,
              icon: CustomIconWidget(
                iconName: 'payment',
                color: _selectedPayments.isNotEmpty
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              tooltip: 'Process Payments',
            ),
            IconButton(
              onPressed: _exitMultiSelectMode,
              icon: CustomIconWidget(
                iconName: 'close',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              tooltip: 'Exit Selection',
            ),
          ] else ...[
            IconButton(
              onPressed: () {
                // Handle search
              },
              icon: CustomIconWidget(
                iconName: 'search',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            PopupMenuButton<String>(
              icon: CustomIconWidget(
                iconName: 'more_vert',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              onSelected: _handleMenuSelection,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.download, size: 18),
                      SizedBox(width: 12),
                      Text('Export Data'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, size: 18),
                      SizedBox(width: 12),
                      Text('Settings'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPayments,
        child: Column(
          children: [
            PaymentSummaryCards(
              totalOutstanding: summaryData['totalOutstanding'] as double,
              overdueAmount: summaryData['overdueAmount'] as double,
              collectionEfficiency:
                  summaryData['collectionEfficiency'] as double,
            ),
            PaymentFilterBar(
              selectedStatus: _selectedStatus,
              selectedMethod: _selectedMethod,
              selectedSort: _selectedSort,
              selectedDateRange: _selectedDateRange,
              selectedCustomer: _selectedCustomer,
              onStatusChanged: (status) {
                setState(() {
                  _selectedStatus = status;
                });
              },
              onMethodChanged: (method) {
                setState(() {
                  _selectedMethod = method;
                });
              },
              onSortChanged: (sort) {
                setState(() {
                  _selectedSort = sort;
                });
              },
              onDateRangeChanged: (dateRange) {
                setState(() {
                  _selectedDateRange = dateRange;
                });
              },
              onCustomerChanged: (customer) {
                setState(() {
                  _selectedCustomer = customer;
                });
              },
              onClearFilters: _clearAllFilters,
            ),
            Expanded(
              child: filteredPayments.isEmpty
                  ? _buildEmptyState(theme)
                  : ListView.builder(
                      itemCount: filteredPayments.length,
                      itemBuilder: (context, index) {
                        final payment = filteredPayments[index];
                        final paymentId = payment['id'] as int;

                        return PaymentListItem(
                          payment: payment,
                          isSelected: _selectedPayments.contains(paymentId),
                          onTap: () => _showPaymentDetail(payment),
                          onSelectionChanged: () =>
                              _togglePaymentSelection(paymentId),
                          onMarkPaid: () => _markPaymentPaid(payment),
                          onRecordPartial: () => _recordPartialPayment(payment),
                          onSendReminder: () => _sendPaymentReminder(payment),
                          onEdit: () => _editPayment(payment),
                          onDispute: () => _disputePayment(payment),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickPaymentDialog,
        child: CustomIconWidget(
          iconName: 'add',
          color: theme.colorScheme.onSecondary,
          size: 24,
        ),
        tooltip: 'Record Payment',
      ),
      bottomNavigationBar: const CustomBottomBar(
        currentIndex: 3,
        variant: CustomBottomBarVariant.standard,
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'payment',
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 64,
            ),
            SizedBox(height: 3.h),
            Text(
              'No Payments Found',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'No payments match your current filters. Try adjusting your search criteria.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: _clearAllFilters,
              icon: CustomIconWidget(
                iconName: 'clear_all',
                color: theme.colorScheme.onPrimary,
                size: 16,
              ),
              label: Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredPayments() {
    List<Map<String, dynamic>> filtered = List.from(_mockPayments);

    // Filter by status
    if (_selectedStatus != PaymentStatus.all) {
      filtered = filtered.where((payment) {
        final status = payment['status'] as String;
        switch (_selectedStatus) {
          case PaymentStatus.pending:
            return status == 'pending';
          case PaymentStatus.partial:
            return status == 'partial';
          case PaymentStatus.complete:
            return status == 'complete';
          default:
            return true;
        }
      }).toList();
    }

    // Filter by payment method
    if (_selectedMethod != PaymentMethod.all) {
      filtered = filtered.where((payment) {
        final method = (payment['paymentMethod'] as String).toLowerCase();
        switch (_selectedMethod) {
          case PaymentMethod.cash:
            return method == 'cash';
          case PaymentMethod.upi:
            return method == 'upi';
          case PaymentMethod.neft:
            return method == 'neft';
          case PaymentMethod.cheque:
            return method == 'cheque';
          default:
            return true;
        }
      }).toList();
    }

    // Filter by date range
    if (_selectedDateRange != null) {
      filtered = filtered.where((payment) {
        final saleDate = payment['saleDate'] as DateTime;
        return saleDate.isAfter(
                _selectedDateRange!.start.subtract(const Duration(days: 1))) &&
            saleDate
                .isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Filter by customer
    if (_selectedCustomer != null) {
      filtered = filtered.where((payment) {
        final customerName = (payment['customerName'] as String).toLowerCase();
        return customerName.contains(_selectedCustomer!.toLowerCase());
      }).toList();
    }

    // Sort payments
    filtered.sort((a, b) {
      switch (_selectedSort) {
        case SortOption.dueDate:
          return (a['saleDate'] as DateTime)
              .compareTo(b['saleDate'] as DateTime);
        case SortOption.amount:
          return (b['dueAmount'] as double).compareTo(a['dueAmount'] as double);
        case SortOption.customerName:
          return (a['customerName'] as String)
              .compareTo(b['customerName'] as String);
        case SortOption.overdueDuration:
          return (b['daysOverdue'] as int).compareTo(a['daysOverdue'] as int);
      }
    });

    return filtered;
  }

  Map<String, dynamic> _calculateSummaryData() {
    double totalOutstanding = 0.0;
    double overdueAmount = 0.0;
    double totalSales = 0.0;
    double totalPaid = 0.0;

    for (final payment in _mockPayments) {
      final dueAmount = payment['dueAmount'] as double;
      final paidAmount = payment['paidAmount'] as double;
      final daysOverdue = payment['daysOverdue'] as int;

      totalSales += dueAmount;
      totalPaid += paidAmount;

      final remainingAmount = dueAmount - paidAmount;
      if (remainingAmount > 0) {
        totalOutstanding += remainingAmount;
        if (daysOverdue > 0) {
          overdueAmount += remainingAmount;
        }
      }
    }

    final collectionEfficiency =
        totalSales > 0 ? (totalPaid / totalSales) * 100 : 0.0;

    return {
      'totalOutstanding': totalOutstanding,
      'overdueAmount': overdueAmount,
      'collectionEfficiency': collectionEfficiency,
    };
  }

  void _clearAllFilters() {
    setState(() {
      _selectedStatus = PaymentStatus.all;
      _selectedMethod = PaymentMethod.all;
      _selectedSort = SortOption.dueDate;
      _selectedDateRange = null;
      _selectedCustomer = null;
    });
  }

  void _togglePaymentSelection(int paymentId) {
    setState(() {
      if (_selectedPayments.contains(paymentId)) {
        _selectedPayments.remove(paymentId);
        if (_selectedPayments.isEmpty) {
          _isMultiSelectMode = false;
        }
      } else {
        _selectedPayments.add(paymentId);
        _isMultiSelectMode = true;
      }
    });
  }

  void _exitMultiSelectMode() {
    setState(() {
      _selectedPayments.clear();
      _isMultiSelectMode = false;
    });
  }

  void _showPaymentDetail(Map<String, dynamic> payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentDetailView(
        payment: payment,
        onEdit: () {
          Navigator.pop(context);
          _editPayment(payment);
        },
        onMarkPaid: () {
          Navigator.pop(context);
          _markPaymentPaid(payment);
        },
        onSendReminder: () {
          Navigator.pop(context);
          _sendPaymentReminder(payment);
        },
      ),
    );
  }

  void _showQuickPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => QuickPaymentDialog(
        onPaymentRecorded: (paymentData) {
          setState(() {
            _mockPayments.add({
              'id': paymentData['id'],
              'customerName': paymentData['customerName'],
              'saleDate': paymentData['paymentDate'],
              'dueAmount': paymentData['amount'],
              'paidAmount': paymentData['paymentType'] == 'Lumpsum'
                  ? paymentData['amount']
                  : 0.0,
              'paymentMethod': paymentData['paymentMethod'],
              'daysOverdue': 0,
              'status': paymentData['status'],
            });
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment recorded successfully'),
              backgroundColor: AppTheme.successColor(
                  Theme.of(context).brightness == Brightness.light),
            ),
          );
        },
      ),
    );
  }

  void _editPayment(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => QuickPaymentDialog(
        existingPayment: payment,
        onPaymentRecorded: (paymentData) {
          setState(() {
            final index =
                _mockPayments.indexWhere((p) => p['id'] == payment['id']);
            if (index != -1) {
              _mockPayments[index] = {
                ..._mockPayments[index],
                'customerName': paymentData['customerName'],
                'dueAmount': paymentData['amount'],
                'paymentMethod': paymentData['paymentMethod'],
                'saleDate': paymentData['paymentDate'],
              };
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment updated successfully'),
              backgroundColor: AppTheme.successColor(
                  Theme.of(context).brightness == Brightness.light),
            ),
          );
        },
      ),
    );
  }

  void _markPaymentPaid(Map<String, dynamic> payment) {
    setState(() {
      final index = _mockPayments.indexWhere((p) => p['id'] == payment['id']);
      if (index != -1) {
        _mockPayments[index]['paidAmount'] = _mockPayments[index]['dueAmount'];
        _mockPayments[index]['status'] = 'complete';
        _mockPayments[index]['daysOverdue'] = 0;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment marked as paid'),
        backgroundColor: AppTheme.successColor(
            Theme.of(context).brightness == Brightness.light),
      ),
    );
  }

  void _recordPartialPayment(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => QuickPaymentDialog(
        existingPayment: payment,
        onPaymentRecorded: (paymentData) {
          setState(() {
            final index =
                _mockPayments.indexWhere((p) => p['id'] == payment['id']);
            if (index != -1) {
              final currentPaid = _mockPayments[index]['paidAmount'] as double;
              _mockPayments[index]['paidAmount'] =
                  currentPaid + paymentData['amount'];

              final totalDue = _mockPayments[index]['dueAmount'] as double;
              final newPaidAmount =
                  _mockPayments[index]['paidAmount'] as double;

              if (newPaidAmount >= totalDue) {
                _mockPayments[index]['status'] = 'complete';
                _mockPayments[index]['daysOverdue'] = 0;
              } else {
                _mockPayments[index]['status'] = 'partial';
              }
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Partial payment recorded'),
              backgroundColor: AppTheme.successColor(
                  Theme.of(context).brightness == Brightness.light),
            ),
          );
        },
      ),
    );
  }

  void _sendPaymentReminder(Map<String, dynamic> payment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment reminder sent to ${payment['customerName']}'),
        backgroundColor: AppTheme.successColor(
            Theme.of(context).brightness == Brightness.light),
      ),
    );
  }

  void _disputePayment(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dispute Payment'),
        content: Text(
            'Mark this payment as disputed? This will flag it for review.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment marked as disputed'),
                  backgroundColor: AppTheme.warningColor(
                      Theme.of(context).brightness == Brightness.light),
                ),
              );
            },
            child: Text('Mark Disputed'),
          ),
        ],
      ),
    );
  }

  void _sendBulkReminders() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Reminders sent to ${_selectedPayments.length} customers'),
        backgroundColor: AppTheme.successColor(
            Theme.of(context).brightness == Brightness.light),
      ),
    );
    _exitMultiSelectMode();
  }

  void _processBulkPayments() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Process Bulk Payments'),
        content: Text(
            'Process payments for ${_selectedPayments.length} selected entries?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('${_selectedPayments.length} payments processed'),
                  backgroundColor: AppTheme.successColor(
                      Theme.of(context).brightness == Brightness.light),
                ),
              );
              _exitMultiSelectMode();
            },
            child: Text('Process'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshPayments() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Refresh payment data
    });
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'export':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exporting payment data...'),
            backgroundColor: AppTheme.successColor(
                Theme.of(context).brightness == Brightness.light),
          ),
        );
        break;
      case 'settings':
        // Navigate to settings
        break;
    }
  }
}
