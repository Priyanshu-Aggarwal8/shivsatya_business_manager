import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PaymentListItem extends StatelessWidget {
  final Map<String, dynamic> payment;
  final VoidCallback? onTap;
  final VoidCallback? onMarkPaid;
  final VoidCallback? onRecordPartial;
  final VoidCallback? onSendReminder;
  final VoidCallback? onEdit;
  final VoidCallback? onDispute;
  final bool isSelected;
  final VoidCallback? onSelectionChanged;

  const PaymentListItem({
    super.key,
    required this.payment,
    this.onTap,
    this.onMarkPaid,
    this.onRecordPartial,
    this.onSendReminder,
    this.onEdit,
    this.onDispute,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customerName =
        (payment['customerName'] as String?) ?? 'Unknown Customer';
    final saleDate = payment['saleDate'] as DateTime? ?? DateTime.now();
    final dueAmount = (payment['dueAmount'] as double?) ?? 0.0;
    final paymentMethod = (payment['paymentMethod'] as String?) ?? 'Cash';
    final daysOverdue = (payment['daysOverdue'] as int?) ?? 0;
    final status = (payment['status'] as String?) ?? 'pending';

    return Dismissible(
      key: Key('payment_${payment['id']}'),
      background: _buildSwipeBackground(context, theme, true),
      secondaryBackground: _buildSwipeBackground(context, theme, false),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onMarkPaid?.call();
        } else {
          onEdit?.call();
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onSelectionChanged,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customerName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Sale Date: ${_formatDate(saleDate)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${_formatAmount(dueAmount)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _getAmountColor(theme, status),
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        _buildStatusChip(context, theme, status),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: _getPaymentMethodIcon(paymentMethod),
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            paymentMethod,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (daysOverdue > 0) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: _getOverdueColor(theme, daysOverdue)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'schedule',
                              color: _getOverdueColor(theme, daysOverdue),
                              size: 12,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '$daysOverdue days',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _getOverdueColor(theme, daysOverdue),
                                fontWeight: FontWeight.w600,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(
      BuildContext context, ThemeData theme, bool isLeftSwipe) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLeftSwipe
            ? AppTheme.successColor(theme.brightness == Brightness.light)
            : theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: isLeftSwipe ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: isLeftSwipe ? 'check_circle' : 'edit',
                color: Colors.white,
                size: 24,
              ),
              SizedBox(height: 0.5.h),
              Text(
                isLeftSwipe ? 'Mark Paid' : 'Edit',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(
      BuildContext context, ThemeData theme, String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'complete':
        backgroundColor =
            AppTheme.successColor(theme.brightness == Brightness.light)
                .withValues(alpha: 0.1);
        textColor = AppTheme.successColor(theme.brightness == Brightness.light);
        displayText = 'Paid';
        break;
      case 'partial':
        backgroundColor =
            AppTheme.warningColor(theme.brightness == Brightness.light)
                .withValues(alpha: 0.1);
        textColor = AppTheme.warningColor(theme.brightness == Brightness.light);
        displayText = 'Partial';
        break;
      default:
        backgroundColor =
            AppTheme.errorColor(theme.brightness == Brightness.light)
                .withValues(alpha: 0.1);
        textColor = AppTheme.errorColor(theme.brightness == Brightness.light);
        displayText = 'Pending';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: theme.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  Color _getAmountColor(ThemeData theme, String status) {
    switch (status.toLowerCase()) {
      case 'complete':
        return AppTheme.successColor(theme.brightness == Brightness.light);
      case 'partial':
        return AppTheme.warningColor(theme.brightness == Brightness.light);
      default:
        return AppTheme.errorColor(theme.brightness == Brightness.light);
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
