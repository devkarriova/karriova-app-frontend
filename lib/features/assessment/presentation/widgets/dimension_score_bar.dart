import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/models/assessment_models.dart';

/// Dimension score bar widget - displays a single dimension result
class DimensionScoreBar extends StatelessWidget {
  final DimensionScoreModel score;

  const DimensionScoreBar({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dimension name
          Text(
            score.dimensionName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSM),
          
          // Pole labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                score.poleALabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: score.score < 50 ? FontWeight.w600 : FontWeight.w400,
                  color: score.score < 50
                      ? AppColors.primary
                      : AppColors.textTertiary,
                ),
              ),
              Text(
                score.poleBLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: score.score >= 50 ? FontWeight.w600 : FontWeight.w400,
                  color: score.score >= 50
                      ? AppColors.secondary
                      : AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingXS),
          
          // Score bar with marker
          SizedBox(
            height: 24,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final markerPosition = constraints.maxWidth * (score.score / 100);
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Background gradient bar
                    Container(
                      height: 8,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.gradientStart, AppColors.gradientEnd],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    // Marker
                    Positioned(
                      left: markerPosition - 12,
                      top: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getMarkerColor(score.score),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSM),
          
          // Descriptive label
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getMarkerColor(score.score).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                score.descriptiveLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _getMarkerColor(score.score),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMarkerColor(double score) {
    if (score < 45) return AppColors.primary;
    if (score > 55) return AppColors.secondary;
    return AppColors.textSecondary;
  }
}
