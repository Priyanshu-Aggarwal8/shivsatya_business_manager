import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

enum AdjustmentType { add, remove, set }

enum AdjustmentReason { sale, purchase, damage, theft, correction, other }

class StockAdjustmentWidget extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic>) onStockAdjusted;

  const StockAdjustmentWidget({
    super.key,
    required this.product,
    required this.onStockAdjusted,
  });

  @override
  State<StockAdjustmentWidget> createState() => _StockAdjustmentWidgetState();
}

class _StockAdjustmentWidgetState extends State<StockAdjustmentWidget> {
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();

  AdjustmentType _adjustmentType = AdjustmentType.add;
  AdjustmentReason _selectedReason = AdjustmentReason.purchase;
  int _currentStock = 0;
  int _newStock = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentStock = (widget.product['stock'] as int?) ?? 0;
    _newStock = _currentStock;
    _quantityController.addListener(_calculateNewStock);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _calculateNewStock() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    setState(() {
      switch (_adjustmentType) {
        case AdjustmentType.add:
          _newStock = _currentStock + quantity;
          break;
        case AdjustmentType.remove:
          _newStock =
              (_currentStock - quantity).clamp(0, double.infinity).toInt();
          break;
        case AdjustmentType.set:
          _newStock = quantity;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 4,
                height: 30,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adjust Stock',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.product['name'] as String? ?? 'Unknown Product',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Current Stock Display
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'inventory',
                  color: theme.colorScheme.primary,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Current Stock: $_currentStock units',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Adjustment Type Selection
          Text(
            'Adjustment Type',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: AdjustmentType.values.map((type) {
              final isSelected = _adjustmentType == type;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: type != AdjustmentType.values.last ? 2.w : 0),
                  child: ChoiceChip(
                    label: Text(_getAdjustmentTypeLabel(type)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _adjustmentType = type;
                          _calculateNewStock();
                        });
                      }
                    },
                    selectedColor:
                        theme.colorScheme.primary.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 3.h),

          // Quantity Input
          Text(
            _adjustmentType == AdjustmentType.set
                ? 'New Stock Quantity'
                : 'Quantity',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              // Stepper Controls
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        final current =
                            int.tryParse(_quantityController.text) ?? 0;
                        if (current > 0) {
                          _quantityController.text = (current - 1).toString();
                        }
                      },
                      icon: CustomIconWidget(
                        iconName: 'remove',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 4.w,
                      ),
                    ),
                    Container(
                      width: 20.w,
                      child: TextFormField(
                        controller: _quantityController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        final current =
                            int.tryParse(_quantityController.text) ?? 0;
                        _quantityController.text = (current + 1).toString();
                      },
                      icon: CustomIconWidget(
                        iconName: 'add',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 4.w,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 4.w),

              // New Stock Preview
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: _getStockChangeColor(theme).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStockChangeColor(theme).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: _getStockChangeIcon(),
                        color: _getStockChangeColor(theme),
                        size: 4.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'New: $_newStock',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _getStockChangeColor(theme),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Reason Selection
          Text(
            'Reason',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          DropdownButtonFormField<AdjustmentReason>(
            value: _selectedReason,
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'help_outline',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
              ),
            ),
            items: AdjustmentReason.values
                .map((reason) => DropdownMenuItem(
                      value: reason,
                      child: Text(_getReasonLabel(reason)),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedReason = value!;
              });
            },
          ),

          if (_selectedReason == AdjustmentReason.other) ...[
            SizedBox(height: 2.h),
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                hintText: 'Enter custom reason',
              ),
              maxLines: 2,
            ),
          ],

          SizedBox(height: 4.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _adjustStock,
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Text('Adjust Stock'),
                ),
              ),
            ],
          ),

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  String _getAdjustmentTypeLabel(AdjustmentType type) {
    switch (type) {
      case AdjustmentType.add:
        return 'Add';
      case AdjustmentType.remove:
        return 'Remove';
      case AdjustmentType.set:
        return 'Set';
    }
  }

  String _getReasonLabel(AdjustmentReason reason) {
    switch (reason) {
      case AdjustmentReason.sale:
        return 'Sale';
      case AdjustmentReason.purchase:
        return 'Purchase';
      case AdjustmentReason.damage:
        return 'Damage';
      case AdjustmentReason.theft:
        return 'Theft';
      case AdjustmentReason.correction:
        return 'Correction';
      case AdjustmentReason.other:
        return 'Other';
    }
  }

  Color _getStockChangeColor(ThemeData theme) {
    if (_newStock > _currentStock) return AppTheme.successLight;
    if (_newStock < _currentStock) return AppTheme.errorLight;
    return theme.colorScheme.onSurfaceVariant;
  }

  String _getStockChangeIcon() {
    if (_newStock > _currentStock) return 'trending_up';
    if (_newStock < _currentStock) return 'trending_down';
    return 'trending_flat';
  }

  void _adjustStock() async {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    if (quantity == 0 && _adjustmentType != AdjustmentType.set) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedProduct = Map<String, dynamic>.from(widget.product);
      updatedProduct['stock'] = _newStock;
      updatedProduct['updatedAt'] = DateTime.now();

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      widget.onStockAdjusted(updatedProduct);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock adjusted successfully'),
          backgroundColor: AppTheme.successLight,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adjusting stock: ${e.toString()}'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
