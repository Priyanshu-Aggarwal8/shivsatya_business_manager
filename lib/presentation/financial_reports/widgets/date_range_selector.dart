import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum DateRangeType { today, week, month, year, custom }

class DateRangeSelector extends StatefulWidget {
  final DateRangeType selectedRange;
  final ValueChanged<DateRangeType> onRangeChanged;
  final VoidCallback? onCustomDateTap;

  const DateRangeSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
    this.onCustomDateTap,
  });

  @override
  State<DateRangeSelector> createState() => _DateRangeSelectorState();
}

class _DateRangeSelectorState extends State<DateRangeSelector> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildRangeChip(
              context,
              theme,
              'Today',
              DateRangeType.today,
              widget.selectedRange == DateRangeType.today,
            ),
            SizedBox(width: 2.w),
            _buildRangeChip(
              context,
              theme,
              'Week',
              DateRangeType.week,
              widget.selectedRange == DateRangeType.week,
            ),
            SizedBox(width: 2.w),
            _buildRangeChip(
              context,
              theme,
              'Month',
              DateRangeType.month,
              widget.selectedRange == DateRangeType.month,
            ),
            SizedBox(width: 2.w),
            _buildRangeChip(
              context,
              theme,
              'Year',
              DateRangeType.year,
              widget.selectedRange == DateRangeType.year,
            ),
            SizedBox(width: 2.w),
            _buildCustomRangeChip(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeChip(
    BuildContext context,
    ThemeData theme,
    String label,
    DateRangeType rangeType,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => widget.onRangeChanged(rangeType),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomRangeChip(BuildContext context, ThemeData theme) {
    final isSelected = widget.selectedRange == DateRangeType.custom;

    return GestureDetector(
      onTap: () {
        widget.onRangeChanged(DateRangeType.custom);
        widget.onCustomDateTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'calendar_today',
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
            SizedBox(width: 1.w),
            Text(
              'Custom',
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
