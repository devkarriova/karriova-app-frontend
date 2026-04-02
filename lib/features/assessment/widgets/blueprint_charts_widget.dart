import 'package:flutter/material.dart';
import 'package:karriova_app/core/theme/app_colors.dart';
import 'package:karriova_app/core/theme/app_typography.dart';
import 'package:karriova_app/features/assessment/models/career_blueprint_model.dart';

/// Charts Display Widget for Blueprint
class BlueprintChartsWidget extends StatefulWidget {
  final ChartData? chartData;
  final String careerName;

  const BlueprintChartsWidget({
    required this.chartData,
    required this.careerName,
    Key? key,
  }) : super(key: key);

  @override
  _BlueprintChartsWidgetState createState() => _BlueprintChartsWidgetState();
}

class _BlueprintChartsWidgetState extends State<BlueprintChartsWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    int tabCount = 0;
    if (widget.chartData?.salaryProjection != null &&
        widget.chartData!.salaryProjection.isNotEmpty) tabCount++;
    if (widget.chartData?.jobMarketDemand != null &&
        widget.chartData!.jobMarketDemand.isNotEmpty) tabCount++;
    if (widget.chartData?.skillAlignment != null &&
        widget.chartData!.skillAlignment.isNotEmpty) tabCount++;

    _tabController = TabController(
      length: tabCount,
      vsync: this,
      initialIndex: 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.chartData == null) {
      return const SizedBox.shrink();
    }

    final hasSalary = widget.chartData!.salaryProjection.isNotEmpty;
    final hasJobMarket = widget.chartData!.jobMarketDemand.isNotEmpty;
    final hasSkills = widget.chartData!.skillAlignment.isNotEmpty;

    if (!hasSalary && !hasJobMarket && !hasSkills) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Career Insights',
                style: AppTypography.heading3,
              ),
              const SizedBox(height: 8),
              Text(
                'Explore market trends and growth potential',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Tab bar
        if (hasSalary || hasJobMarket || hasSkills)
          Container(
            color: AppColors.lightGray,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: [
                if (hasSalary)
                  const Tab(
                    text: 'Salary',
                    icon: Icon(Icons.trending_up, size: 16),
                  ),
                if (hasJobMarket)
                  const Tab(
                    text: 'Job Market',
                    icon: Icon(Icons.business, size: 16),
                  ),
                if (hasSkills)
                  const Tab(
                    text: 'Skills',
                    icon: Icon(Icons.school, size: 16),
                  ),
              ],
            ),
          ),

        // Tab views
        SizedBox(
          height: 300,
          child: TabBarView(
            controller: _tabController,
            children: [
              if (hasSalary)
                _buildSalaryChart(widget.chartData!.salaryProjection),
              if (hasJobMarket)
                _buildJobMarketChart(widget.chartData!.jobMarketDemand),
              if (hasSkills)
                _buildSkillsChart(widget.chartData!.skillAlignment),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSalaryChart(List<SalaryProjectionData> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Salary Growth Projection',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '+${((data.last.medSalary - data.first.medSalary) / data.first.medSalary * 100).toStringAsFixed(0)}% growth',
                  style: AppTypography.caption.copyWith(
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                ...data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final maxSalary = data.fold<int>(
                    0,
                    (max, d) => d.maxSalary > max ? d.maxSalary : max,
                  );

                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            child: Text(
                              item.year,
                              style: AppTypography.caption,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                // Bar chart
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGray,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: (item.minSalary / maxSalary) *
                                            MediaQuery.of(context).size.width *
                                            0.5,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                      Container(
                                        width: (item.medSalary / maxSalary) *
                                            MediaQuery.of(context).size.width *
                                            0.5,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 80,
                            child: Text(
                              '\$${(item.medSalary / 1000).toStringAsFixed(0)}K',
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (index < data.length - 1)
                        const SizedBox(height: 8),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobMarketChart(List<JobMarketPoint> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Job Market Demand',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Growing',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                ...data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final maxPositions = data.fold<int>(
                    0,
                    (max, d) => d.openPositions > max ? d.openPositions : max,
                  );

                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            child: Text(
                              item.year,
                              style: AppTypography.caption,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.lightGray,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Container(
                                width:
                                    (item.openPositions / maxPositions) *
                                        100,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 80,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${item.openPositions}',
                                  style: AppTypography.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (index > 0)
                                  Text(
                                    '+${item.growthRate.toStringAsFixed(1)}%',
                                    style: AppTypography.caption.copyWith(
                                      color: const Color(0xFF10B981),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (index < data.length - 1)
                        const SizedBox(height: 12),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsChart(List<SkillRadarData> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Required Skills',
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                ...data.map((skill) {
                  final gap = skill.required - skill.userLevel;
                  final gapPercent = (gap / skill.required * 100).abs();

                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  skill.skill,
                                  style: AppTypography.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Importance: ${skill.importance.toStringAsFixed(1)}/5',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    // User level
                                    Container(
                                      height: 8,
                                      width: (skill.userLevel / 100) * 80,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    // Required level
                                    Container(
                                      height: 8,
                                      width: (gap.abs() / 100) * 80,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withOpacity(0.3),
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 60,
                            child: Text(
                              gap > 0
                                  ? '${gapPercent.toStringAsFixed(0)}% to go'
                                  : 'Ready',
                              style: AppTypography.caption.copyWith(
                                color: gap > 0
                                    ? AppColors.textSecondary
                                    : const Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
