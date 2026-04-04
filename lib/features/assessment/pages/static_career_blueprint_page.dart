import 'package:flutter/material.dart';
import 'package:karriova_app/core/constants/app_colors.dart';
import 'package:karriova_app/core/theme/app_typography.dart';

/// Static Career Blueprint UI - No API calls, all data hardcoded
/// Shows carousel with 3 careers and detail view with 14 sections
class StaticCareerBlueprintPage extends StatefulWidget {
  const StaticCareerBlueprintPage({Key? key}) : super(key: key);

  @override
  State<StaticCareerBlueprintPage> createState() => _StaticCareerBlueprintPageState();
}

class _StaticCareerBlueprintPageState extends State<StaticCareerBlueprintPage> {
  int _selectedCareerIndex = 0;
  bool _showDetail = false;
  final Set<int> _expandedSections = {0, 1}; // First 2 sections expanded by default

  final List<_CareerData> _careers = [
    _CareerData(
      name: 'Full Stack Software Engineer',
      category: 'Technology & Engineering',
      fitScore: 8.5,
      difficulty: 'low',
      confidence: 'high',
    ),
    _CareerData(
      name: 'Data Scientist',
      category: 'Technology & Analytics',
      fitScore: 7.8,
      difficulty: 'medium',
      confidence: 'high',
    ),
    _CareerData(
      name: 'Product Manager',
      category: 'Business & Strategy',
      fitScore: 7.2,
      difficulty: 'medium',
      confidence: 'medium',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _showDetail ? _buildDetailView() : _buildCarouselView();
  }

  Widget _buildCarouselView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Career Options'),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Explore Your Paths',
                    style: AppTypography.heading2,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Swipe to explore your top 3 career matches.\nSelect one to dive deep into your personalized roadmap.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Carousel
            SizedBox(
              height: 520,
              child: PageView.builder(
                onPageChanged: (index) {
                  setState(() => _selectedCareerIndex = index);
                },
                itemCount: _careers.length,
                itemBuilder: (context, index) {
                  final career = _careers[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildCareerCard(career),
                  );
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _careers.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _selectedCareerIndex
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                ),
              ),
            ),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Total Matches',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_careers.length}',
                          style: AppTypography.heading3.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'Top Match',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _careers.first.fitScore.toStringAsFixed(1),
                          style: AppTypography.heading3.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareerCard(_CareerData career) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCareerIndex = _careers.indexOf(career);
          _showDetail = true;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fit score badge
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Match: ${career.fitScore.toStringAsFixed(1)}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Career name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                career.name,
                style: AppTypography.heading3,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 4),

