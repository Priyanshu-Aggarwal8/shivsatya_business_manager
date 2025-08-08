import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExportMenu extends StatelessWidget {
  final VoidCallback? onExportPDF;
  final VoidCallback? onExportCSV;
  final VoidCallback? onShare;

  const ExportMenu({
    super.key,
    this.onExportPDF,
    this.onExportCSV,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<String>(
      icon: CustomIconWidget(
        iconName: 'file_download',
        color: theme.colorScheme.onSurfaceVariant,
        size: 24,
      ),
      onSelected: (value) => _handleMenuSelection(context, value),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'pdf',
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'picture_as_pdf',
                color: AppTheme.errorLight,
                size: 18,
              ),
              SizedBox(width: 3.w),
              Text(
                'Export as PDF',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'csv',
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'table_chart',
                color: AppTheme.successLight,
                size: 18,
              ),
              SizedBox(width: 3.w),
              Text(
                'Export as CSV',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'share',
                color: theme.colorScheme.primary,
                size: 18,
              ),
              SizedBox(width: 3.w),
              Text(
                'Share Report',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'pdf':
        onExportPDF?.call();
        _showExportMessage(context, 'PDF report exported successfully');
        break;
      case 'csv':
        onExportCSV?.call();
        _showExportMessage(context, 'CSV data exported successfully');
        break;
      case 'share':
        onShare?.call();
        break;
    }
  }

  void _showExportMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
