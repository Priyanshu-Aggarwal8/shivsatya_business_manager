import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_bottom_bar.dart';
import './widgets/customer_analysis_list.dart';
import './widgets/date_range_selector.dart';
import './widgets/export_menu.dart';
import './widgets/kpi_card.dart';
import './widgets/payment_pattern_chart.dart';
import './widgets/product_profitability_list.dart';
import './widgets/profit_analysis_chart.dart';
import './widgets/sales_trend_chart.dart';

class FinancialReports extends StatefulWidget {
  const FinancialReports({super.key});

  @override
  State<FinancialReports> createState() => _FinancialReportsState();
}

class _FinancialReportsState extends State<FinancialReports> {
  DateRangeType _selectedRange = DateRangeType.month;
  bool _isLoading = false;

  // Mock data for financial reports
  final List<Map<String, dynamic>> _salesTrendData = [
    {"date": "01-08", "amount": 45000.0},
    {"date": "02-08", "amount": 52000.0},
    {"date": "03-08", "amount": 38000.0},
    {"date": "04-08", "amount": 61000.0},
    {"date": "05-08", "amount": 47000.0},
    {"date": "06-08", "amount": 58000.0},
  ];

  final List<Map<String, dynamic>> _profitAnalysisData = [
    {"product": "Smartphone", "profit": 25000.0, "margin": 18.5},
    {"product": "Laptop", "profit": 35000.0, "margin": 22.3},
    {"product": "Tablet", "profit": 18000.0, "margin": 15.2},
    {"product": "Headphones", "profit": 12000.0, "margin": 28.7},
    {"product": "Smartwatch", "profit": 22000.0, "margin": 31.4},
  ];

  final List<Map<String, dynamic>> _paymentMethodData = [
    {"method": "UPI", "amount": 125000.0, "percentage": 45.0},
    {"method": "Cash", "amount": 85000.0, "percentage": 30.5},
    {"method": "Card", "amount": 45000.0, "percentage": 16.2},
    {"method": "NEFT", "amount": 23000.0, "percentage": 8.3},
  ];

  final List<Map<String, dynamic>> _productProfitabilityData = [
    {
      "name": "iPhone 15 Pro",
      "unitsSold": 25,
      "revenue": 187500.0,
      "profit": 37500.0,
      "profitMargin": 20.0,
    },
    {
      "name": "MacBook Air M2",
      "unitsSold": 12,
      "revenue": 156000.0,
      "profit": 31200.0,
      "profitMargin": 20.0,
    },
    {
      "name": "iPad Pro 11\"",
      "unitsSold": 18,
      "revenue": 108000.0,
      "profit": 18900.0,
      "profitMargin": 17.5,
    },
    {
      "name": "AirPods Pro",
      "unitsSold": 45,
      "revenue": 112500.0,
      "profit": 33750.0,
      "profitMargin": 30.0,
    },
    {
      "name": "Apple Watch Series 9",
      "unitsSold": 22,
      "revenue": 88000.0,
      "profit": 22000.0,
      "profitMargin": 25.0,
    },
  ];

  final List<Map<String, dynamic>> _customerAnalysisData = [
    {
      "name": "Rajesh Kumar",
      "orders": 15,
      "totalSpent": 125000.0,
      "lastOrder": "2 days ago",
      "status": "Active",
    },
    {
      "name": "Priya Sharma",
      "orders": 12,
      "totalSpent": 98000.0,
      "lastOrder": "1 week ago",
      "status": "Active",
    },
    {
      "name": "Amit Patel",
      "orders": 8,
      "totalSpent": 75000.0,
      "lastOrder": "3 days ago",
      "status": "Active",
    },
    {
      "name": "Sunita Gupta",
      "orders": 6,
      "totalSpent": 45000.0,
      "lastOrder": "2 weeks ago",
      "status": "Pending",
    },
    {
      "name": "Vikram Singh",
      "orders": 10,
      "totalSpent": 82000.0,
      "lastOrder": "5 days ago",
      "status": "Active",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Financial Reports',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          ExportMenu(
            onExportPDF: _exportPDF,
            onExportCSV: _exportCSV,
            onShare: _shareReport,
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Range Selector
              Container(
                color: theme.colorScheme.surface,
                child: DateRangeSelector(
                  selectedRange: _selectedRange,
                  onRangeChanged: _onDateRangeChanged,
                  onCustomDateTap: _showCustomDatePicker,
                ),
              ),
              SizedBox(height: 2.h),

              // KPI Cards
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: KpiCard(
                            title: 'Total Sales',
                            value: '₹3,01,000',
                            trend: '+12.5%',
                            isPositive: true,
                            onTap: () => _navigateToDetailedView('sales'),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: KpiCard(
                            title: 'Profit Margin',
                            value: '₹1,43,200',
                            subtitle: '23.8%',
                            trend: '+8.2%',
                            isPositive: true,
                            onTap: () => _navigateToDetailedView('profit'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Expanded(
                          child: KpiCard(
                            title: 'Collection Rate',
                            value: '87.5%',
                            subtitle: '₹2,63,375',
                            trend: '+5.1%',
                            isPositive: true,
                            onTap: () => _navigateToDetailedView('payments'),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: KpiCard(
                            title: 'Inventory Turn',
                            value: '4.2x',
                            subtitle: 'Monthly',
                            trend: '-2.3%',
                            isPositive: false,
                            onTap: () => _navigateToDetailedView('inventory'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),

              // Charts Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  children: [
                    SalesTrendChart(
                      salesData: _salesTrendData,
                      onChartTap: () => _showFullScreenChart('sales'),
                    ),
                    SizedBox(height: 2.h),
                    ProfitAnalysisChart(
                      profitData: _profitAnalysisData,
                      onChartTap: () => _showFullScreenChart('profit'),
                    ),
                    SizedBox(height: 2.h),
                    PaymentPatternChart(
                      paymentData: _paymentMethodData,
                      onChartTap: () => _showFullScreenChart('payment'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),

              // Detailed Reports Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  children: [
                    ProductProfitabilityList(
                      productData: _productProfitabilityData,
                      onViewAll: () => _showDetailedProductReport(),
                    ),
                    SizedBox(height: 2.h),
                    CustomerAnalysisList(
                      customerData: _customerAnalysisData,
                      onViewAll: () => _showDetailedCustomerReport(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 4, // Financial Reports tab
        onTap: (index) => _handleBottomNavigation(context, index),
      ),
    );
  }

  void _onDateRangeChanged(DateRangeType range) {
    setState(() {
      _selectedRange = range;
    });
    _refreshData();
  }

  void _showCustomDatePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedRange = DateRangeType.custom;
      });
      _refreshData();
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  void _exportPDF() {
    // PDF export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating PDF report...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _exportCSV() {
    // CSV export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting CSV data...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareReport() {
    // Share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening share options...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToDetailedView(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening detailed $type view...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showFullScreenChart(String chartType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening full-screen $chartType chart...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDetailedProductReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening detailed product profitability report...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showDetailedCustomerReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening detailed customer analysis report...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleBottomNavigation(BuildContext context, int index) {
    final routes = [
      '/dashboard',
      '/customer-management',
      '/inventory-management',
      '/payment-tracking',
      '/financial-reports',
    ];

    if (index < routes.length && index != 4) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        routes[index],
        (route) => false,
      );
    }
  }
}
