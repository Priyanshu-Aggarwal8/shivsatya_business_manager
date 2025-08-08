import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/add_product_dialog_widget.dart';
import './widgets/inventory_filter_widget.dart';
import './widgets/product_card_widget.dart';
import './widgets/stock_adjustment_widget.dart';

class InventoryManagement extends StatefulWidget {
  const InventoryManagement({super.key});

  @override
  State<InventoryManagement> createState() => _InventoryManagementState();
}

class _InventoryManagementState extends State<InventoryManagement>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  Set<int> _selectedProducts = {};

  StockFilter _selectedStockFilter = StockFilter.all;
  ProfitFilter _selectedProfitFilter = ProfitFilter.all;
  SortOption _selectedSortOption = SortOption.alphabetical;
  String _selectedCategory = '';

  bool _isLoading = false;
  bool _isMultiSelectMode = false;
  String _searchQuery = '';

  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Home & Garden',
    'Sports',
    'Books',
    'Toys',
    'Food & Beverages',
    'Health & Beauty',
    'Automotive',
  ];

  @override
  void initState() {
    super.initState();
    _loadMockData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    _products = [
      {
        "id": 1,
        "name": "Samsung Galaxy S23",
        "category": "Electronics",
        "costPrice": 45000.0,
        "sellingPrice": 52000.0,
        "stock": 15,
        "description":
            "Latest Samsung flagship smartphone with advanced camera features",
        "imageUrl":
            "https://images.pexels.com/photos/404280/pexels-photo-404280.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        "createdAt": DateTime.now().subtract(const Duration(days: 30)),
        "updatedAt": DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        "id": 2,
        "name": "Nike Air Max 270",
        "category": "Sports",
        "costPrice": 8000.0,
        "sellingPrice": 12000.0,
        "stock": 3,
        "description":
            "Comfortable running shoes with air cushioning technology",
        "imageUrl":
            "https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        "createdAt": DateTime.now().subtract(const Duration(days: 25)),
        "updatedAt": DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        "id": 3,
        "name": "Cotton T-Shirt",
        "category": "Clothing",
        "costPrice": 300.0,
        "sellingPrice": 599.0,
        "stock": 0,
        "description":
            "Premium quality cotton t-shirt available in multiple colors",
        "imageUrl":
            "https://images.pexels.com/photos/996329/pexels-photo-996329.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        "createdAt": DateTime.now().subtract(const Duration(days: 20)),
        "updatedAt": DateTime.now().subtract(const Duration(days: 5)),
      },
      {
        "id": 4,
        "name": "Bluetooth Headphones",
        "category": "Electronics",
        "costPrice": 2500.0,
        "sellingPrice": 3500.0,
        "stock": 25,
        "description": "Wireless headphones with noise cancellation feature",
        "imageUrl":
            "https://images.pexels.com/photos/3394650/pexels-photo-3394650.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        "createdAt": DateTime.now().subtract(const Duration(days: 15)),
        "updatedAt": DateTime.now().subtract(const Duration(hours: 12)),
      },
      {
        "id": 5,
        "name": "Coffee Maker",
        "category": "Home & Garden",
        "costPrice": 5000.0,
        "sellingPrice": 7500.0,
        "stock": 8,
        "description": "Automatic coffee maker with programmable timer",
        "imageUrl":
            "https://images.pexels.com/photos/324028/pexels-photo-324028.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        "createdAt": DateTime.now().subtract(const Duration(days: 10)),
        "updatedAt": DateTime.now().subtract(const Duration(hours: 6)),
      },
      {
        "id": 6,
        "name": "Yoga Mat",
        "category": "Sports",
        "costPrice": 800.0,
        "sellingPrice": 1200.0,
        "stock": 12,
        "description": "Non-slip yoga mat with carrying strap",
        "imageUrl":
            "https://images.pexels.com/photos/4056723/pexels-photo-4056723.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        "createdAt": DateTime.now().subtract(const Duration(days: 8)),
        "updatedAt": DateTime.now().subtract(const Duration(hours: 3)),
      },
    ];
    _applyFilters();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_products);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        final name = (product['name'] as String).toLowerCase();
        final category = (product['category'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || category.contains(query);
      }).toList();
    }

    // Apply stock filter
    if (_selectedStockFilter != StockFilter.all) {
      filtered = filtered.where((product) {
        final stock = product['stock'] as int;
        switch (_selectedStockFilter) {
          case StockFilter.inStock:
            return stock > 5;
          case StockFilter.lowStock:
            return stock > 0 && stock <= 5;
          case StockFilter.outOfStock:
            return stock == 0;
          default:
            return true;
        }
      }).toList();
    }

    // Apply profit filter
    if (_selectedProfitFilter != ProfitFilter.all) {
      filtered = filtered.where((product) {
        final costPrice = product['costPrice'] as double;
        final sellingPrice = product['sellingPrice'] as double;
        final profitPercentage = costPrice > 0
            ? ((sellingPrice - costPrice) / costPrice) * 100
            : 0.0;

        switch (_selectedProfitFilter) {
          case ProfitFilter.highProfit:
            return profitPercentage > 30;
          case ProfitFilter.mediumProfit:
            return profitPercentage >= 10 && profitPercentage <= 30;
          case ProfitFilter.lowProfit:
            return profitPercentage >= 0 && profitPercentage < 10;
          case ProfitFilter.negative:
            return profitPercentage < 0;
          default:
            return true;
        }
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory.isNotEmpty) {
      filtered = filtered.where((product) {
        return product['category'] == _selectedCategory;
      }).toList();
    }

    // Apply sorting
    switch (_selectedSortOption) {
      case SortOption.alphabetical:
        filtered.sort(
            (a, b) => (a['name'] as String).compareTo(b['name'] as String));
        break;
      case SortOption.stockLevel:
        filtered
            .sort((a, b) => (b['stock'] as int).compareTo(a['stock'] as int));
        break;
      case SortOption.profitMargin:
        filtered.sort((a, b) {
          final profitA =
              ((a['sellingPrice'] as double) - (a['costPrice'] as double)) /
                  (a['costPrice'] as double) *
                  100;
          final profitB =
              ((b['sellingPrice'] as double) - (b['costPrice'] as double)) /
                  (b['costPrice'] as double) *
                  100;
          return profitB.compareTo(profitA);
        });
        break;
      case SortOption.recentActivity:
        filtered.sort((a, b) =>
            (b['updatedAt'] as DateTime).compareTo(a['updatedAt'] as DateTime));
        break;
    }

    setState(() {
      _filteredProducts = filtered;
    });
  }

  int _getLowStockCount() {
    return _products
        .where((product) =>
            (product['stock'] as int) <= 5 && (product['stock'] as int) > 0)
        .length;
  }

  void _onProductTap(Map<String, dynamic> product) {
    if (_isMultiSelectMode) {
      setState(() {
        final productId = product['id'] as int;
        if (_selectedProducts.contains(productId)) {
          _selectedProducts.remove(productId);
        } else {
          _selectedProducts.add(productId);
        }

        if (_selectedProducts.isEmpty) {
          _isMultiSelectMode = false;
        }
      });
    } else {
      _showProductDetails(product);
    }
  }

  void _onProductLongPress(Map<String, dynamic> product) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isMultiSelectMode = true;
      _selectedProducts.add(product['id'] as int);
    });
  }

  void _showProductDetails(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildProductDetailsSheet(product),
    );
  }

  Widget _buildProductDetailsSheet(Map<String, dynamic> product) {
    final theme = Theme.of(context);
    final costPrice = product['costPrice'] as double;
    final sellingPrice = product['sellingPrice'] as double;
    final profit = sellingPrice - costPrice;
    final profitPercentage = costPrice > 0 ? (profit / costPrice) * 100 : 0.0;

    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    product['name'] as String,
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
                    size: 5.w,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  if (product['imageUrl'] != null)
                    Container(
                      height: 30.h,
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 3.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CustomImageWidget(
                          imageUrl: product['imageUrl'] as String,
                          width: double.infinity,
                          height: 30.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  // Product Info
                  _buildDetailRow(
                      theme, 'Category', product['category'] as String),
                  _buildDetailRow(theme, 'Stock', '${product['stock']} units'),
                  _buildDetailRow(
                      theme, 'Cost Price', '₹${costPrice.toStringAsFixed(2)}'),
                  _buildDetailRow(theme, 'Selling Price',
                      '₹${sellingPrice.toStringAsFixed(2)}'),
                  _buildDetailRow(theme, 'Profit',
                      '₹${profit.toStringAsFixed(2)} (${profitPercentage.toStringAsFixed(1)}%)'),

                  if (product['description'] != null &&
                      (product['description'] as String).isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      'Description',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      product['description'] as String,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showStockAdjustment(product);
                    },
                    icon: CustomIconWidget(
                      iconName: 'add_circle_outline',
                      color: theme.colorScheme.primary,
                      size: 4.w,
                    ),
                    label: Text('Update Stock'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _editProduct(product);
                    },
                    icon: CustomIconWidget(
                      iconName: 'edit',
                      color: theme.colorScheme.onPrimary,
                      size: 4.w,
                    ),
                    label: Text('Edit Product'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStockAdjustment(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StockAdjustmentWidget(
        product: product,
        onStockAdjusted: (updatedProduct) {
          setState(() {
            final index =
                _products.indexWhere((p) => p['id'] == updatedProduct['id']);
            if (index != -1) {
              _products[index] = updatedProduct;
              _applyFilters();
            }
          });
        },
      ),
    );
  }

  void _editProduct(Map<String, dynamic> product) {
    // Implementation for editing product
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit product functionality coming soon')),
    );
  }

  void _addProduct() {
    showDialog(
      context: context,
      builder: (context) => AddProductDialogWidget(
        onProductAdded: (product) {
          setState(() {
            _products.add(product);
            _applyFilters();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Product added successfully'),
              backgroundColor: AppTheme.successLight,
            ),
          );
        },
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedStockFilter = StockFilter.all;
      _selectedProfitFilter = ProfitFilter.all;
      _selectedSortOption = SortOption.alphabetical;
      _selectedCategory = '';
      _searchController.clear();
      _searchQuery = '';
      _applyFilters();
    });
  }

  void _exitMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = false;
      _selectedProducts.clear();
    });
  }

  void _bulkUpdateStock() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Bulk stock update functionality coming soon')),
    );
  }

  Future<void> _refreshInventory() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1000));

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Inventory refreshed'),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lowStockCount = _getLowStockCount();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Inventory',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (lowStockCount > 0) ...[
              SizedBox(width: 2.w),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warningLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$lowStockCount',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_isMultiSelectMode) ...[
            IconButton(
              onPressed: _bulkUpdateStock,
              icon: CustomIconWidget(
                iconName: 'edit',
                color: theme.colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
            ),
            IconButton(
              onPressed: _exitMultiSelectMode,
              icon: CustomIconWidget(
                iconName: 'close',
                color: theme.colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
            ),
          ] else ...[
            IconButton(
              onPressed: _addProduct,
              icon: CustomIconWidget(
                iconName: 'add',
                color: theme.colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
            ),
            PopupMenuButton<String>(
              icon: CustomIconWidget(
                iconName: 'more_vert',
                color: theme.colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
              onSelected: (value) {
                switch (value) {
                  case 'scan':
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Barcode scanner coming soon')),
                    );
                    break;
                  case 'export':
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Export functionality coming soon')),
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'scan',
                  child: Row(
                    children: [
                      Icon(Icons.qr_code_scanner),
                      SizedBox(width: 12),
                      Text('Scan Barcode'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.file_download),
                      SizedBox(width: 12),
                      Text('Export Data'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 5.w,
                  ),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 5.w,
                        ),
                      )
                    : null,
              ),
            ),
          ),

          // Filters
          InventoryFilterWidget(
            selectedStockFilter: _selectedStockFilter,
            selectedProfitFilter: _selectedProfitFilter,
            selectedSortOption: _selectedSortOption,
            selectedCategory: _selectedCategory,
            categories: _categories,
            onStockFilterChanged: (filter) {
              setState(() {
                _selectedStockFilter = filter;
                _applyFilters();
              });
            },
            onProfitFilterChanged: (filter) {
              setState(() {
                _selectedProfitFilter = filter;
                _applyFilters();
              });
            },
            onSortOptionChanged: (option) {
              setState(() {
                _selectedSortOption = option;
                _applyFilters();
              });
            },
            onCategoryChanged: (category) {
              setState(() {
                _selectedCategory = category;
                _applyFilters();
              });
            },
            onClearFilters: _clearFilters,
          ),

          // Product Grid
          Expanded(
            child: _filteredProducts.isEmpty
                ? _buildEmptyState(theme)
                : RefreshIndicator(
                    onRefresh: _refreshInventory,
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(4.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            MediaQuery.of(context).size.width > 600 ? 3 : 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 4.w,
                        mainAxisSpacing: 2.h,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        final isSelected =
                            _selectedProducts.contains(product['id']);

                        return ProductCardWidget(
                          product: product,
                          isSelected: isSelected,
                          onTap: () => _onProductTap(product),
                          onLongPress: () => _onProductLongPress(product),
                          onUpdateStock: () => _showStockAdjustment(product),
                          onEditPrices: () => _editProduct(product),
                          onViewHistory: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Sales history coming soon')),
                            );
                          },
                          onArchive: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Archive functionality coming soon')),
                            );
                          },
                          onDelete: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Delete functionality coming soon')),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: _isMultiSelectMode
          ? null
          : FloatingActionButton(
              onPressed: _addProduct,
              child: CustomIconWidget(
                iconName: 'add',
                color: theme.colorScheme.onSecondary,
                size: 6.w,
              ),
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'inventory_2',
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            size: 20.w,
          ),
          SizedBox(height: 3.h),
          Text(
            _searchQuery.isNotEmpty ? 'No products found' : 'No products yet',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'Add your first product to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          if (_searchQuery.isEmpty)
            ElevatedButton.icon(
              onPressed: _addProduct,
              icon: CustomIconWidget(
                iconName: 'add',
                color: theme.colorScheme.onPrimary,
                size: 4.w,
              ),
              label: Text('Add Product'),
            ),
        ],
      ),
    );
  }
}
