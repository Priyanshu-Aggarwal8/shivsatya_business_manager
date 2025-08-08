import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class QuickPaymentDialog extends StatefulWidget {
  final Map<String, dynamic>? existingPayment;
  final Function(Map<String, dynamic>) onPaymentRecorded;

  const QuickPaymentDialog({
    super.key,
    this.existingPayment,
    required this.onPaymentRecorded,
  });

  @override
  State<QuickPaymentDialog> createState() => _QuickPaymentDialogState();
}

class _QuickPaymentDialogState extends State<QuickPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCustomer = '';
  String _selectedPaymentMethod = 'Cash';
  String _selectedPaymentType = 'Lumpsum';
  DateTime _selectedDate = DateTime.now();

  final List<String> _paymentMethods = ['Cash', 'UPI', 'NEFT', 'Cheque'];
  final List<String> _paymentTypes = ['Lumpsum', 'Partial'];

  final List<String> _mockCustomers = [
    'Rajesh Kumar',
    'Priya Sharma',
    'Amit Patel',
    'Sunita Gupta',
    'Vikram Singh',
    'Meera Joshi',
    'Ravi Agarwal',
    'Kavita Reddy',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingPayment != null) {
      _initializeWithExistingPayment();
    } else {
      _selectedCustomer = _mockCustomers.first;
    }
  }

  void _initializeWithExistingPayment() {
    final payment = widget.existingPayment!;
    _selectedCustomer =
        (payment['customerName'] as String?) ?? _mockCustomers.first;
    _amountController.text =
        (payment['dueAmount'] as double?)?.toString() ?? '';
    _selectedPaymentMethod = (payment['paymentMethod'] as String?) ?? 'Cash';
    _selectedDate = payment['saleDate'] as DateTime? ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: 80.h,
          maxWidth: 90.w,
        ),
        padding: EdgeInsets.all(6.w),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.existingPayment != null
                            ? 'Update Payment'
                            : 'Record Payment',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                _buildCustomerDropdown(theme),
                SizedBox(height: 2.h),
                _buildAmountField(theme),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildPaymentMethodDropdown(theme),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: _buildPaymentTypeDropdown(theme),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                _buildDatePicker(theme),
                SizedBox(height: 2.h),
                _buildNotesField(theme),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _recordPayment,
                        child: Text(
                          widget.existingPayment != null ? 'Update' : 'Record',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          value: _selectedCustomer,
          decoration: InputDecoration(
            prefixIcon: CustomIconWidget(
              iconName: 'person',
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          items: _mockCustomers
              .map((customer) => DropdownMenuItem(
                    value: customer,
                    child: Text(customer),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCustomer = value;
              });
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a customer';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAmountField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount (₹)',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            prefixIcon: CustomIconWidget(
              iconName: 'currency_rupee',
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            hintText: 'Enter amount',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter valid amount';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethodDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          value: _selectedPaymentMethod,
          decoration: InputDecoration(
            prefixIcon: CustomIconWidget(
              iconName: 'payment',
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          items: _paymentMethods
              .map((method) => DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPaymentMethod = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildPaymentTypeDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Type',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          value: _selectedPaymentType,
          decoration: InputDecoration(
            prefixIcon: CustomIconWidget(
              iconName: 'category',
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          items: _paymentTypes
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPaymentType = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildDatePicker(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Date',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'calendar_today',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (Optional)',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            prefixIcon: CustomIconWidget(
              iconName: 'note',
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            hintText: 'Add payment notes...',
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _recordPayment() {
    if (_formKey.currentState!.validate()) {
      final paymentData = {
        'id': widget.existingPayment?['id'] ??
            DateTime.now().millisecondsSinceEpoch,
        'customerName': _selectedCustomer,
        'amount': double.parse(_amountController.text),
        'paymentMethod': _selectedPaymentMethod,
        'paymentType': _selectedPaymentType,
        'paymentDate': _selectedDate,
        'notes': _notesController.text,
        'status': _selectedPaymentType == 'Lumpsum' ? 'complete' : 'partial',
      };

      widget.onPaymentRecorded(paymentData);
      Navigator.pop(context);
    }
  }
}
