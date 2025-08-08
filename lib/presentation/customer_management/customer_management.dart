import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/add_customer_form.dart';
import './widgets/customer_card_widget.dart';
import './widgets/customer_empty_state.dart';
import './widgets/customer_filter_sheet.dart';
import './widgets/customer_search_bar.dart';

class CustomerManagement extends StatefulWidget {
  const CustomerManagement({super.key});

  @override
  State<CustomerManagement> createState() => _CustomerManagementState();
}

class _CustomerManagementState extends State<CustomerManagement> {
  final List<Map<String, dynamic>> _allCustomers = [
    {
      "id": 1,
      "name": "Rajesh Kumar",
      "phone": "9876543210",
      "email": "rajesh.kumar@email.com",
      "address": "123 MG Road, Delhi",
      "business": "Electronics Store",
      "totalPurchases": 45000.0,
      "lastTransaction": DateTime.now().subtract(const Duration(days: 2)),
      "createdAt": DateTime.now().subtract(const Duration(days: 30)),
      "notes": "Regular customer, prefers cash payments",
    },
    {
      "id": 2,
      "name": "Priya Sharma",
      "phone": "9123456789",
      "email": "priya.sharma@email.com",
      "address": "456 Park Street, Mumbai",
      "business": "Fashion Boutique",
      "totalPurchases": 32000.0,
      "lastTransaction": DateTime.now().subtract(const Duration(days: 5)),
      "createdAt": DateTime.now().subtract(const Duration(days: 45)),
      "notes": "Bulk orders, good payment history",
    },
    {
      "id": 3,
      "name": "Amit Patel",
      "phone": "9234567890",
      "email": "amit.patel@email.com",
      "address": "789 Commercial Street, Bangalore",
      "business": "Mobile Accessories",
      "totalPurchases": 28500.0,
      "lastTransaction": DateTime.now().subtract(const Duration(days: 1)),
      "createdAt": DateTime.now().subtract(const Duration(days: 60)),
      "notes": "Quick decision maker, prefers UPI",
    },
    {
      "id": 4,
      "name": "Sunita Gupta",
      "phone": "9345678901",
      "email": "sunita.gupta@email.com",
      "address": "321 Market Road, Pune",
      "business": "Grocery Store",
      "totalPurchases": 52000.0,
      "lastTransaction": DateTime.now().subtract(const Duration(days: 7)),
      "createdAt": DateTime.now().subtract(const Duration(days: 90)),
      "notes": "Large volume orders, seasonal buyer",
    },
    {
      "id": 5,
      "name": "Vikram Singh",
      "phone": "9456789012",
      "email": "vikram.singh@email.com",
      "address": "654 Industrial Area, Chennai",
      "business": "Hardware Store",
      "totalPurchases": 38000.0,
      "lastTransaction": DateTime.now().subtract(const Duration(days: 10)),
      "createdAt": DateTime.now().subtract(const Duration(days: 120)),
      "notes": "Reliable customer, monthly orders",
    },
  ];

