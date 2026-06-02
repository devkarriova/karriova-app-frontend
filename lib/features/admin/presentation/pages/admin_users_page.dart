import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/header/app_header.dart';
import '../../../../core/widgets/navigation/app_navigation_bar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  static const List<String> _roles = ['all', 'admin', 'user', 'recruiter', 'company', 'mentor'];

  final ApiClient _apiClient = getIt<ApiClient>();
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<AuthState>? _authSubscription;

  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String? _error;
  String _selectedRole = 'all';
  bool _activeOnly = false;

  @override
  void initState() {
    super.initState();
    _loadWhenAuthenticated();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _loadWhenAuthenticated() {
    final authBloc = getIt<AuthBloc>();
    final authState = authBloc.state;

    if (authState.status == AuthStatus.authenticated) {
      _loadUsers();
      return;
    }

    if (authState.status == AuthStatus.unauthenticated) {
      setState(() {
        _loading = false;
        _error = 'Your session is no longer active. Please sign in again.';
      });
      return;
    }

    _authSubscription?.cancel();
    _authSubscription = authBloc.stream.listen((state) {
      if (!mounted) return;
      if (state.status == AuthStatus.authenticated) {
        _authSubscription?.cancel();
        _authSubscription = null;
        _loadUsers();
      } else if (state.status == AuthStatus.unauthenticated) {
        _authSubscription?.cancel();
        _authSubscription = null;
        setState(() {
          _loading = false;
          _error = 'Your session is no longer active. Please sign in again.';
        });
      }
    });
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final response = await _apiClient.get(
      '/admin/users',
      requiresAuth: true,
      queryParams: {
        'limit': '100',
        'offset': '0',
        if (_selectedRole != 'all') 'role': _selectedRole,
        if (_searchController.text.trim().isNotEmpty) 'search': _searchController.text.trim(),
        if (_activeOnly) 'active_only': 'true',
      },
    );

    if (!mounted) return;

    if (response.isSuccess && response.data != null) {
      final users = (response.data['users'] as List? ?? [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      setState(() {
        _users = users;
        _loading = false;
      });
      return;
    }

    setState(() {
      _error = response.errorMessage ?? 'Failed to load users';
      _loading = false;
    });
  }

  Future<void> _updateUserRole(String userId, String role) async {
    final response = await _apiClient.put(
      '/admin/users/$userId/role',
      requiresAuth: true,
      body: {'role': role},
    );

    if (!mounted) return;

    if (response.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User role updated to ${_prettyRole(role)}'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadUsers();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.errorMessage ?? 'Failed to update user role'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Future<void> _updateUserStatus(String userId, bool isActive) async {
    final response = await _apiClient.put(
      '/admin/users/$userId/status',
      requiresAuth: true,
      body: {'is_active': isActive},
    );

    if (!mounted) return;

    if (response.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isActive ? 'User activated' : 'User deactivated'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadUsers();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.errorMessage ?? 'Failed to update user status'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Future<void> _showCreateUserDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    String selectedRole = 'user';
    bool emailVerified = true;
    bool isActive = true;
    bool submitting = false;
    String? localError;
    bool obscurePassword = true;
    bool obscureConfirmPassword = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: !submitting,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submit() async {
              final name = nameController.text.trim();
              final email = emailController.text.trim();
              final password = passwordController.text;
              final confirmPassword = confirmPasswordController.text;

              if (name.isEmpty || email.isEmpty || password.isEmpty) {
                setDialogState(() => localError = 'Name, email, and password are required.');
                return;
              }
              if (password.length < 8) {
                setDialogState(() => localError = 'Password must be at least 8 characters.');
                return;
              }
              if (password != confirmPassword) {
                setDialogState(() => localError = 'Passwords do not match.');
                return;
              }

              setDialogState(() {
                localError = null;
                submitting = true;
              });

              final response = await _apiClient.post(
                '/admin/users',
                requiresAuth: true,
                body: {
                  'name': name,
                  'email': email,
                  'password': password,
                  'role': selectedRole,
                  'email_verified': emailVerified,
                  'is_active': isActive,
                },
              );

              if (!mounted) return;

              if (response.isSuccess) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('Created ${_prettyRole(selectedRole)} account for $email'),
                    backgroundColor: AppColors.success,
                  ),
                );
                _loadUsers();
                return;
              }

              setDialogState(() {
                localError = response.errorMessage ?? 'Failed to create user';
                submitting = false;
              });
            }

            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text(
                'Create User',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField(
                        controller: nameController,
                        label: 'Full name',
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        controller: emailController,
                        label: 'Email address',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        controller: passwordController,
                        label: 'Temporary password',
                        obscureText: obscurePassword,
                        textInputAction: TextInputAction.next,
                        suffixIcon: IconButton(
                          onPressed: () => setDialogState(() => obscurePassword = !obscurePassword),
                          icon: Icon(
                            obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        controller: confirmPasswordController,
                        label: 'Confirm password',
                        obscureText: obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        suffixIcon: IconButton(
                          onPressed: () => setDialogState(
                            () => obscureConfirmPassword = !obscureConfirmPassword,
                          ),
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        dropdownColor: AppColors.surface,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: _inputDecoration('User type'),
                        items: _roles
                            .where((role) => role != 'all')
                            .map(
                              (role) => DropdownMenuItem<String>(
                                value: role,
                                child: Text(_prettyRole(role)),
                              ),
                            )
                            .toList(),
                        onChanged: submitting
                            ? null
                            : (value) {
                                if (value != null) {
                                  setDialogState(() => selectedRole = value);
                                }
                              },
                      ),
                      if (selectedRole == 'mentor') ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Mentor profile scaffolding will be created automatically.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: emailVerified,
                        activeColor: AppColors.primary,
                        title: const Text(
                          'Email already verified',
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        ),
                        subtitle: const Text(
                          'Use this for manually approved accounts.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        onChanged: submitting
                            ? null
                            : (value) => setDialogState(() => emailVerified = value),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: isActive,
                        activeColor: AppColors.primary,
                        title: const Text(
                          'Activate account immediately',
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        ),
                        subtitle: const Text(
                          'Turn this off if the user should not be able to log in yet.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        onChanged: submitting
                            ? null
                            : (value) => setDialogState(() => isActive = value),
                      ),
                      if (localError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          localError!,
                          style: const TextStyle(color: AppColors.error, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: submitting ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: submitting ? null : submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Create', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: _inputDecoration(label).copyWith(suffixIcon: suffixIcon),
    );
  }

  String _prettyRole(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'user':
        return 'User';
      case 'recruiter':
        return 'Recruiter';
      case 'company':
        return 'Company';
      case 'mentor':
        return 'Mentor';
      default:
        return role;
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.redAccent;
      case 'mentor':
        return Colors.deepPurple;
      case 'recruiter':
        return Colors.orange;
      case 'company':
        return Colors.teal;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _showCreateUserDialog,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text('Create User', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            const AppNavigationBar(currentRoute: AppRouter.admin),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                          onPressed: () => context.go(AppRouter.admin),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'User Management',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Create accounts manually and control role and account access.',
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _loadUsers,
                          icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: (_) => _loadUsers(),
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Search by name or email...',
                              hintStyle: const TextStyle(color: AppColors.textTertiary),
                              prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
                              suffixIcon: IconButton(
                                onPressed: _loadUsers,
                                icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: _selectedRole,
                          dropdownColor: AppColors.surface,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                          underline: const SizedBox(),
                          items: _roles
                              .map(
                                (role) => DropdownMenuItem<String>(
                                  value: role,
                                  child: Text(role == 'all' ? 'All roles' : _prettyRole(role)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedRole = value);
                              _loadUsers();
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        FilterChip(
                          selected: _activeOnly,
                          onSelected: (value) {
                            setState(() => _activeOnly = value);
                            _loadUsers();
                          },
                          label: const Text('Active only'),
                          selectedColor: AppColors.primary.withOpacity(0.15),
                          checkmarkColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                        : _error != null
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(_error!, style: const TextStyle(color: AppColors.error)),
                                    const SizedBox(height: 12),
                                    ElevatedButton(onPressed: _loadUsers, child: const Text('Retry')),
                                  ],
                                ),
                              )
                            : _users.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No users found for the current filters.',
                                      style: TextStyle(color: AppColors.textSecondary),
                                    ),
                                  )
                                : RefreshIndicator(
                                    onRefresh: _loadUsers,
                                    color: AppColors.primary,
                                    child: ListView.separated(
                                      padding: const EdgeInsets.fromLTRB(24, 4, 24, 90),
                                      itemCount: _users.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        final user = _users[index];
                                        final role = (user['user_role'] as String? ?? 'user').toLowerCase();
                                        final isActive = user['is_active'] as bool? ?? true;
                                        final emailVerified = user['email_verified'] as bool? ?? false;
                                        final userId = user['id'] as String;

                                        return Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.surface,
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.04),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 22,
                                                      backgroundColor: _roleColor(role).withOpacity(0.12),
                                                      child: Text(
                                                        ((user['name'] as String?)?.isNotEmpty == true
                                                                ? (user['name'] as String).trim()[0]
                                                                : (user['email'] as String).trim()[0])
                                                            .toUpperCase(),
                                                        style: TextStyle(
                                                          color: _roleColor(role),
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            (user['name'] as String?)?.isNotEmpty == true
                                                                ? user['name'] as String
                                                                : 'Unnamed user',
                                                            style: const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.w600,
                                                              color: AppColors.textPrimary,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 2),
                                                          Text(
                                                            user['email'] as String? ?? '',
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                              color: AppColors.textSecondary,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Wrap(
                                                      spacing: 8,
                                                      runSpacing: 8,
                                                      children: [
                                                        _StatusBadge(
                                                          label: _prettyRole(role),
                                                          color: _roleColor(role),
                                                        ),
                                                        _StatusBadge(
                                                          label: isActive ? 'Active' : 'Inactive',
                                                          color: isActive ? AppColors.success : AppColors.error,
                                                        ),
                                                        _StatusBadge(
                                                          label: emailVerified ? 'Email verified' : 'Email pending',
                                                          color: emailVerified
                                                              ? Colors.green.shade700
                                                              : Colors.orange.shade700,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 14),
                                                Wrap(
                                                  spacing: 24,
                                                  runSpacing: 12,
                                                  crossAxisAlignment: WrapCrossAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Posts: ${user['post_count'] ?? 0}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors.textTertiary,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Followers: ${user['follower_count'] ?? 0}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors.textTertiary,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Created: ${_formatDate(user['created_at'] as String?)}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors.textTertiary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 14),
                                                Wrap(
                                                  spacing: 12,
                                                  runSpacing: 8,
                                                  crossAxisAlignment: WrapCrossAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 180,
                                                      child: DropdownButtonFormField<String>(
                                                        value: role,
                                                        dropdownColor: AppColors.surface,
                                                        style: const TextStyle(color: AppColors.textPrimary),
                                                        decoration: _inputDecoration('Role'),
                                                        items: _roles
                                                            .where((value) => value != 'all')
                                                            .map(
                                                              (value) => DropdownMenuItem<String>(
                                                                value: value,
                                                                child: Text(_prettyRole(value)),
                                                              ),
                                                            )
                                                            .toList(),
                                                        onChanged: (value) {
                                                          if (value != null && value != role) {
                                                            _updateUserRole(userId, value);
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Text(
                                                          'Account access',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: AppColors.textSecondary,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Switch(
                                                          value: isActive,
                                                          activeColor: AppColors.primary,
                                                          onChanged: (value) => _updateUserStatus(userId, value),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return 'Unknown';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final month = _monthLabel(parsed.month);
    return '$month ${parsed.day}, ${parsed.year}';
  }

  String _monthLabel(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[(month - 1).clamp(0, 11)];
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
