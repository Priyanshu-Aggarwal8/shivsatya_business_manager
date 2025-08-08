import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import './widgets/biometric_prompt_widget.dart';
import './widgets/business_logo_widget.dart';
import './widgets/login_form_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _showBiometricPrompt = false;
  final FocusNode _focusNode = FocusNode();

  // Mock credentials for different user types
  final Map<String, Map<String, String>> _mockCredentials = {
    'admin@shivsatya.com': {
      'password': 'admin123',
      'role': 'Business Owner',
    },
    'manager@shivsatya.com': {
      'password': 'manager123',
      'role': 'Store Manager',
    },
    'staff@shivsatya.com': {
      'password': 'staff123',
      'role': 'Sales Staff',
    },
  };

  @override
  void initState() {
    super.initState();
    _checkSavedCredentials();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _checkSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email');
      if (savedEmail != null) {
        // Auto-fill saved email if available
        setState(() {});
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Check mock credentials
      final credentials = _mockCredentials[email.toLowerCase()];

      if (credentials != null && credentials['password'] == password) {
        // Save credentials
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email', email);
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_role', credentials['role']!);

        // Success haptic feedback
        HapticFeedback.mediumImpact();

        // Check if first time login for biometric prompt
        final isFirstLogin = prefs.getBool('first_login') ?? true;
        if (isFirstLogin) {
          await prefs.setBool('first_login', false);
          setState(() {
            _isLoading = false;
            _showBiometricPrompt = true;
          });
        } else {
          _navigateToDashboard();
        }
      } else {
        // Invalid credentials
        _showErrorMessage(
            'Invalid credentials. Please check your email and password.');
      }
    } catch (e) {
      _showErrorMessage(
          'Network error. Please check your connection and try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _handleBiometricSetup() async {
    try {
      // Simulate biometric setup
      await Future.delayed(const Duration(seconds: 1));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometric_enabled', true);

      HapticFeedback.mediumImpact();
      _navigateToDashboard();
    } catch (e) {
      _showErrorMessage(
          'Biometric setup failed. You can enable it later in settings.');
      _navigateToDashboard();
    }
  }

  void _skipBiometric() {
    HapticFeedback.lightImpact();
    _navigateToDashboard();
  }

  void _navigateToDashboard() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/dashboard',
      (route) => false,
    );
  }

  Widget _buildLoginContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        children: [
          SizedBox(height: 8.h),

          // Business Logo
          const BusinessLogoWidget(),

          SizedBox(height: 6.h),

          // Welcome Text
          Text(
            'Welcome Back!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 24.sp,
                ),
          ),

          SizedBox(height: 1.h),

          Text(
            'Sign in to manage your business',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14.sp,
                ),
          ),

          SizedBox(height: 6.h),

          // Login Form
          LoginFormWidget(
            onLogin: _handleLogin,
            isLoading: _isLoading,
          ),

          SizedBox(height: 4.h),

          // Demo Credentials Info
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Demo Credentials:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Admin: admin@shivsatya.com / admin123\nManager: manager@shivsatya.com / manager123\nStaff: staff@shivsatya.com / staff123',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10.sp,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildBiometricPrompt() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: BiometricPromptWidget(
            onBiometricLogin: _handleBiometricSetup,
            onSkip: _skipBiometric,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Login Content
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: _buildLoginContent(),
            ),

            // Biometric Prompt Overlay
            if (_showBiometricPrompt) _buildBiometricPrompt(),
          ],
        ),
      ),
    );
  }
}
