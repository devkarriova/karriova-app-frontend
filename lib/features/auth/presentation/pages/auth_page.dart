import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/social_login_button.dart';
import '../../../../shared/widgets/auth_tab_switcher.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_layout.dart';

class AuthPage extends StatefulWidget {
  final bool initiallyShowLogin;

  const AuthPage({
    super.key,
    this.initiallyShowLogin = true,
  });

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late bool _isLoginMode;

  @override
  void initState() {
    super.initState();
    _isLoginMode = widget.initiallyShowLogin;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _formKey.currentState?.reset();
    });
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_isLoginMode) {
        context.read<AuthBloc>().add(
              AuthLoginRequested(
                email: _emailController.text.trim(),
                password: _passwordController.text,
              ),
            );
      } else {
        context.read<AuthBloc>().add(
              AuthSignupRequested(
                email: _emailController.text.trim(),
                password: _passwordController.text,
                name: _nameController.text.trim(),
              ),
            );
      }
    }
  }

  void _handleSocialLogin(String provider) {
    context.read<AuthBloc>().add(const AuthGoogleLoginRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state.status == AuthStatus.authenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ??
                  '${_isLoginMode ? 'Login' : 'Signup'} successful!'),
              backgroundColor: AppColors.success,
            ),
          );
          
          // Check assessment status first
          if (state.assessmentCompleted == null) {
            // Need to check assessment status from backend
            context.read<AuthBloc>().add(const AuthCheckAssessmentStatus());
          } else if (state.assessmentCompleted == false) {
            // User hasn't completed assessment - redirect to assessment page
            context.go(AppRouter.assessment);
          } else {
            // User has completed assessment - go to feed
            context.go(AppRouter.feed);
          }
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;

        return AuthLayout(
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    const Text(
                      'Welcome to Karriova',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingSM),
                    const Text(
                      'Join thousands of students building their future',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingLG),

                    // Tab Switcher
                    AuthTabSwitcher(
                      isLogin: _isLoginMode,
                      onLoginTap: () {
                        if (!_isLoginMode) _toggleMode();
                      },
                      onRegisterTap: () {
                        if (_isLoginMode) _toggleMode();
                      },
                    ),

                    const SizedBox(height: AppDimensions.paddingLG),

                    // Form Fields - Animated transition
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Full Name (only for signup)
                          if (!_isLoginMode) ...[
                            const Text(
                              'Full Name',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingSM),
                            TextFormField(
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                              decoration: _buildInputDecoration(
                                hintText: 'Enter your full name',
                                suffixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: AppColors.textTertiary,
                                  size: 20,
                                ),
                              ),
                              validator: !_isLoginMode
                                  ? Validators.validateName
                                  : null,
                            ),
                            const SizedBox(height: AppDimensions.paddingMD),
                          ],

                          // Email (both modes) or Email/Mobile (login only)
                          Text(
                            _isLoginMode ? 'Email or Mobile' : 'Email',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingSM),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _buildInputDecoration(
                              hintText: _isLoginMode
                                  ? '[email protected] or +91-9876543210'
                                  : '[email protected]',
                              prefixIcon: _isLoginMode
                                  ? null
                                  : const Icon(
                                      Icons.email_outlined,
                                      color: AppColors.textTertiary,
                                      size: 20,
                                    ),
                              suffixIcon: _isLoginMode
                                  ? const Icon(
                                      Icons.lock_outline,
                                      color: AppColors.textTertiary,
                                      size: 20,
                                    )
                                  : null,
                            ),
                            validator: Validators.validateEmail,
                          ),

                          const SizedBox(height: AppDimensions.paddingMD),

                          // Mobile Number (only for signup)
                          if (!_isLoginMode) ...[
                            const Text(
                              'Mobile Number',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingSM),
                            TextFormField(
                              controller: _mobileController,
                              keyboardType: TextInputType.phone,
                              decoration: _buildInputDecoration(
                                hintText: '+91-9876543210',
                                prefixIcon: const Icon(
                                  Icons.phone_outlined,
                                  color: AppColors.textTertiary,
                                  size: 20,
                                ),
                                suffixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: AppColors.textTertiary,
                                  size: 20,
                                ),
                              ),
                              validator: !_isLoginMode
                                  ? Validators.validatePhoneNumber
                                  : null,
                            ),
                            const SizedBox(height: AppDimensions.paddingMD),
                          ],

                          // Password Field
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingSM),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: _buildInputDecoration(
                              hintText: _isLoginMode
                                  ? 'Enter your password'
                                  : 'Create a strong password',
                              prefixIcon: !_isLoginMode
                                  ? const Icon(
                                      Icons.lock_outline,
                                      color: AppColors.textTertiary,
                                      size: 20,
                                    )
                                  : null,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textTertiary,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: Validators.validatePassword,
                          ),

                          // Forgot Password (only for login)
                          if (_isLoginMode) ...[
                            const SizedBox(height: AppDimensions.paddingSM),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // TODO: Implement forgot password
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingMD),

                    // Submit Button
                    GradientButton(
                      text: _isLoginMode ? 'Login' : 'Send OTP',
                      onPressed: isLoading ? null : _handleSubmit,
                      isLoading: isLoading,
                    ),

                    const SizedBox(height: AppDimensions.paddingLG),

                    // Divider
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingMD,
                          ),
                          child: Text(
                            'OR CONTINUE WITH',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.paddingLG),

                    // Google SSO Button
                    SocialLoginButton(
                      text: 'Continue with Google',
                      icon: Image.network(
                        'https://www.google.com/favicon.ico',
                        width: 20,
                        height: 20,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.g_mobiledata, size: 24);
                        },
                      ),
                      onPressed: isLoading
                          ? null
                          : () => _handleSocialLogin('google'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: AppColors.textTertiary,
        fontSize: 14,
      ),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        borderSide: const BorderSide(
          color: AppColors.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: AppDimensions.paddingMD,
      ),
    );
  }
}
