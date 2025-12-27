import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../domain/models/profile_model.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_event.dart';
import 'common/custom_text_field.dart';

/// Form for editing basic profile information
class BasicInfoEditForm extends StatefulWidget {
  final ProfileModel profile;

  const BasicInfoEditForm({super.key, required this.profile});

  @override
  State<BasicInfoEditForm> createState() => _BasicInfoEditFormState();
}

class _BasicInfoEditFormState extends State<BasicInfoEditForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _headlineController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _websiteController;

  @override
  void initState() {
    super.initState();
    _headlineController = TextEditingController(text: widget.profile.headline);
    _bioController = TextEditingController(text: widget.profile.bio);
    _locationController = TextEditingController(text: widget.profile.location);
    _websiteController = TextEditingController(text: widget.profile.website);
  }

  @override
  void dispose() {
    _headlineController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _saveBasicInfo() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ProfileBloc>().add(
            ProfileHeadlineUpdated(headline: _headlineController.text.trim()),
          );
      context.read<ProfileBloc>().add(
            ProfileBioUpdated(bio: _bioController.text.trim()),
          );
      context.read<ProfileBloc>().add(
            ProfileLocationUpdated(location: _locationController.text.trim()),
          );
      context.read<ProfileBloc>().add(
            ProfileWebsiteUpdated(website: _websiteController.text.trim()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card container for clean look
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Basic Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tell others about yourself',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Headline',
                    hint: 'e.g., Software Engineer at Google',
                    controller: _headlineController,
                    maxLength: 120,
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) {
                        return 'Please enter a headline';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Bio',
                    hint: 'Write a short bio about yourself...',
                    controller: _bioController,
                    maxLines: 4,
                    maxLength: 500,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Location',
                    hint: 'e.g., San Francisco, CA',
                    controller: _locationController,
                    prefix: const Icon(Icons.location_on_outlined, size: 20),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Website',
                    hint: 'https://yourwebsite.com',
                    controller: _websiteController,
                    keyboardType: TextInputType.url,
                    prefix: const Icon(Icons.link, size: 20),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!value.startsWith('http://') &&
                            !value.startsWith('https://')) {
                          return 'Please enter a valid URL';
                        }
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Save button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _saveBasicInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
