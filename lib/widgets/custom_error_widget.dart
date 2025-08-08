import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';

class CustomErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final bool showRetry;
  final VoidCallback? onRetry;

  const CustomErrorWidget({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'An unexpected error occurred. Please try again.',
    this.actionText,
    this.onAction,
    this.showRetry = true,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.errorLight.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'error_outline',
                color: AppTheme.errorLight,
                size: 15.w,
              ),
            ),

            SizedBox(height: 3.h),

            // Error Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 1.h),

            // Error Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 4.h),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showRetry) ...[
                  ElevatedButton.icon(
                    onPressed: onRetry ??
                        () {
                          // Default retry action - go back or refresh
                          Navigator.of(context).pop();
                        },
                    icon: CustomIconWidget(
                      iconName: 'refresh',
                      color: theme.colorScheme.onPrimary,
                      size: 4.w,
                    ),
                    label: Text('Try Again'),
                  ),
                  if (actionText != null && onAction != null)
                    SizedBox(width: 4.w),
                ],
                if (actionText != null && onAction != null)
                  OutlinedButton(
                    onPressed: onAction,
                    child: Text(actionText!),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Static method for navigation errors
  static Widget navigationError({
    required BuildContext context,
    String? routeName,
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      title: 'Navigation Error',
      message: routeName != null
          ? 'Unable to navigate to $routeName. This feature may not be available.'
          : 'Navigation failed. Please try again.',
      actionText: 'Go Back',
      onAction: () => Navigator.of(context).pop(),
      onRetry: onRetry,
    );
  }

  // Static method for loading errors
  static Widget loadingError({
    required String resource,
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      title: 'Loading Failed',
      message:
          'Failed to load $resource. Please check your connection and try again.',
      onRetry: onRetry,
    );
  }

  // Static method for permission errors
  static Widget permissionError({
    required String permission,
    VoidCallback? onAction,
  }) {
    return CustomErrorWidget(
      title: 'Permission Required',
      message: 'This app needs $permission permission to continue.',
      actionText: 'Grant Permission',
      onAction: onAction,
      showRetry: false,
    );
  }
}
