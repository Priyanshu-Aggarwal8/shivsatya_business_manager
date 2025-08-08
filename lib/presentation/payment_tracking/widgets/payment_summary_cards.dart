import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PaymentSummaryCards extends StatelessWidget {
  final double totalOutstanding;
  final double overdueAmount;
  final double collectionEfficiency;

  const PaymentSummaryCards({
    super.key,
    required this.totalOutstanding,
    required this.overdueAmount,
    required this.collectionEfficiency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              context,
              theme,
              'Total Outstanding',
              '₹${_formatAmount(totalOutstanding)}',
              CustomIconWidget(
                iconName: 'account_balance_wallet',
                color:
                    AppTheme.warningColor(theme.brightness == Brightness.light),
                size: 24,
              ),
              AppTheme.warningColor(theme.brightness == Brightness.light)
                  .withValues(alpha: 0.1),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: _buildSummaryCard(
              context,
              theme,
              'Overdue',
              '₹${_formatAmount(overdueAmount)}',
              CustomIconWidget(
                iconName: 'warning',
                color:
                    AppTheme.errorColor(theme.brightness == Brightness.light),
                size: 24,
              ),
              AppTheme.errorColor(theme.brightness == Brightness.light)
                  .withValues(alpha: 0.1),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: _buildSummaryCard(
              context,
              theme,
              'Collection Rate',
              '${collectionEfficiency.toStringAsFixed(1)}%',
              CustomIconWidget(
                iconName: 'trending_up',
                color:
                    AppTheme.successColor(theme.brightness == Brightness.light),
                size: 24,
              ),
              AppTheme.successColor(theme.brightness == Brightness.light)
                  .withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    ThemeData theme,
    String title,
    String value,
    Widget icon,
    Color backgroundColor,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              icon,
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
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
}