  List<Map<String, dynamic>> _filteredCustomers = [];
  final Set<int> _selectedCustomers = {};
  String _searchQuery = '';
  CustomerSortOption _currentSort = CustomerSortOption.alphabetical;
  bool _isMultiSelectMode = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _filteredCustomers = List.from(_allCustomers);
    _sortCustomers();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context, theme),
      body: Column(
        children: [
          CustomerSearchBar(
            hintText: 'Search customers by name or phone...',
            onChanged: _handleSearch,
            onFilterTap: _showFilterSheet,
            onAddCustomer: _showAddCustomerForm,
          ),
          if (_isMultiSelectMode) _buildMultiSelectHeader(context, theme),
          Expanded(
            child: _buildCustomerList(context, theme),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomBar(
        variant: CustomBottomBarVariant.standard,
        currentIndex: 1,
      ),
      floatingActionButton: _allCustomers.isNotEmpty && !_isMultiSelectMode
          ? FloatingActionButton(
              onPressed: _showAddCustomerForm,
              child: CustomIconWidget(
                iconName: 'person_add',
                size: 24,
                color: theme.colorScheme.onSecondary,
              ),
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme) {
    if (_isMultiSelectMode) {
      return AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: Text(
          '${_selectedCustomers.length} selected',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: _exitMultiSelectMode,
          icon: CustomIconWidget(
            iconName: 'close',
            size: 24,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed:
                _selectedCustomers.isNotEmpty ? _exportSelectedCustomers : null,
            icon: CustomIconWidget(
              iconName: 'file_download',
              size: 24,
              color: _selectedCustomers.isNotEmpty
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onPrimary.withValues(alpha: 0.5),
            ),
          ),
          IconButton(
            onPressed: _selectedCustomers.isNotEmpty ? _sendGroupMessage : null,
            icon: CustomIconWidget(
              iconName: 'message',
              size: 24,
              color: _selectedCustomers.isNotEmpty
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onPrimary.withValues(alpha: 0.5),
            ),
          ),
        ],
      );
    }

    return CustomAppBar(
      title: 'Customer Management',
      variant: CustomAppBarVariant.standard,
      actions: [
        Container(
          margin: EdgeInsets.only(right: 2.w),
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_allCustomers.length}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _selectedCustomers.length == _filteredCustomers.length,
            tristate: true,
            onChanged: _toggleSelectAll,
          ),
          SizedBox(width: 2.w),
          Text(
            _selectedCustomers.length == _filteredCustomers.length
                ? 'All customers selected'
                : _selectedCustomers.isEmpty
                    ? 'Select customers'
                    : '${_selectedCustomers.length} of ${_filteredCustomers.length} selected',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerList(BuildContext context, ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_allCustomers.isEmpty) {
      return CustomerEmptyState(
        onAddCustomer: _showAddCustomerForm,
        onImportContacts: _importContacts,
      );
    }

    if (_filteredCustomers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              size: 60,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 2.h),
            Text(
              'No customers found',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Try adjusting your search or filters',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshCustomers,
      child: ListView.builder(
        itemCount: _filteredCustomers.length,
        itemBuilder: (context, index) {
          final customer = _filteredCustomers[index];
          final customerId = customer['id'] as int;

          return CustomerCardWidget(
            customer: customer,
            isSelected: _selectedCustomers.contains(customerId),
            onTap: () => _handleCustomerTap(customer, customerId),
            onCall: () => _callCustomer(customer),
            onMessage: () => _messageCustomer(customer),
            onViewHistory: () => _viewCustomerHistory(customer),
            onEdit: () => _editCustomer(customer),
            onArchive: () => _archiveCustomer(customer),
          );
        },
      ),
    );
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filterCustomers();
    });
  }

  void _filterCustomers() {
    _filteredCustomers = _allCustomers.where((customer) {
      final name = (customer['name'] as String).toLowerCase();
      final phone = (customer['phone'] as String).toLowerCase();
      final business = (customer['business'] as String? ?? '').toLowerCase();

      return name.contains(_searchQuery) ||
          phone.contains(_searchQuery) ||
          business.contains(_searchQuery);
    }).toList();

    _sortCustomers();
  }

  void _sortCustomers() {
    switch (_currentSort) {
      case CustomerSortOption.alphabetical:
        _filteredCustomers.sort(
            (a, b) => (a['name'] as String).compareTo(b['name'] as String));
        break;
      case CustomerSortOption.recentActivity:
        _filteredCustomers.sort((a, b) {
          final aDate = a['lastTransaction'] as DateTime?;
          final bDate = b['lastTransaction'] as DateTime?;
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return bDate.compareTo(aDate);
        });
        break;
      case CustomerSortOption.highestPurchases:
        _filteredCustomers.sort((a, b) => (b['totalPurchases'] as double)
            .compareTo(a['totalPurchases'] as double));
        break;
      case CustomerSortOption.outstandingPayments:
        // For demo purposes, assuming some customers have outstanding payments
        _filteredCustomers.sort((a, b) {
          final aOutstanding =
              (a['totalPurchases'] as double) * 0.1; // Mock outstanding
          final bOutstanding = (b['totalPurchases'] as double) * 0.1;
          return bOutstanding.compareTo(aOutstanding);
        });
        break;
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomerFilterSheet(
        currentSort: _currentSort,
        onSortChanged: (sort) {
          setState(() {
            _currentSort = sort;
            _sortCustomers();
          });
        },
        onClearFilters: () {
          setState(() {
            _currentSort = CustomerSortOption.alphabetical;
            _sortCustomers();
          });
        },
      ),
    );
  }

  void _showAddCustomerForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: 90.h,
        child: AddCustomerForm(
          onSave: _addCustomer,
        ),
      ),
    );
  }

  void _addCustomer(Map<String, dynamic> customerData) {
    setState(() {
      _allCustomers.add(customerData);
      _filterCustomers();
    });
  }

  void _editCustomer(Map<String, dynamic> customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: 90.h,
        child: AddCustomerForm(
          initialData: customer,
          isEditing: true,
          onSave: (updatedData) => _updateCustomer(updatedData),
        ),
      ),
    );
  }

  void _updateCustomer(Map<String, dynamic> updatedData) {
    setState(() {
      final index = _allCustomers.indexWhere(
        (customer) => customer['id'] == updatedData['id'],
      );
      if (index != -1) {
        _allCustomers[index] = updatedData;
        _filterCustomers();
      }
    });
  }

  void _handleCustomerTap(Map<String, dynamic> customer, int customerId) {
    if (_isMultiSelectMode) {
      setState(() {
        if (_selectedCustomers.contains(customerId)) {
          _selectedCustomers.remove(customerId);
        } else {
          _selectedCustomers.add(customerId);
        }

        if (_selectedCustomers.isEmpty) {
          _isMultiSelectMode = false;
        }
      });
    } else {
      _viewCustomerDetails(customer);
    }
  }

  void _viewCustomerDetails(Map<String, dynamic> customer) {
    // Navigate to customer details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening details for ${customer['name']}'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }

  void _callCustomer(Map<String, dynamic> customer) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${customer['name']} at ${customer['phone']}'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }

  void _messageCustomer(Map<String, dynamic> customer) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sending message to ${customer['name']}'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }

  void _viewCustomerHistory(Map<String, dynamic> customer) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing sales history for ${customer['name']}'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }

  void _archiveCustomer(Map<String, dynamic> customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Customer'),
        content: Text('Are you sure you want to archive ${customer['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _allCustomers.removeWhere((c) => c['id'] == customer['id']);
                _filterCustomers();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${customer['name']} archived'),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                ),
              );
            },
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectedCustomers.clear();
        _selectedCustomers.addAll(
          _filteredCustomers.map((customer) => customer['id'] as int),
        );
      } else {
        _selectedCustomers.clear();
        if (_selectedCustomers.isEmpty) {
          _isMultiSelectMode = false;
        }
      }
    });
  }

  void _exitMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = false;
      _selectedCustomers.clear();
    });
  }

  void _exportSelectedCustomers() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting ${_selectedCustomers.length} customers'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }

  void _sendGroupMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Sending message to ${_selectedCustomers.length} customers'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }

  void _importContacts() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact import feature coming soon'),
      ),
    );
  }

  Future<void> _refreshCustomers() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Customer data refreshed'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }
}
