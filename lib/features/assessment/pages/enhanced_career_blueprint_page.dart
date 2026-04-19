import 'package:flutter/material.dart';
import 'package:karriova_app/core/constants/app_colors.dart';
import 'package:karriova_app/core/theme/app_typography.dart';

/// Enhanced Career Blueprint with modern visuals
/// Mix of grids, full-width cards, charts, timelines
class EnhancedCareerBlueprintPage extends StatefulWidget {
  final bool embedded;

  const EnhancedCareerBlueprintPage({super.key, this.embedded = false});

  @override
  State<EnhancedCareerBlueprintPage> createState() => _EnhancedCareerBlueprintPageState();
}

class _EnhancedCareerBlueprintPageState extends State<EnhancedCareerBlueprintPage> {
  int _selectedCareerIndex = 0;
  bool _showDetail = false;

  double _horizontalGutter(BuildContext context) => MediaQuery.of(context).size.width * 0.10;

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
    return _showDetail ? _buildEnhancedDetailView() : _buildCarouselView();
  }

  // Top options view (non-swipable)
  Widget _buildCarouselView() {
    final content = SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text('Explore Your Paths', style: AppTypography.heading2),
                  const SizedBox(height: 12),
                  Text(
                    'Review your top 3 career matches below.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth > 980 ? 3 : 1;
                  final totalSpacing = (columns - 1) * 16;
                  final cardWidth = (constraints.maxWidth - totalSpacing) / columns;

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: _careers
                        .map((career) => SizedBox(width: cardWidth, child: _buildCareerCard(career)))
                        .toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Career Options'),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: content,
    );
  }

  Widget _buildCareerCard(_CareerData career) {
    return GestureDetector(
      onTap: () => setState(() {
        _selectedCareerIndex = _careers.indexOf(career);
        _showDetail = true;
      }),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(career.name, style: AppTypography.heading3),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                career.category,
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => setState(() {
                    _selectedCareerIndex = _careers.indexOf(career);
                    _showDetail = true;
                  }),
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

  // ENHANCED DETAIL VIEW with mixed layouts
  Widget _buildEnhancedDetailView() {
    final career = _careers[_selectedCareerIndex];

    final detailBody = CustomScrollView(
        slivers: [
          // Gradient App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _showDetail = false),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                career.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.gradientStart.withOpacity(0.9),
                      AppColors.gradientEnd.withOpacity(0.9),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 16, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                '${career.fitScore.toStringAsFixed(1)} Match',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // 4-COLUMN STATS GRID (Always Visible)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _horizontalGutter(context)),
                  child: _buildStatsGrid(),
                ),

                const SizedBox(height: 24),

                // SECTION 1: Why This Fits (FULL-WIDTH GRADIENT CARD)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _horizontalGutter(context)),
                  child: _buildGradientHeroCard(
                    title: 'Why This Career Fits You',
                    items: [
                      'Strong analytical thinking (scored 92%)',
                      'Creative problem-solving approach',
                      'Interest in technology and innovation',
                      'Team-oriented mindset',
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // SECTION 2: Your Journey (FULL-WIDTH WITH TIMELINE)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _horizontalGutter(context)),
                  child: _buildTimelineCard(
                    title: 'Your Unique Journey',
                    milestones: [
                      'Leverage your existing analytical skills',
                      'Build on your tech interest',
                      'Start with fundamentals',
                      'Join communities early',
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // SECTION 3: Reality Check (FULL-WIDTH WARNING CARD, 2-COL GRID INSIDE)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _horizontalGutter(context)),
                  child: _buildRealityCheckCard(),
                ),

                const SizedBox(height: 16),

                // SECTION 4: Skills Profile (3-COLUMN GRID WITH PROGRESS BARS)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _horizontalGutter(context)),
                  child: _buildSkillsSection(),
                ),

                const SizedBox(height: 16),

                // SECTION 5: Salary Growth (2-COLUMN: DATA + CHART)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _horizontalGutter(context)),
                  child: _buildSalarySection(),
                ),

                const SizedBox(height: 16),

                // SECTION 6: Detailed Roadmap
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _horizontalGutter(context)),
                  child: _buildDetailedRoadmapCard(),
                ),

                const SizedBox(height: 16),

                // SECTION 7: Try Before Commit
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _horizontalGutter(context)),
                  child: _buildTryBeforeCommitCard(),
                ),

                const SizedBox(height: 16),

                // SECTION 8: Education & Cost
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _horizontalGutter(context)),
                  child: _buildEducationCostGrid(),
                ),

                const SizedBox(height: 16),

                // SECTION 9: Backup Careers
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _horizontalGutter(context)),
                  child: _buildBackupCareersGrid(),
                ),

                const SizedBox(height: 16),

                // SECTION 10: Resources & Mentorship
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _horizontalGutter(context)),
                  child: _buildResourcesGrid(),
                ),

                const SizedBox(height: 16),

                // SECTION 11: 10-Year Career Path
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _horizontalGutter(context)),
                  child: _buildCareerPathCard(),
                ),

                const SizedBox(height: 16),

                // SECTION 12: Industry Trends
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _horizontalGutter(context)),
                  child: _buildIndustryTrendsGrid(),
                ),

                const SizedBox(height: 16),

                // SECTION 14: Summary (FULL-WIDTH GRADIENT CARD)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _horizontalGutter(context)),
                  child: _buildSummaryCard(),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      );

    if (widget.embedded) {
      return detailBody;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: detailBody,
    );
  }

  // 4-COLUMN STATS GRID
  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Career Snapshot', style: AppTypography.heading3.copyWith(fontSize: 20)),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _buildStatCard(
                    icon: Icons.straighten_outlined,
                    label: 'Difficulty',
                    value: 'Low',
                    color: AppColors.success,
                    bullets: ['Great for beginners', 'Clear learning path', 'Lots of free resources'],
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildStatCard(
                    icon: Icons.trending_up,
                    label: 'Salary Range',
                    value: '₹4-60L',
                    color: AppColors.info,
                    bullets: ['Entry: ₹4-8L', 'Mid: ₹12-25L', 'Senior: ₹35-60L'],
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildStatCard(
                    icon: Icons.schedule_outlined,
                    label: 'Time to Master',
                    value: '2-3 Years',
                    color: AppColors.warning,
                    bullets: ['6 months basics', '1 year job-ready', '3 years expert'],
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildStatCard(
                    icon: Icons.whatshot_outlined,
                    label: 'Market Demand',
                    value: 'Very High',
                    color: AppColors.error,
                    bullets: ['10,000+ openings', 'Growing 15% yearly', 'Remote-friendly'],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required List<String> bullets,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      value,
                      style: AppTypography.heading3.copyWith(fontSize: 28, color: color),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...bullets.map((bullet) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(fontSize: 12, color: color)),
                Expanded(
                  child: Text(
                    bullet,
                    style: AppTypography.caption.copyWith(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // GRADIENT HERO CARD (Full-width)
  Widget _buildGradientHeroCard({required String title, required List<String> items}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gradientStart.withOpacity(0.15),
            AppColors.gradientEnd.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.heading3.copyWith(fontSize: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              final itemWidth = isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 10,
                children: items
                    .map(
                      (item) => SizedBox(
                        width: itemWidth,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item,
                                  style: AppTypography.body.copyWith(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // TIMELINE CARD (Full-width)
  Widget _buildTimelineCard({required String title, required List<String> milestones}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(title, style: AppTypography.heading3.copyWith(fontSize: 24)),
          const SizedBox(height: 16),
          ...milestones.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (entry.key < milestones.length - 1)
                        Container(
                          width: 2,
                          height: 30,
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        entry.value,
                        style: AppTypography.body.copyWith(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // REALITY CHECK CARD (Full-width warning)
  Widget _buildRealityCheckCard() {
    final challenges = [
      _ChallengeData(
        title: 'Steep learning curve',
        bullets: ['6-12 months initial ramp-up', 'New frameworks every year'],
      ),
      _ChallengeData(
        title: 'Constant tech updates',
        bullets: ['Learn new tools regularly', 'Keep up with trends'],
      ),
      _ChallengeData(
        title: 'Can be mentally exhausting',
        bullets: ['Long debugging sessions', 'Tight deadlines'],
      ),
      _ChallengeData(
        title: 'High entry-level competition',
        bullets: ['Many bootcamp grads', 'Need to stand out'],
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24),
              const SizedBox(width: 12),
              Text(
                'Reality Check',
                style: AppTypography.heading3.copyWith(fontSize: 18, color: AppColors.warning),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: challenges
                    .map((c) => SizedBox(width: cardWidth, child: _buildChallengeItem(c)))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeItem(_ChallengeData challenge) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            challenge.title,
            style: AppTypography.caption.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          ...challenge.bullets.map((bullet) => Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: AppTypography.caption.copyWith(fontSize: 10)),
                Expanded(
                  child: Text(
                    bullet,
                    style: AppTypography.caption.copyWith(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // SKILLS SECTION (3-column grid with progress bars)
  Widget _buildSkillsSection() {
    final skills = [
      _SkillData('JavaScript', 0.85),
      _SkillData('React', 0.75),
      _SkillData('Node.js', 0.70),
      _SkillData('Databases', 0.65),
      _SkillData('Git', 0.80),
      _SkillData('DevOps', 0.60),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text('Skills to Develop', style: AppTypography.heading3.copyWith(fontSize: 18)),
          const SizedBox(height: 16),
          ...skills.map((skill) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(skill.name, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                      Text(
                        '${(skill.progress * 100).toInt()}%',
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: skill.progress,
                      minHeight: 8,
                      backgroundColor: AppColors.lightGray,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // SALARY SECTION (2-column: data + simple bar chart)
  Widget _buildSalarySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text('Salary & Growth', style: AppTypography.heading3.copyWith(fontSize: 18)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSalaryRow('Entry', '₹4-8 LPA'),
                    _buildSalaryRow('Mid', '₹8-15 LPA'),
                    _buildSalaryRow('Senior', '₹15-30 LPA'),
                    _buildSalaryRow('Lead', '₹30-60 LPA'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 120,
                  child: CustomPaint(
                    painter: _SimpleBarChartPainter(),
                    size: const Size(double.infinity, 120),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryRow(String level, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(level, style: AppTypography.caption),
          Text(
            amount,
            style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }


  // SECTION 6: Detailed Roadmap - Non-expandable
  Widget _buildDetailedRoadmapCard() {
    final steps = [
      _RoadmapStepData(
        title: 'Step 1: Foundation (Month 1-2)',
        subtitle: 'HTML, CSS, JavaScript basics + 2 mini projects',
      ),
      _RoadmapStepData(
        title: 'Step 2: Frontend Core (Month 3-4)',
        subtitle: 'React fundamentals, state, routing, API integration',
      ),
      _RoadmapStepData(
        title: 'Step 3: Backend Basics (Month 5-6)',
        subtitle: 'Node.js, REST APIs, auth, database modeling',
      ),
      _RoadmapStepData(
        title: 'Step 4: Full-Stack Projects (Month 7-9)',
        subtitle: 'Build 2 end-to-end portfolio apps + deploy',
      ),
      _RoadmapStepData(
        title: 'Step 5: Job Readiness (Month 10-12)',
        subtitle: 'Interview prep, resume polish, targeted applications',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detailed Roadmap', style: AppTypography.heading3.copyWith(fontSize: 18)),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            final idx = entry.key;
            final step = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: Center(
                          child: Text('${idx + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                        ),
                      ),
                      if (idx < steps.length - 1)
                        Container(width: 3, height: 56, margin: const EdgeInsets.symmetric(vertical: 4), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.25), borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(step.title, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(step.subtitle, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // SECTION 7: Try Before Commit
  Widget _buildTryBeforeCommitCard() {
    final actions = [
      ('Take Free Courses', 'Explore Udemy, Coursera, YouTube'),
      ('Build a Portfolio Project', 'Create something small to test'),
      ('Join Communities', 'Dev forums, meetups, Discord groups'),
      ('Informational Interviews', 'Talk to 2-3 people in the field'),
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Try Before Commit', style: AppTypography.heading3.copyWith(fontSize: 18)),
          const SizedBox(height: 16),
          ...actions.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), shape: BoxShape.circle), child: const Center(child: Icon(Icons.check_circle, size: 18, color: AppColors.primary))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.value.$1, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(e.value.$2, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // SECTION 8: Education & Cost Grid
  Widget _buildEducationCostGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Education & Cost', style: AppTypography.heading3.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 760 ? 2 : 1;
              final totalSpacing = (columns - 1) * 12;
              final cardWidth = (constraints.maxWidth - totalSpacing) / columns;

              final cards = [
                _buildEducationCard('Free', '₹0', 'Khan Academy, YouTube, Docs', AppColors.success),
                _buildEducationCard('Bootcamp', '₹2-5L', '3-6 months, job guarantee', AppColors.warning),
                _buildEducationCard('Degree', '₹5-15L', '4 years, broad knowledge', AppColors.info),
                _buildEducationCard('Self-Paced', '₹5-10K', 'Flexible, mix & match', AppColors.error),
              ];

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: cards.map((card) => SizedBox(width: cardWidth, child: card)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEducationCard(String title, String cost, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
              const SizedBox(height: 3),
              Text(cost, style: AppTypography.heading3.copyWith(fontSize: 18, color: color, fontWeight: FontWeight.w700)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              ...desc.split(', ').map((bullet) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, size: 12, color: color),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        bullet,
                        style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  // SECTION 9: Backup Careers Grid
  Widget _buildBackupCareersGrid() {
    final careers = [
      ('DevOps Engineer', 'Infra & automation', AppColors.info),
      ('Solutions Architect', 'Design & strategy', AppColors.warning),
      ('Technical Writer', 'Docs & communication', AppColors.success),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Backup Careers', style: AppTypography.heading3.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 760 ? 2 : 1;
              final totalSpacing = (columns - 1) * 12;
              final cardWidth = (constraints.maxWidth - totalSpacing) / columns;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: careers
                    .map((c) => SizedBox(width: cardWidth, child: _buildBackupCareerCard(c.$1, c.$2, c.$3)))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBackupCareerCard(String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: const Center(child: Icon(Icons.trending_up, color: Colors.white, size: 16)),
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
              const SizedBox(height: 3),
              Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  // SECTION 10: Resources & Mentorship Grid
  Widget _buildResourcesGrid() {
    final resources = [
      ('Platforms', 'Udemy, Coursera, Codecademy', Icons.school),
      ('Communities', 'Dev.to, Reddit, Discord', Icons.people),
      ('Mentorship', 'Adplist, Merit, Codementor', Icons.person),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resources & Mentorship', style: AppTypography.heading3.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 1000
                  ? 3
                  : constraints.maxWidth > 680
                      ? 2
                      : 1;
              final totalSpacing = (columns - 1) * 12;
              final cardWidth = (constraints.maxWidth - totalSpacing) / columns;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: resources
                    .map((r) => SizedBox(width: cardWidth, child: _buildResourceCard(r.$1, r.$2, r.$3)))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightBlue.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: AppColors.primary),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
              const SizedBox(height: 3),
              Text(desc, style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  // SECTION 11: 10-Year Career Path
  Widget _buildCareerPathCard() {
    final years = ['Year 1-2', 'Year 3-5', 'Year 6-10'];
    final levels = ['Junior Dev', 'Mid-Level', 'Senior/Lead'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('10-Year Career Path', style: AppTypography.heading3.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 1000
                  ? 3
                  : constraints.maxWidth > 680
                      ? 2
                      : 1;
              final totalSpacing = (columns - 1) * 12;
              final cardWidth = (constraints.maxWidth - totalSpacing) / columns;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(
                  3,
                  (i) => SizedBox(
                    width: cardWidth,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1 + (i * 0.03)),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.35 + (i * 0.15)),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                years[i],
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                levels[i],
                                style: AppTypography.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
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
          ),
        ],
      ),
    );
  }

  // SECTION 12: Industry Trends Grid
  Widget _buildIndustryTrendsGrid() {
    final trends = [
      ('AI Integration', '↑ 45%', AppColors.error),
      ('Remote Work', '↑ 60%', AppColors.warning),
      ('Cloud Skills', '↑ 38%', AppColors.info),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Industry Trends', style: AppTypography.heading3.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 1000
                  ? 3
                  : constraints.maxWidth > 680
                      ? 2
                      : 1;
              final totalSpacing = (columns - 1) * 12;
              final cardWidth = (constraints.maxWidth - totalSpacing) / columns;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: trends
                    .map((t) => SizedBox(width: cardWidth, child: _buildTrendCard(t.$1, t.$2, t.$3)))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(String title, String growth, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            growth.startsWith('↑') ? Icons.trending_up : Icons.trending_down,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(growth, style: AppTypography.heading3.copyWith(fontSize: 16, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }


  // SUMMARY CARD (Full-width gradient)
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gradientStart,
            AppColors.gradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Blueprint Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            5,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      [
                        'Start with free resources to validate interest',
                        'Build projects from day one',
                        'Join communities early',
                        'Focus on fundamentals before frameworks',
                        'Aim for first job in 12-18 months',
                      ][i],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Simple bar chart painter
class _SimpleBarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final barWidth = size.width / 5;
    final values = [0.2, 0.4, 0.7, 1.0]; // Relative heights

    for (int i = 0; i < values.length; i++) {
      paint.color = AppColors.primary.withOpacity(0.3 + (values[i] * 0.7));
      final barHeight = size.height * values[i];
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          i * (barWidth + 4),
          size.height - barHeight,
          barWidth,
          barHeight,
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Data classes
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

class _SkillData {
  final String name;
  final double progress;

  _SkillData(this.name, this.progress);
}

class _ChallengeData {
  final String title;
  final List<String> bullets;

  _ChallengeData({
    required this.title,
    required this.bullets,
  });
}

class _RoadmapStepData {
  final String title;
  final String subtitle;

  _RoadmapStepData({
    required this.title,
    required this.subtitle,
  });
}
