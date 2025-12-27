import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_state.dart';
import '../../bloc/profile_event.dart';

/// About section - displays user bio and career goals
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (!state.hasProfile) {
          return const Center(
            child: Text(
              'No profile data available',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final profile = state.profile!;
        final bio = profile.bio;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // About Card
              _buildCard(
                context: context,
                title: 'About',
                onEdit: () => _showEditBioDialog(context, bio),
                child: bio.isNotEmpty
                    ? Text(
                        bio,
                        style: const TextStyle(fontSize: 13, height: 1.5),
                      )
                    : Text(
                        'No bio added yet. Click edit to add your bio.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              // Career Goals Card
              _buildCard(
                context: context,
                title: 'Career Goals',
                onEdit: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Career goals feature coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Text(
                  'No career goals added yet',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditBioDialog(BuildContext context, String currentBio) {
    final TextEditingController bioController = TextEditingController(text: currentBio);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit About'),
        content: TextField(
          controller: bioController,
          maxLines: 6,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Tell us about yourself...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newBio = bioController.text.trim();
              context.read<ProfileBloc>().add(
                ProfilePersonalDetailsUpdated(bio: newBio),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((_) => bioController.dispose());
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required Widget child,
    required VoidCallback onEdit,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Edit Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 16),
                onPressed: onEdit,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                iconSize: 16,
                color: Colors.grey[600],
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