            // Category
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                career.category,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 12),

            // Difficulty and Confidence badges
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(career.difficulty).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Difficulty: ${career.difficulty}',
                        style: AppTypography.caption.copyWith(
                          color: _getDifficultyColor(career.difficulty),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Fit: ${career.confidence}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // CTA Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedCareerIndex = _careers.indexOf(career);
                      _showDetail = true;
                    });
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('View Full Blueprint'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailView() {
    final career = _careers[_selectedCareerIndex];
    final sections = _get14Sections();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _showDetail = false),
        ),
        title: Text(career.name),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              color: AppColors.lightBlue,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          '${career.fitScore.toStringAsFixed(1)} Match',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    career.name,
                    style: AppTypography.heading2.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    career.category,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Stats
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Difficulty', career.difficulty),
                  _buildStatItem('Fit Level', career.confidence),
                  _buildStatItem('Sections', '${sections.length}'),
                ],
              ),
            ),

            // Sections
            ...sections.asMap().entries.map((entry) {
              final index = entry.key;
              final section = entry.value;
              final isExpanded = _expandedSections.contains(index);

              return isExpanded
                  ? _buildExpandedSection(index, section)
                  : _buildCollapsedSection(index, section);
            }).toList(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildExpandedSection(int index, _SectionData section) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _expandedSections.remove(index);
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    section.icon,
                    color: section.color,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      section.title,
                      style: AppTypography.heading3.copyWith(fontSize: 18),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_up,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (section.description.isNotEmpty) ...[
                  Text(
                    section.description,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                ...section.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 16)),
                          Expanded(
                            child: Text(item, style: AppTypography.body),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedSection(int index, _SectionData section) {
    return InkWell(
      onTap: () {
        setState(() {
          _expandedSections.add(index);
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              section.icon,
              color: section.color,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                section.title,
                style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'low':
        return const Color(0xFF10B981);
      case 'medium':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFFEF4444);
    }
  }

  List<_SectionData> _get14Sections() {
    return [
      _SectionData(
        title: 'Why This Career Fits You',
        description: 'Based on your assessment, this career aligns perfectly with your strengths.',
        icon: Icons.lightbulb_outline,
        color: const Color(0xFF3B82F6),
        items: [
          'Strong analytical thinking (scored 92%)',
          'Creative problem-solving approach',
          'Interest in technology and innovation',
          'Team-oriented mindset',
        ],
      ),
      _SectionData(
        title: 'Your Unique Journey',
        description: 'Your specific skills create a distinctive path into this field.',
        icon: Icons.lightbulb_outline,
        color: const Color(0xFF3B82F6),
        items: [
          'Leverage your existing analytical skills',
          'Build on your tech interest',
          'Start with fundamentals',
          'Join communities early',
        ],
      ),
      _SectionData(
        title: 'Detailed Roadmap (24 Months)',
        description: 'Month-by-month plan to transition into this career.',
        icon: Icons.timeline_outlined,
        color: const Color(0xFF10B981),
        items: [
          'Months 0-6: Learn fundamentals, build portfolio',
          'Months 7-12: Master frameworks and tools',
          'Months 13-18: Develop professional skills',
          'Months 19-24: Job hunt and interviews',
        ],
      ),
      _SectionData(
        title: 'Reality Check',
        description: 'Challenges you should be aware of before committing.',
        icon: Icons.warning_amber_outlined,
        color: const Color(0xFFEF4444),
        items: [
          'Steep learning curve (6-12 months)',
          'Constant need to learn new technologies',
          'Can be mentally exhausting',
          'High competition for entry-level roles',
        ],
      ),
      _SectionData(
        title: 'Salary & Growth',
        description: 'Expected earnings over your career.',
        icon: Icons.bar_chart_outlined,
        color: const Color(0xFFF59E0B),
        items: [
          'Entry Level (0-2 years): ₹4-8 LPA',
          'Mid Level (3-5 years): ₹8-15 LPA',
          'Senior (6-10 years): ₹15-30 LPA',
          'Lead/Architect (10+ years): ₹30-60+ LPA',
        ],
      ),
      _SectionData(
        title: 'Skills to Develop',
        description: 'The complete skill set you need to master.',
        icon: Icons.list_alt_outlined,
        color: AppColors.textSecondary,
        items: [
          'Programming languages & frameworks',
          'Problem-solving & debugging',
          'Version control (Git)',
          'Cloud platforms & DevOps',
          'Communication & teamwork',
        ],
      ),
      _SectionData(
        title: 'Try Before You Commit',
        description: 'Low-risk ways to test if this is right for you.',
        icon: Icons.rocket_launch_outlined,
        color: const Color(0xFF8B5CF6),
        items: [
          'Complete online tutorials (40 hours)',
          'Build a simple portfolio project',
          'Join a weekend hackathon',
          'Shadow a professional for a day',
        ],
      ),
      _SectionData(
        title: 'Backup Careers',
        description: 'Alternative paths with similar skills.',
        icon: Icons.list_alt_outlined,
        color: AppColors.textSecondary,
        items: [
          'DevOps Engineer',
          'Product Manager',
          'UI/UX Designer',
          'Data Analyst',
          'Technical Writer',
        ],
      ),
      _SectionData(
        title: 'Education & Cost',
        description: 'Investment required for learning.',
        icon: Icons.list_alt_outlined,
        color: AppColors.textSecondary,
        items: [
          'Formal degree: ₹5-25 lakhs (4 years)',
          'Bootcamps: ₹50k-3 lakhs (3-9 months)',
          'Self-learning: ₹20-50k (12-18 months)',
          'Free resources available online',
        ],
      ),
      _SectionData(
        title: 'Start Now - First Steps',
        description: 'What you can do this week.',
        icon: Icons.rocket_launch_outlined,
        color: const Color(0xFF8B5CF6),
        items: [
          'Set up development environment',
          'Start online course (freeCodeCamp)',
          'Join r/learnprogramming',
          'Follow developers on social media',
        ],
      ),
      _SectionData(
        title: 'Mentorship & Resources',
        description: 'Where to find guidance.',
        icon: Icons.list_alt_outlined,
        color: AppColors.textSecondary,
        items: [
          'freeCodeCamp - Free courses',
          'GitHub - Open source projects',
          'Dev.to - Articles & community',
          'Local meetups - Networking',
        ],
      ),
      _SectionData(
        title: '10-Year Career Path',
        description: 'Typical career evolution.',
        icon: Icons.timeline_outlined,
        color: const Color(0xFF10B981),
        items: [
          'Years 0-2: Junior - Learn & deliver features',
          'Years 3-5: Mid-Level - Own projects',
          'Years 6-10: Senior - Lead & mentor',
          'Years 10+: Choose management or technical track',
        ],
      ),
      _SectionData(
        title: 'Industry Trends',
        description: 'How the field is evolving.',
        icon: Icons.bar_chart_outlined,
        color: const Color(0xFFF59E0B),
        items: [
          'AI/ML integration everywhere',
          'Cloud & serverless computing',
          'Remote work now standard',
          '20% job growth by 2030',
        ],
      ),
      _SectionData(
        title: 'Your Blueprint Summary',
        description: 'Key decisions for your success.',
        icon: Icons.lightbulb_outline,
        color: const Color(0xFF3B82F6),
        items: [
          'Start with free resources first',
          'Build projects from day one',
          'Join communities early',
          'Focus on fundamentals over frameworks',
          'Aim for first job in 12-18 months',
        ],
      ),
    ];
  }
}

class _CareerData {
  final String name;
  final String category;
  final double fitScore;
  final String difficulty;
  final String confidence;

  _CareerData({
    required this.name,
    required this.category,
    required this.fitScore,
    required this.difficulty,
    required this.confidence,
  });
}

class _SectionData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> items;

  _SectionData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.items,
  });
}
