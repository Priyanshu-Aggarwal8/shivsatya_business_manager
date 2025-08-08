import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionFabWidget extends StatefulWidget {
  final VoidCallback? onAddSale;
  final VoidCallback? onRecordPayment;
  final VoidCallback? onUpdateStock;

  const QuickActionFabWidget({
    super.key,
    this.onAddSale,
    this.onRecordPayment,
    this.onUpdateStock,
  });

  @override
  State<QuickActionFabWidget> createState() => _QuickActionFabWidgetState();
}

class _QuickActionFabWidgetState extends State<QuickActionFabWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value,
              child: Opacity(
                opacity: _animation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildActionButton(
                      context,
                      theme,
                      'Update Stock',
                      'inventory',
                      AppTheme.warningLight,
                      widget.onUpdateStock,
                    ),
                    SizedBox(height: 2.h),
                    _buildActionButton(
                      context,
                      theme,
                      'Record Payment',
                      'payment',
                      theme.colorScheme.primary,
                      widget.onRecordPayment,
                    ),
                    SizedBox(height: 2.h),
                    _buildActionButton(
                      context,
                      theme,
                      'Add Sale',
                      'add_shopping_cart',
                      AppTheme.successLight,
                      widget.onAddSale,
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            );
          },
        ),
        FloatingActionButton(
          onPressed: _toggleExpanded,
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onSecondary,
          elevation: 6,
          child: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 300),
            child: CustomIconWidget(
              iconName: _isExpanded ? 'close' : 'add',
              color: theme.colorScheme.onSecondary,
              size: 7.w,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    ThemeData theme,
    String label,
    String iconName,
    Color color,
    VoidCallback? onPressed,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 12.sp,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        FloatingActionButton.small(
          onPressed: () {
            _toggleExpanded();
            onPressed?.call();
          },
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 4,
          child: CustomIconWidget(
            iconName: iconName,
            color: Colors.white,
            size: 5.w,
          ),
        ),
      ],
    );
  }
}
