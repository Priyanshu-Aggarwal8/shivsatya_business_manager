import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum PaymentStatus { all, pending, partial, complete }

enum PaymentMethod { all, cash, upi, neft, cheque }

enum SortOption { dueDate, amount, customerName, overdueDuration }

class PaymentFilterBar extends StatelessWidget {
  final PaymentStatus selectedStatus;
  final PaymentMethod selectedMethod;
  final SortOption selectedSort;
  final DateTimeRange? selectedDateRange;
  final String? selectedCustomer;
  final Function(PaymentStatus) onStatusChanged;
  final Function(PaymentMethod) onMethodChanged;
  final Function(SortOption) onSortChanged;
  final Function(DateTimeRange?) onDateRangeChanged;
  final Function(String?) onCustomerChanged;
  final VoidCallback onClearFilters;

  const PaymentFilterBar({
    super.key,
    required this.selectedStatus,
    required this.selectedMethod,
    required this.selectedSort,
    this.selectedDateRange,
    this.selectedCustomer,
    required this.onStatusChanged,
    required this.onMethodChanged,
    required this.onSortChanged,
    required this.onDateRangeChanged,
    required this.onCustomerChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        context,
                        theme,
                        'Status',
                        _getStatusText(selectedStatus),
                        () => _showStatusFilter(context),
                      ),
                      SizedBox(width: 2.w),
                      _buildFilterChip(
                        context,
                        theme,
                        'Method',
                        _getMethodText(selectedMethod),
                        () => _showMethodFilter(context),
                      ),
                      SizedBox(width: 2.w),
                      _buildFilterChip(
                        context,
                        theme,
                        'Sort',
                        _getSortText(selectedSort),
                        () => _showSortFilter(context),
                      ),
                      SizedBox(width: 2.w),
                      _buildFilterChip(
                        context,
                        theme,
                        'Date',
                        selectedDateRange != null ? 'Custom' : 'All',
                        () => _showDateRangePicker(context),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              IconButton(
                onPressed: onClearFilters,
                icon: CustomIconWidget(
                  iconName: 'clear_all',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                tooltip: 'Clear Filters',
              ),
            ],
          ),
          if (selectedCustomer != null) ...[
            SizedBox(height: 1.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'person',
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Customer: $selectedCustomer',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onCustomerChanged(null),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    ThemeData theme,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    final isActive = value != 'All';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: $value',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            SizedBox(width: 1.w),
            CustomIconWidget(
              iconName: 'keyboard_arrow_down',
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterBottomSheet(
        title: 'Payment Status',
        options: PaymentStatus.values
            .map((status) => _FilterOption(
                  value: status,
                  label: _getStatusText(status),
                  isSelected: status == selectedStatus,
                ))
            .toList(),
        onSelected: (value) => onStatusChanged(value as PaymentStatus),
      ),
    );
  }

  void _showMethodFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterBottomSheet(
        title: 'Payment Method',
        options: PaymentMethod.values
            .map((method) => _FilterOption(
                  value: method,
                  label: _getMethodText(method),
                  isSelected: method == selectedMethod,
                ))
            .toList(),
        onSelected: (value) => onMethodChanged(value as PaymentMethod),
      ),
    );
  }

  void _showSortFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterBottomSheet(
        title: 'Sort By',
        options: SortOption.values
            .map((sort) => _FilterOption(
                  value: sort,
                  label: _getSortText(sort),
                  isSelected: sort == selectedSort,
                ))
            .toList(),
        onSelected: (value) => onSortChanged(value as SortOption),
      ),
    );
  }

  void _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: selectedDateRange,
    );
    if (picked != null) {
      onDateRangeChanged(picked);
    }
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.all:
        return 'All';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.partial:
        return 'Partial';
      case PaymentStatus.complete:
        return 'Complete';
    }
  }

  String _getMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.all:
        return 'All';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.neft:
        return 'NEFT';
      case PaymentMethod.cheque:
        return 'Cheque';
    }
  }

  String _getSortText(SortOption sort) {
    switch (sort) {
      case SortOption.dueDate:
        return 'Due Date';
      case SortOption.amount:
        return 'Amount';
      case SortOption.customerName:
        return 'Customer';
      case SortOption.overdueDuration:
        return 'Overdue Days';
    }
  }
}

class _FilterBottomSheet extends StatelessWidget {
  final String title;
  final List<_FilterOption> options;
  final Function(dynamic) onSelected;

  const _FilterBottomSheet({
    required this.title,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          ...options.map((option) => ListTile(
                title: Text(option.label),
                trailing: option.isSelected
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: theme.colorScheme.primary,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  onSelected(option.value);
                  Navigator.pop(context);
                },
              )),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}

class _FilterOption {
  final dynamic value;
  final String label;
  final bool isSelected;

  const _FilterOption({
    required this.value,
    required this.label,
    required this.isSelected,
  });
}
