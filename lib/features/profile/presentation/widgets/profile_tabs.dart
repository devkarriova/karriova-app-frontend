import 'package:flutter/material.dart';
import 'profile_sections/about_section.dart';
import 'profile_sections/education_section.dart';
import 'profile_sections/experience_section.dart';
import 'profile_sections/skills_section.dart';
import 'profile_sections/achievements_section.dart';

/// Profile tabs widget - About, Education, Experience, Skills, Achievements
class ProfileTabs extends StatefulWidget {
  const ProfileTabs({super.key});

  @override
  State<ProfileTabs> createState() => _ProfileTabsState();
}

class _ProfileTabsState extends State<ProfileTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
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
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicator: const BoxDecoration(),
            dividerColor: Colors.transparent,
            labelColor: const Color(0xFFFF6B9D),
            unselectedLabelColor: Colors.grey[600],
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            tabs: const [
              Tab(text: 'About'),
              Tab(text: 'Education'),
              Tab(text: 'Experience'),
              Tab(text: 'Skills'),
              Tab(text: 'Achievements'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tab Content
        SizedBox(
          height: 600, // Fixed height for tab content
          child: TabBarView(
            controller: _tabController,
            children: const [
              AboutSection(),
              EducationSection(),
              ExperienceSection(),
              SkillsSection(),
              AchievementsSection(),
            ],
          ),
        ),
      ],
    );
  }
}
