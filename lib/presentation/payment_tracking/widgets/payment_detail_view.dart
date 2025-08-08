import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PaymentDetailView extends StatelessWidget {
  final Map<String, dynamic> payment;
  final VoidCallback? onEdit;
  final VoidCallback? onMarkPaid;
  final VoidCallback? onSendReminder;

  const PaymentDetailView({
    super.key,
    required this.payment,
    this.onEdit,
    this.onMarkPaid,
    this.onSendReminder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customerName =
        (payment['customerName'] as String?) ?? 'Unknown Customer';
    final saleDate = payment['saleDate'] as DateTime? ?? DateTime.now();
    final dueAmount = (payment['dueAmount'] as double?) ?? 0.0;
    final paidAmount = (payment['paidAmount'] as double?) ?? 0.0;
    final paymentMethod = (payment['paymentMethod'] as String?) ?? 'Cash';
    final daysOverdue = (payment['daysOverdue'] as int?) ?? 0;
    final status = (payment['status'] as String?) ?? 'pending';

    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context, theme),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCustomerInfo(theme, customerName, saleDate),
                  SizedBox(height: 3.h),
                  _buildPaymentSummary(theme, dueAmount, paidAmount, status),
                  SizedBox(height: 3.h),
                  _buildPaymentDetails(theme, paymentMethod, daysOverdue),
                  SizedBox(height: 3.h),
                  _buildPaymentHistory(theme),
                  SizedBox(height: 3.h),
                  _buildCommunicationLog(theme),
                  SizedBox(height: 3.h),
                  _buildInstallmentOptions(theme),
                ],
              ),
            ),
          ),
          _buildActionButtons(context, theme),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Payment Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'close',
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(
      ThemeData theme, String customerName, DateTime saleDate) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'person',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  customerName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'calendar_today',
                color: theme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
              SizedBox(width: 2.w),
              Text(
                'Sale Date: ${_formatDate(saleDate)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(
      ThemeData theme, double dueAmount, double paidAmount, String status) {
    final remainingAmount = dueAmount - paidAmount;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount:',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '₹${_formatAmount(dueAmount)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Paid Amount:',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '₹${_formatAmount(paidAmount)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.successColor(
                      theme.brightness == Brightness.light),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Divider(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Remaining:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '₹${_formatAmount(remainingAmount)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: remainingAmount > 0
                      ? AppTheme.errorColor(
                          theme.brightness == Brightness.light)
                      : AppTheme.successColor(
                          theme.brightness == Brightness.light),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails(
      ThemeData theme, String paymentMethod, int daysOverdue) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: _getPaymentMethodIcon(paymentMethod),
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              SizedBox(width: 3.w),
              Text(
                'Payment Method: $paymentMethod',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          if (daysOverdue > 0) ...[
            SizedBox(height: 2.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: _getOverdueColor(theme, daysOverdue),
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Overdue: $daysOverdue days',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _getOverdueColor(theme, daysOverdue),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentHistory(ThemeData theme) {
    final List<Map<String, dynamic>> paymentHistory = [
      {
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'amount': 15000.0,
        'method': 'UPI',
        'status': 'completed',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 15)),
        'amount': 10000.0,
        'method': 'Cash',
        'status': 'completed',
      },
    ];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment History',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          ...paymentHistory.map((history) => Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.successColor(
                            theme.brightness == Brightness.light),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${_formatAmount(history['amount'] as double)} - ${history['method']}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatDate(history['date'] as DateTime),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCommunicationLog(ThemeData theme) {
    final List<Map<String, dynamic>> communications = [
      {
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'type': 'reminder',
        'message': 'Payment reminder sent via SMS',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 7)),
        'type': 'call',
        'message': 'Follow-up call made',
      },
    ];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Communication Log',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          ...communications.map((comm) => Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: comm['type'] == 'reminder'
                          ? 'notifications'
                          : 'phone',
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comm['message'] as String,
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            _formatDate(comm['date'] as DateTime),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildInstallmentOptions(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Installment Options',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Allow customer to pay in installments with flexible payment schedules.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),
          OutlinedButton(
            onPressed: () {
              // Handle installment setup
            },
            child: Text('Setup Installments'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onSendReminder,
              icon: CustomIconWidget(
                iconName: 'send',
                color: theme.colorScheme.primary,
                size: 16,
              ),
              label: Text('Send Reminder'),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: CustomIconWidget(
                iconName: 'edit',
                color: theme.colorScheme.primary,
                size: 16,
              ),
              label: Text('Edit'),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onMarkPaid,
              icon: CustomIconWidget(
                iconName: 'check_circle',
                color: theme.colorScheme.onPrimary,
                size: 16,
              ),
              label: Text('Mark Paid'),
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'upi':
        return 'qr_code';
      case 'neft':
        return 'account_balance';
      case 'cheque':
        return 'receipt';
      default:
        return 'payments';
    }
  }

  Color _getOverdueColor(ThemeData theme, int days) {
    if (days > 30) {
      return AppTheme.errorColor(theme.brightness == Brightness.light);
    } else if (days > 15) {
      return AppTheme.warningColor(theme.brightness == Brightness.light);
    } else {
      return theme.colorScheme.onSurfaceVariant;
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
