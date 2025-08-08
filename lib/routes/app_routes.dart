import 'package:flutter/material.dart';
import '../presentation/financial_reports/financial_reports.dart';
import '../presentation/customer_management/customer_management.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/dashboard/dashboard.dart';
import '../presentation/payment_tracking/payment_tracking.dart';
import '../presentation/inventory_management/inventory_management.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String financialReports = '/financial-reports';
  static const String customerManagement = '/customer-management';
  static const String login = '/login-screen';
  static const String dashboard = '/dashboard';
  static const String paymentTracking = '/payment-tracking';
  static const String inventoryManagement = '/inventory-management';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    financialReports: (context) => const FinancialReports(),
    customerManagement: (context) => const CustomerManagement(),
    login: (context) => const LoginScreen(),
    dashboard: (context) => const Dashboard(),
    paymentTracking: (context) => const PaymentTracking(),
    inventoryManagement: (context) => const InventoryManagement(),
    // TODO: Add your other routes here
  };
}
