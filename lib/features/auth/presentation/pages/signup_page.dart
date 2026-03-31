import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/services/firebase_otp_service.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/social_login_button.dart';
import '../../../../shared/widgets/auth_tab_switcher.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_layout.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  
  // Firebase OTP Service
  final FirebaseOtpService _otpService = GetIt.instance<FirebaseOtpService>();
  
  bool _obscurePassword = true;
  bool _hasNavigated = false;
  DateTime? _selectedDOB;
  bool _isMinor = false;
  bool _otpSent = false;
  bool _otpVerified = false;
  bool _isOtpLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    _parentPhoneController.dispose();
    super.dispose();
  }

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectDOB() async {
    final now = DateTime.now();
    final minDate = DateTime(now.year - 100, 1, 1);
    final maxDate = DateTime(now.year - 13, now.month, now.day); // Must be at least 13
    
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDOB ?? maxDate,
      firstDate: minDate,
      lastDate: maxDate,
      helpText: 'Select your date of birth',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDOB = picked;
        _isMinor = _calculateAge(picked) < 18;
      });
    }
  }

  void _handleSendOTP() async {
    if (_mobileController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a phone number'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Format phone number to E.164 format (add + if not present)
    String phoneNumber = _mobileController.text.trim();
    if (!phoneNumber.startsWith('+')) {
      // Assuming Indian numbers if no country code - adjust as needed
      phoneNumber = '+91$phoneNumber';
    }

    setState(() {
      _isOtpLoading = true;
    });

    try {
      final result = await _otpService.sendOtp(phoneNumber);
      
      if (!mounted) return;
      
      if (result.autoVerified) {
        // Phone was auto-verified (Android SMS auto-retrieval)
        setState(() {
          _otpSent = true;
          _otpVerified = true;
          _isOtpLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number automatically verified!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        setState(() {
          _otpSent = true;
          _isOtpLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent! Check your SMS'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } on OtpException catch (e) {
      if (!mounted) return;
      setState(() {
        _isOtpLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isOtpLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send OTP: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleVerifyOTP() async {
    if (_otpController.text.isEmpty || _otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isOtpLoading = true;
    });

    try {
      final verified = await _otpService.verifyOtp(_otpController.text.trim());
      
      if (!mounted) return;
      
      if (verified) {
        setState(() {
          _otpVerified = true;
          _isOtpLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number verified!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } on OtpException catch (e) {
      if (!mounted) return;
      setState(() {
        _isOtpLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isOtpLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to verify OTP: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleSignup() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDOB == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your date of birth'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (!_otpVerified && _mobileController.text.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please verify your phone number with OTP'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (_isMinor && _parentPhoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Parent/Guardian phone number is required for users under 18'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      context.read<AuthBloc>().add(
        AuthSignupRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          dateOfBirth: DateFormat('yyyy-MM-dd').format(_selectedDOB!),
          phone: _mobileController.text.trim(),
          parentPhone: _isMinor ? _parentPhoneController.text.trim() : null,
          otpCode: _otpController.text.trim(),
        ),
      );
    }
  }

  void _handleGoogleSignup() {
    context.read<AuthBloc>().add(const AuthGoogleLoginRequested());
  }

  Future<void> _launchGoogleOAuth(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Google Sign-In. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: AppDimensions.paddingMD,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        return previous.status != current.status ||
            previous.assessmentCompleted != current.assessmentCompleted;
      },
      listener: (context, state) {
        if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state.status == AuthStatus.googleOAuthRequired) {
          if (state.googleOAuthUrl != null) {
            _launchGoogleOAuth(state.googleOAuthUrl!);
          }
        } else if (state.status == AuthStatus.authenticated) {
          if (!_hasNavigated) {
            _hasNavigated = true;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage ?? 'Signup successful!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
          
          // Trigger assessment status check if not yet known
          // Router will handle navigation once assessment status is set
          if (state.assessmentCompleted == null) {
            context.read<AuthBloc>().add(const AuthCheckAssessmentStatus());
          }
          // Navigation is handled by GoRouter's redirect based on auth state
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
                      isLogin: false,
                      onLoginTap: () {
                        context.go(AppRouter.login);
                      },
                      onRegisterTap: () {},
                    ),

                    const SizedBox(height: AppDimensions.paddingLG),

                    // Full Name Field
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
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                      ),
                      validator: Validators.validateName,
                    ),

                    const SizedBox(height: AppDimensions.paddingMD),

                    // Date of Birth Field
                    const Text(
                      'Date of Birth',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingSM),
                    InkWell(
                      onTap: _selectDOB,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingMD,
                          vertical: AppDimensions.paddingMD,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: AppColors.textTertiary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedDOB != null
                                    ? DateFormat('MMM dd, yyyy').format(_selectedDOB!)
                                    : 'Select your date of birth',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _selectedDOB != null
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ),
                            if (_isMinor)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Under 18',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingMD),

                    // Email Field
                    const Text(
                      'Email',
                      style: TextStyle(
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
                        hintText: '[email protected]',
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                      ),
                      validator: Validators.validateEmail,
                    ),

                    const SizedBox(height: AppDimensions.paddingMD),

                    // Mobile Number Field with OTP
                    const Text(
                      'Mobile Number',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingSM),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            enabled: !_otpVerified,
                            decoration: _buildInputDecoration(
                              hintText: '+91-9876543210',
                              prefixIcon: const Icon(
                                Icons.phone_outlined,
                                color: AppColors.textTertiary,
                                size: 20,
                              ),
                              suffixIcon: _otpVerified
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: AppColors.success,
                                      size: 20,
                                    )
                                  : null,
                            ),
                            validator: Validators.validatePhoneNumber,
                          ),
                        ),
                        if (!_otpVerified) ...[
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: (isLoading || _isOtpLoading) ? null : _handleSendOTP,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                                ),
                              ),
                              child: _isOtpLoading && !_otpSent
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(_otpSent ? 'Resend' : 'Send OTP'),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // OTP Input Field (shown after OTP is sent)
                    if (_otpSent && !_otpVerified) ...[
                      const SizedBox(height: AppDimensions.paddingMD),
                      const Text(
                        'Enter OTP',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingSM),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: _buildInputDecoration(
                                hintText: '6-digit OTP',
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: AppColors.textTertiary,
                                  size: 20,
                                ),
                              ).copyWith(counterText: ''),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: (isLoading || _isOtpLoading) ? null : _handleVerifyOTP,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                                ),
                              ),
                              child: _isOtpLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Verify'),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Parent/Guardian Phone (shown for minors)
                    if (_isMinor) ...[
                      const SizedBox(height: AppDimensions.paddingMD),
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingMD),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                          border: Border.all(
                            color: AppColors.warning.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppColors.warning,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Parental Consent Required',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Since you are under 18, we need your parent or guardian\'s phone number for verification.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingMD),
                            TextFormField(
                              controller: _parentPhoneController,
                              keyboardType: TextInputType.phone,
                              decoration: _buildInputDecoration(
                                hintText: 'Parent/Guardian phone number',
                                prefixIcon: const Icon(
                                  Icons.family_restroom,
                                  color: AppColors.textTertiary,
                                  size: 20,
                                ),
                              ),
                              validator: (value) {
                                if (_isMinor && (value == null || value.isEmpty)) {
                                  return 'Parent/Guardian phone is required';
                                }
                                return Validators.validatePhoneNumber(value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppDimensions.paddingMD),

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
                        hintText: 'Create a strong password',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
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

                    const SizedBox(height: AppDimensions.paddingLG),

                    // Signup Button
                    GradientButton(
                      text: 'Create Account',
                      onPressed: isLoading ? null : _handleSignup,
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

                    // Social Signup Buttons
                    Row(
                      children: [
                        Expanded(
                          child: SocialLoginButton(
                            text: 'Google',
                            icon: Image.network(
                              'https://www.google.com/favicon.ico',
                              width: 20,
                              height: 20,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.g_mobiledata, size: 24);
                              },
                            ),
                            onPressed: isLoading ? null : _handleGoogleSignup,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingMD),
                        Expanded(
                          child: SocialLoginButton(
                            text: 'LinkedIn',
                            icon: const Icon(
                              Icons.business,
                              color: Color(0xFF0A66C2),
                              size: 20,
                            ),
                            onPressed: isLoading ? null : () {},
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
      },
    );
  }
}
