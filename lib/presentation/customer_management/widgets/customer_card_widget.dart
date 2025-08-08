import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CustomerCardWidget extends StatelessWidget {
  final Map<String, dynamic> customer;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;
  final VoidCallback? onViewHistory;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;
  final bool isSelected;

  const CustomerCardWidget({
    super.key,
    required this.customer,
    this.onTap,
    this.onCall,
    this.onMessage,
    this.onViewHistory,
    this.onEdit,
    this.onArchive,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customerName = customer['name'] as String? ?? 'Unknown';
    final phone = customer['phone'] as String? ?? '';
    final totalPurchases = customer['totalPurchases'] as double? ?? 0.0;
    final lastTransaction = customer['lastTransaction'] as DateTime?;

    return Dismissible(
      key: Key(customer['id'].toString()),
      background: _buildSwipeBackground(context, theme, true),
      secondaryBackground: _buildSwipeBackground(context, theme, false),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          // Right swipe - quick actions
          _showQuickActions(context);
        } else {
          // Left swipe - edit/archive
          _showEditActions(context);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
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
              color: theme.colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  _buildAvatar(context, theme, customerName),
                  SizedBox(width: 3.w),
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
                        if (phone.isNotEmpty) ...[
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'phone',
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              SizedBox(width: 1.w),
                              Expanded(
                                child: Text(
                                  phone,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: 1.h),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Purchases',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    '₹${totalPurchases.toStringAsFixed(2)}',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (lastTransaction != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Last Transaction',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    _formatDate(lastTransaction),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    CustomIconWidget(
                      iconName: 'check_circle',
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, ThemeData theme, String name) {
    final initials = _getInitials(name);
    final avatarColor = _getAvatarColor(name, theme);

    return Container(
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        color: avatarColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(
      BuildContext context, ThemeData theme, bool isRightSwipe) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color:
            isRightSwipe ? theme.colorScheme.tertiary : theme.colorScheme.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: isRightSwipe ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isRightSwipe) ...[
                CustomIconWidget(
                  iconName: 'phone',
                  size: 24,
                  color: Colors.white,
                ),
                SizedBox(width: 2.w),
                CustomIconWidget(
                  iconName: 'message',
                  size: 24,
                  color: Colors.white,
                ),
                SizedBox(width: 2.w),
                CustomIconWidget(
                  iconName: 'history',
                  size: 24,
                  color: Colors.white,
                ),
              ] else ...[
                CustomIconWidget(
                  iconName: 'edit',
                  size: 24,
                  color: Colors.white,
                ),
                SizedBox(width: 2.w),
                CustomIconWidget(
                  iconName: 'archive',
                  size: 24,
                  color: Colors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'phone',
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Call Customer'),
              onTap: () {
                Navigator.pop(context);
                onCall?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'message',
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Send Message'),
              onTap: () {
                Navigator.pop(context);
                onMessage?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'history',
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('View Sales History'),
              onTap: () {
                Navigator.pop(context);
                onViewHistory?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Edit Customer'),
              onTap: () {
                Navigator.pop(context);
                onEdit?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'archive',
                size: 24,
                color: Theme.of(context).colorScheme.error,
              ),
              title: const Text('Archive Customer'),
              onTap: () {
                Navigator.pop(context);
                onArchive?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return 'U';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  Color _getAvatarColor(String name, ThemeData theme) {
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      const Color(0xFF9C27B0),
      const Color(0xFF673AB7),
      const Color(0xFF3F51B5),
      const Color(0xFF2196F3),
      const Color(0xFF00BCD4),
      const Color(0xFF009688),
      const Color(0xFF4CAF50),
      const Color(0xFF8BC34A),
      const Color(0xFFCDDC39),
      const Color(0xFFFFEB3B),
      const Color(0xFFFFC107),
      const Color(0xFFFF9800),
      const Color(0xFFFF5722),
    ];

    final hash = name.hashCode;
    return colors[hash.abs() % colors.length];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
