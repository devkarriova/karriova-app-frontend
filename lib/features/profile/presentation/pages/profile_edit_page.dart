import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/edit_forms/basic_info_edit_form.dart';
import '../widgets/edit_forms/experience_edit_form.dart';
import '../widgets/edit_forms/education_edit_form.dart';
import '../widgets/edit_forms/skills_edit_form.dart';
import '../widgets/edit_forms/certifications_edit_form.dart';
import '../widgets/edit_forms/projects_edit_form.dart';
import '../widgets/edit_forms/languages_edit_form.dart';
import '../widgets/edit_forms/awards_edit_form.dart';

/// Minimalist profile edit page with all sections
class ProfileEditPage extends StatelessWidget {
  const ProfileEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 8,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: const TabBar(
                isScrollable: true,
                indicatorColor: AppColors.primary,
                indicatorWeight: 2,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                tabs: [
                  Tab(text: 'Basic'),
                  Tab(text: 'Experience'),
                  Tab(text: 'Education'),
                  Tab(text: 'Skills'),
                  Tab(text: 'Certifications'),
                  Tab(text: 'Projects'),
                  Tab(text: 'Languages'),
                  Tab(text: 'Awards'),
                ],
              ),
            ),
          ),
        ),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listenWhen: (previous, current) {
            // Only listen when status actually changes
            return previous.status != current.status;
          },
          listener: (context, state) {
            if (state.status == ProfileStatus.updateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              // Reload profile after update
              context.read<ProfileBloc>().add(const ProfileRefreshRequested());
            } else if (state.status == ProfileStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'An error occurred'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == ProfileStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state.profile == null) {
              return const Center(
                child: Text(
                  'No profile data available',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            return TabBarView(
              children: [
                BasicInfoEditForm(profile: state.profile!),
                ExperienceEditForm(profile: state.profile!),
                EducationEditForm(profile: state.profile!),
                SkillsEditForm(profile: state.profile!),
                CertificationsEditForm(profile: state.profile!),
                ProjectsEditForm(profile: state.profile!),
                LanguagesEditForm(profile: state.profile!),
                AwardsEditForm(profile: state.profile!),
              ],
            );
          },
        ),
      ),
    );
  }
}
