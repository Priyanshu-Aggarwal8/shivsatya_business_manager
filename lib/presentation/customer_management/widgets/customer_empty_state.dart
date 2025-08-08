import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CustomerEmptyState extends StatelessWidget {
  final VoidCallback? onAddCustomer;
  final VoidCallback? onImportContacts;
  final bool showImportOption;

  const CustomerEmptyState({
    super.key,
    this.onAddCustomer,
    this.onImportContacts,
    this.showImportOption = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'people_outline',
                  size: 60,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),

            SizedBox(height: 4.h),

            // Title
            Text(
              'No Customers Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // Description
            Text(
              'Start building your customer database by adding your first customer or importing from your contacts.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 6.h),

            // Action buttons
            Column(
              children: [
                // Add Customer button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onAddCustomer,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'person_add',
                          size: 20,
                          color: theme.colorScheme.onPrimary,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Add Your First Customer',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (showImportOption) ...[
                  SizedBox(height: 2.h),

                  // Import Contacts button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onImportContacts,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'contacts',
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Import from Contacts',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),

            if (showImportOption) ...[
              SizedBox(height: 4.h),

              // Privacy assurance
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'security',
                      size: 20,
                      color: theme.colorScheme.tertiary,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Your contact data is stored securely on your device and never shared without permission.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
