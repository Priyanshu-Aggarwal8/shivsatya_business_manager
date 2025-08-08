import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentTransactionWidget extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback? onEdit;
  final VoidCallback? onMarkPaid;

  const RecentTransactionWidget({
    super.key,
    required this.transaction,
    this.onEdit,
    this.onMarkPaid,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactionType = transaction['type'] as String;
    final amount = transaction['amount'] as double;
    final customerName = transaction['customerName'] as String;
    final date = transaction['date'] as DateTime;
    final status = transaction['status'] as String;
    final paymentMethod = transaction['paymentMethod'] as String?;

    return Dismissible(
      key: Key(transaction['id'].toString()),
      background: _buildSwipeBackground(context, true),
      secondaryBackground: _buildSwipeBackground(context, false),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd && onMarkPaid != null) {
          onMarkPaid!();
        } else if (direction == DismissDirection.endToStart && onEdit != null) {
          onEdit!();
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: _getTransactionColor(transactionType)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: _getTransactionIcon(transactionType),
                    color: _getTransactionColor(transactionType),
                    size: 6.w,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            customerName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '₹${amount.toStringAsFixed(0)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            color: transactionType == 'sale'
                                ? AppTheme.successLight
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11.sp,
                          ),
                        ),
                        Row(
                          children: [
                            if (paymentMethod != null) ...[
                              Text(
                                paymentMethod,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 10.sp,
                                ),
                              ),
                              SizedBox(width: 2.w),
                            ],
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 0.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _getStatusColor(status),
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildSwipeBackground(BuildContext context, bool isLeftSwipe) {
    final theme = Theme.of(context);
    final color =
        isLeftSwipe ? AppTheme.successLight : theme.colorScheme.primary;
    final icon = isLeftSwipe ? 'check' : 'edit';
    final text = isLeftSwipe ? 'Mark Paid' : 'Edit';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Row(
          mainAxisAlignment:
              isLeftSwipe ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: Colors.white,
              size: 6.w,
            ),
            SizedBox(width: 2.w),
            Text(
              text,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTransactionColor(String type) {
    switch (type) {
      case 'sale':
        return AppTheme.successLight;
      case 'payment':
        return AppTheme.primaryLight;
      case 'purchase':
        return AppTheme.warningLight;
      default:
        return AppTheme.primaryLight;
    }
  }

  String _getTransactionIcon(String type) {
    switch (type) {
      case 'sale':
        return 'trending_up';
      case 'payment':
        return 'payment';
      case 'purchase':
        return 'shopping_cart';
      default:
        return 'receipt';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppTheme.successLight;
      case 'pending':
        return AppTheme.warningLight;
      case 'overdue':
        return AppTheme.errorLight;
      default:
        return AppTheme.primaryLight;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
