import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_state.dart';
import '../../bloc/profile_event.dart';
import '../edit_forms/profile_item_dialog.dart';
import '../../../domain/models/profile_model.dart';

/// Achievements section - displays certifications, projects, and awards in tabs
class AchievementsSection extends StatefulWidget {
  const AchievementsSection({super.key});

  @override
  State<AchievementsSection> createState() => _AchievementsSectionState();
}

class _AchievementsSectionState extends State<AchievementsSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (!state.hasProfile) {
          return const Center(child: Text('No profile data'));
        }

        return Column(
          children: [
            // Tab Bar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[700],
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Certifications'),
                  Tab(text: 'Projects'),
                  Tab(text: 'Awards'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _CertificationsTab(),
                  _ProjectsTab(),
                  _AwardsTab(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Certifications Tab
class _CertificationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (!state.hasProfile) {
          return const Center(child: Text('No profile data'));
        }

        // Get real certifications from profile
        final certifications = state.profile!.certifications;

        return Stack(
          children: [
            if (certifications.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No certifications added yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to add your certifications',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: certifications.length,
                itemBuilder: (context, index) {
                  final cert = certifications[index];
                  return _buildCertificationCard(context, cert, index);
                },
              ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'add_cert',
                onPressed: () async {
                  final result = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) => const ProfileItemDialog(
                      type: ProfileItemType.certification,
                    ),
                  );
                  if (result != null && context.mounted) {
                    context.read<ProfileBloc>().add(
                      ProfileCertificationAdded(
                        name: result['name'] as String,
                        issuer: result['issuer'] as String,
                        issueDate: result['issueDate'] as DateTime,
                        expiryDate: result['expiryDate'] as DateTime?,
                        credentialUrl: result['credentialUrl'] as String? ?? '',
                      ),
                    );
                  }
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCertificationCard(BuildContext context, Certification cert, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.verified, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cert.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cert.issuer,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Issued: ${DateFormat('MMM yyyy').format(cert.issueDate)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                if (cert.expiryDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Expires: ${DateFormat('MMM yyyy').format(cert.expiryDate!)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[600]),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
            onSelected: (value) async {
              if (value == 'edit') {
                final certData = {
                  'name': cert.name,
                  'issuer': cert.issuer,
                  'issueDate': cert.issueDate,
                  'expiryDate': cert.expiryDate,
                  'credentialUrl': cert.credentialUrl,
                };
                final result = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (context) => ProfileItemDialog(
                    type: ProfileItemType.certification,
                    initialData: certData,
                  ),
                );
                if (result != null && context.mounted) {
                  context.read<ProfileBloc>().add(
                    ProfileCertificationUpdated(
                      index: index,
                      name: result['name'] as String,
                      issuer: result['issuer'] as String,
                      issueDate: result['issueDate'] as DateTime,
                      expiryDate: result['expiryDate'] as DateTime?,
                      credentialUrl: result['credentialUrl'] as String? ?? '',
                    ),
                  );
                }
              } else if (value == 'delete') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Certification'),
                    content: Text('Are you sure you want to delete "${cert.name}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  context.read<ProfileBloc>().add(
                    ProfileCertificationDeleted(index: index),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Projects Tab
class _ProjectsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (!state.hasProfile) {
          return const Center(child: Text('No profile data'));
        }

        // Get real projects from profile
        final projects = state.profile!.projects;

        return Stack(
          children: [
            if (projects.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No projects added yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to add your projects',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return _buildProjectCard(context, project, index);
                },
              ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'add_project',
                onPressed: () async {
                  final result = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) => const ProfileItemDialog(
                      type: ProfileItemType.project,
                    ),
                  );
                  if (result != null && context.mounted) {
                    context.read<ProfileBloc>().add(
                      ProfileProjectAdded(
                        name: result['name'] as String,
                        description: result['description'] as String,
                        startDate: result['startDate'] as DateTime,
                        endDate: result['endDate'] as DateTime?,
                        current: result['current'] as bool? ?? false,
                        url: result['url'] as String? ?? '',
                        technologies: List<String>.from(result['technologies'] as List? ?? []),
                      ),
                    );
                  }
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  project.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[600]),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'edit') {
                    final projectData = {
                      'name': project.name,
                      'description': project.description,
                      'startDate': project.startDate,
                      'endDate': project.endDate,
                      'current': project.current,
                      'url': project.url,
                      'technologies': project.technologies,
                    };
                    final result = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (context) => ProfileItemDialog(
                        type: ProfileItemType.project,
                        initialData: projectData,
                      ),
                    );
                    if (result != null && context.mounted) {
                      context.read<ProfileBloc>().add(
                        ProfileProjectUpdated(
                          index: index,
                          name: result['name'] as String,
                          description: result['description'] as String,
                          startDate: result['startDate'] as DateTime,
                          endDate: result['endDate'] as DateTime?,
                          current: result['current'] as bool? ?? false,
                          url: result['url'] as String? ?? '',
                          technologies: List<String>.from(result['technologies'] as List? ?? []),
                        ),
                      );
                    }
                  } else if (value == 'delete') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Project'),
                        content: Text('Are you sure you want to delete "${project.name}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      context.read<ProfileBloc>().add(
                        ProfileProjectDeleted(index: index),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            project.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: project.technologies
                .map((tech) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tech,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

/// Awards Tab
class _AwardsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (!state.hasProfile) {
          return const Center(child: Text('No profile data'));
        }

        // Get real awards from profile
        final awards = state.profile!.awards;

        return Stack(
          children: [
            if (awards.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No awards added yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to add your awards',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: awards.length,
                itemBuilder: (context, index) {
                  final award = awards[index];
                  return _buildAwardCard(context, award, index);
                },
              ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'add_award',
                onPressed: () async {
                  final result = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) => const ProfileItemDialog(
                      type: ProfileItemType.award,
                    ),
                  );
                  if (result != null && context.mounted) {
                    context.read<ProfileBloc>().add(
                      ProfileAwardAdded(
                        title: result['title'] as String,
                        issuer: result['issuer'] as String,
                        date: result['date'] as DateTime,
                        description: result['description'] as String? ?? '',
                      ),
                    );
                  }
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAwardCard(BuildContext context, Award award, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  award.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  award.issuer,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('MMM yyyy').format(award.date),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[600]),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
            onSelected: (value) async {
              if (value == 'edit') {
                final awardData = {
                  'title': award.title,
                  'issuer': award.issuer,
                  'date': award.date,
                  'description': award.description,
                };
                final result = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (context) => ProfileItemDialog(
                    type: ProfileItemType.award,
                    initialData: awardData,
                  ),
                );
                if (result != null && context.mounted) {
                  context.read<ProfileBloc>().add(
                    ProfileAwardUpdated(
                      index: index,
                      title: result['title'] as String,
                      issuer: result['issuer'] as String,
                      date: result['date'] as DateTime,
                      description: result['description'] as String? ?? '',
                    ),
                  );
                }
              } else if (value == 'delete') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Award'),
                    content: Text('Are you sure you want to delete "${award.title}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  context.read<ProfileBloc>().add(
                    ProfileAwardDeleted(index: index),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
