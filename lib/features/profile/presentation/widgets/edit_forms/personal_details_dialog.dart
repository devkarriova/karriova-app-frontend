import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/constants/app_colors.dart';

/// Dialog for editing personal account details
class PersonalDetailsDialog extends StatefulWidget {
  final String? initialName;
  final String? initialEmail;
  final String? initialHeadline;
  final String? initialWebsite;
  final bool initialIsPublic;

  const PersonalDetailsDialog({
    super.key,
    this.initialName,
    this.initialEmail,
    this.initialHeadline,
    this.initialWebsite,
    this.initialIsPublic = true,
  });

  @override
  State<PersonalDetailsDialog> createState() => _PersonalDetailsDialogState();
}

class _PersonalDetailsDialogState extends State<PersonalDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _headlineController;
  late TextEditingController _websiteController;
  bool _isPublic = true;
  XFile? _selectedProfileImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _headlineController = TextEditingController(text: widget.initialHeadline);
    _websiteController = TextEditingController(text: widget.initialWebsite);
    _isPublic = widget.initialIsPublic;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _headlineController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedProfileImage = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final result = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'headline': _headlineController.text.trim(),
        'website': _websiteController.text.trim(),
        'isPublic': _isPublic,
        'profileImage': _selectedProfileImage?.path,
      };
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Scrollable Content
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Picture Section
                      _buildProfilePictureSection(),
                      const SizedBox(height: 24),

                      // Name
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'e.g., John Doe',
                        icon: Icons.person_outline,
                        required: true,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'e.g., john.doe@example.com',
                        icon: Icons.email_outlined,
                        required: true,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),

                      // Headline
                      _buildTextField(
                        controller: _headlineController,
                        label: 'Professional Headline',
                        hint: 'e.g., Senior Software Engineer | Full Stack',
                        icon: Icons.work_outline,
                        required: true,
                      ),
                      const SizedBox(height: 16),

                      // Website
                      _buildTextField(
                        controller: _websiteController,
                        label: 'Website',
                        hint: 'e.g., https://yourwebsite.com',
                        icon: Icons.link,
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 24),

                      // Profile Visibility
                      _buildVisibilitySwitch(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.settings,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Edit Personal Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildProfilePictureSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: _selectedProfileImage != null
                    ? FileImage(File(_selectedProfileImage!.path))
                    : null,
                child: _selectedProfileImage == null
                    ? const Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primary,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, size: 16),
                    color: Colors.white,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    onPressed: _pickProfileImage,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _selectedProfileImage != null ? 'Change Profile Picture' : 'Add Profile Picture',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: validator ??
          (value) {
            if (required && (value == null || value.trim().isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
    );
  }

  Widget _buildVisibilitySwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            _isPublic ? Icons.public : Icons.lock_outline,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile Visibility',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isPublic
                      ? 'Your profile is visible to everyone'
                      : 'Your profile is only visible to you',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isPublic,
            onChanged: (value) {
              setState(() {
                _isPublic = value;
              });
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(100, 40),
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }
}
