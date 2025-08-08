import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum StockFilter { all, inStock, lowStock, outOfStock }

enum ProfitFilter { all, highProfit, mediumProfit, lowProfit, negative }

enum SortOption { alphabetical, stockLevel, profitMargin, recentActivity }

class InventoryFilterWidget extends StatefulWidget {
  final StockFilter selectedStockFilter;
  final ProfitFilter selectedProfitFilter;
  final SortOption selectedSortOption;
  final String selectedCategory;
  final List<String> categories;
  final Function(StockFilter) onStockFilterChanged;
  final Function(ProfitFilter) onProfitFilterChanged;
  final Function(SortOption) onSortOptionChanged;
  final Function(String) onCategoryChanged;
  final VoidCallback onClearFilters;

  const InventoryFilterWidget({
    super.key,
    required this.selectedStockFilter,
    required this.selectedProfitFilter,
    required this.selectedSortOption,
    required this.selectedCategory,
    required this.categories,
    required this.onStockFilterChanged,
    required this.onProfitFilterChanged,
    required this.onSortOptionChanged,
    required this.onCategoryChanged,
    required this.onClearFilters,
  });

  @override
  State<InventoryFilterWidget> createState() => _InventoryFilterWidgetState();
}

class _InventoryFilterWidgetState extends State<InventoryFilterWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Filter Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'filter_list',
                    color: theme.colorScheme.primary,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Filters & Sort',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (_hasActiveFilters())
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getActiveFilterCount().toString(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  SizedBox(width: 2.w),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: CustomIconWidget(
                      iconName: 'keyboard_arrow_down',
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 5.w,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filter Content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? null : 0,
            child: _isExpanded ? _buildFilterContent(context, theme) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterContent(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stock Status Filter
          _buildFilterSection(
            context,
            theme,
            'Stock Status',
            _buildStockFilterChips(theme),
          ),

          SizedBox(height: 3.h),

          // Profit Margin Filter
          _buildFilterSection(
            context,
            theme,
            'Profit Margin',
            _buildProfitFilterChips(theme),
          ),

          SizedBox(height: 3.h),

          // Category Filter
          if (widget.categories.isNotEmpty)
            _buildFilterSection(
              context,
              theme,
              'Category',
              _buildCategoryDropdown(theme),
            ),

          if (widget.categories.isNotEmpty) SizedBox(height: 3.h),

          // Sort Options
          _buildFilterSection(
            context,
            theme,
            'Sort By',
            _buildSortOptions(theme),
          ),

          SizedBox(height: 3.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onClearFilters,
                  child: Text('Clear All'),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _isExpanded = false),
                  child: Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
      BuildContext context, ThemeData theme, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        content,
      ],
    );
  }

  Widget _buildStockFilterChips(ThemeData theme) {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: StockFilter.values.map((filter) {
        final isSelected = widget.selectedStockFilter == filter;
        return FilterChip(
          label: Text(_getStockFilterLabel(filter)),
          selected: isSelected,
          onSelected: (selected) => widget.onStockFilterChanged(filter),
          selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          checkmarkColor: theme.colorScheme.primary,
        );
      }).toList(),
    );
  }

  Widget _buildProfitFilterChips(ThemeData theme) {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: ProfitFilter.values.map((filter) {
        final isSelected = widget.selectedProfitFilter == filter;
        return FilterChip(
          label: Text(_getProfitFilterLabel(filter)),
          selected: isSelected,
          onSelected: (selected) => widget.onProfitFilterChanged(filter),
          selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          checkmarkColor: theme.colorScheme.primary,
        );
      }).toList(),
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: widget.selectedCategory.isEmpty ? null : widget.selectedCategory,
      decoration: InputDecoration(
        hintText: 'Select Category',
        contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      ),
      items: [
        const DropdownMenuItem(value: '', child: Text('All Categories')),
        ...widget.categories.map((category) => DropdownMenuItem(
              value: category,
              child: Text(category),
            )),
      ],
      onChanged: (value) => widget.onCategoryChanged(value ?? ''),
    );
  }

  Widget _buildSortOptions(ThemeData theme) {
    return Column(
      children: SortOption.values.map((option) {
        final isSelected = widget.selectedSortOption == option;
        return RadioListTile<SortOption>(
          title: Text(_getSortOptionLabel(option)),
          value: option,
          groupValue: widget.selectedSortOption,
          onChanged: (value) => widget.onSortOptionChanged(value!),
          contentPadding: EdgeInsets.zero,
          dense: true,
        );
      }).toList(),
    );
  }

  String _getStockFilterLabel(StockFilter filter) {
    switch (filter) {
      case StockFilter.all:
        return 'All';
      case StockFilter.inStock:
        return 'In Stock';
      case StockFilter.lowStock:
        return 'Low Stock';
      case StockFilter.outOfStock:
        return 'Out of Stock';
    }
  }

  String _getProfitFilterLabel(ProfitFilter filter) {
    switch (filter) {
      case ProfitFilter.all:
        return 'All';
      case ProfitFilter.highProfit:
        return 'High (>30%)';
      case ProfitFilter.mediumProfit:
        return 'Medium (10-30%)';
      case ProfitFilter.lowProfit:
        return 'Low (0-10%)';
      case ProfitFilter.negative:
        return 'Negative';
    }
  }

  String _getSortOptionLabel(SortOption option) {
    switch (option) {
      case SortOption.alphabetical:
        return 'Alphabetical';
      case SortOption.stockLevel:
        return 'Stock Level';
      case SortOption.profitMargin:
        return 'Profit Margin';
      case SortOption.recentActivity:
        return 'Recent Activity';
    }
  }

  bool _hasActiveFilters() {
    return widget.selectedStockFilter != StockFilter.all ||
        widget.selectedProfitFilter != ProfitFilter.all ||
        widget.selectedCategory.isNotEmpty ||
        widget.selectedSortOption != SortOption.alphabetical;
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (widget.selectedStockFilter != StockFilter.all) count++;
    if (widget.selectedProfitFilter != ProfitFilter.all) count++;
    if (widget.selectedCategory.isNotEmpty) count++;
    if (widget.selectedSortOption != SortOption.alphabetical) count++;
    return count;
  }
}
