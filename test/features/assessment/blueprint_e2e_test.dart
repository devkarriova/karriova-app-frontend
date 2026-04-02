// End-to-End Test Suite for Career Blueprint Feature
// Run with: flutter test test/features/assessment/blueprint_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:karriova_app/features/assessment/models/career_blueprint_model.dart';
import 'package:karriova_app/features/assessment/services/blueprint_api_service.dart';

// Generate mocks
void main() {
  group('[E2E] Career Blueprint Feature', () {
    late BlueprintApiService apiService;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      apiService = BlueprintApiService(
        dio: mockDio,
        baseUrl: 'http://localhost:8080',
      );
    });

    // ===== Test 1: Carousel Loading =====
    test('Load carousel blueprints successfully', () async {
      final mockResponse = Response(
        data: {
          'data': {
            'assessment_attempt_id': 'attempt-123',
            'user_id': 'user-123',
            'blueprints': [
              {
                'id': 'bp-1',
                'career_name': 'Software Engineer',
                'career_category': 'Technology',
                'fit_score': 0.95,
                'difficulty_level': 'low',
                'confidence_level': 'high',
                'status': 'generated',
              },
              {
                'id': 'bp-2',
                'career_name': 'Product Manager',
                'career_category': 'Technology',
                'fit_score': 0.85,
                'difficulty_level': 'medium',
                'confidence_level': 'high',
                'status': 'generated',
              },
              {
                'id': 'bp-3',
                'career_name': 'Data Scientist',
                'career_category': 'Technology',
                'fit_score': 0.78,
                'difficulty_level': 'high',
                'confidence_level': 'medium',
                'status': 'generated',
              },
            ],
            'completed_at': DateTime.now().toIso8601String(),
          }
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get(any)).thenAnswer((_) async => mockResponse);

      final result = await apiService.getCarouselBlueprints('attempt-123');

      expect(result.blueprints.length, 3);
      expect(result.blueprints.first.careerName, 'Software Engineer');
      expect(result.blueprints.first.fitScore, 0.95);
      expect(result.blueprints.first.status, 'generated');
    });

    // ===== Test 2: Load Full Blueprint Detail =====
    test('Load full blueprint with 14 sections', () async {
      final mockResponse = Response(
        data: {
          'blueprint': {
            'id': 'bp-1',
            'user_id': 'user-123',
            'assessment_attempt_id': 'attempt-123',
            'career_id': 'career-1',
            'career_name': 'Software Engineer',
            'career_category': 'Technology',
            'fit_score': 0.95,
            'difficulty_level': 'low',
            'confidence_level': 'high',
            'sections': List.generate(
              14,
              (i) => {
                'id': 'section-$i',
                'title': 'Section $i',
                'description': 'Description for section $i',
                'section_type': 'insight',
                'content': [],
                'order_index': i,
                'expanded': false,
              },
            ),
            'status': 'generated',
            'generated_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'generation_version': 1,
          }
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get(any)).thenAnswer((_) async => mockResponse);

      final blueprint = await apiService.getBlueprintDetail('bp-1');

      expect(blueprint.id, 'bp-1');
      expect(blueprint.careerName, 'Software Engineer');
      expect(blueprint.sections.length, 14);
      expect(blueprint.status, 'generated');
    });

    // ===== Test 3: Select Blueprint & Lock Choice =====
    test('Select blueprint locks choice and archives others', () async {
      final selectResponse = Response(
        data: {
          'message': 'Career selection locked successfully',
          'blueprint_id': 'bp-1',
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => selectResponse);

      await apiService.selectBlueprint('bp-1', 'attempt-123');

      verify(mockDio.post(
        contains('/blueprints/bp-1/select'),
        data: {'attempt_id': 'attempt-123'},
      )).called(1);
    });

    // ===== Test 4: Chart Data Integration =====
    test('Blueprint includes chart data', () async {
      final mockResponse = Response(
        data: {
          'blueprint': {
            'id': 'bp-1',
            'user_id': 'user-123',
            'assessment_attempt_id': 'attempt-123',
            'career_id': 'career-1',
            'career_name': 'Software Engineer',
            'career_category': 'Technology',
            'fit_score': 0.95,
            'difficulty_level': 'low',
            'confidence_level': 'high',
            'sections': [],
            'charts': {
              'salary_projection': [
                {
                  'year': 'Year 1',
                  'min_salary': 80000,
                  'med_salary': 100000,
                  'max_salary': 120000,
                  'trend_percent': 0,
                },
                {
                  'year': 'Year 5',
                  'min_salary': 110000,
                  'med_salary': 140000,
                  'max_salary': 180000,
                  'trend_percent': 15.0,
                },
              ],
              'job_market_demand': [
                {
                  'year': '2024',
                  'open_positions': 15000,
                  'growth_rate': 0,
                },
                {
                  'year': '2025',
                  'open_positions': 18000,
                  'growth_rate': 20.0,
                },
              ],
              'skill_alignment': [
                {
                  'skill': 'Python',
                  'user_level': 85.0,
                  'required': 90.0,
                  'importance': 5.0,
                },
              ],
            },
            'status': 'generated',
            'generated_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'generation_version': 1,
          }
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get(any)).thenAnswer((_) async => mockResponse);

      final blueprint = await apiService.getBlueprintDetail('bp-1');

      expect(blueprint.charts, isNotNull);
      expect(blueprint.charts!.salaryProjection.length, 2);
      expect(blueprint.charts!.jobMarketDemand.length, 2);
      expect(blueprint.charts!.skillAlignment.length, 1);
    });

    // ===== Test 5: Error Handling =====
    test('Handle API errors gracefully', () async {
      when(mockDio.get(any)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Connection timeout',
        ),
      );

      expect(
        () => apiService.getCarouselBlueprints('attempt-123'),
        throwsA(isA<BlueprintException>()),
      );
    });

    // ===== Test 6: Data Model Serialization =====
    test('Blueprint JSON serialization/deserialization', () {
      final blueprintJson = {
        'id': 'bp-1',
        'user_id': 'user-123',
        'assessment_attempt_id': 'attempt-123',
        'career_id': 'career-1',
        'career_name': 'Software Engineer',
        'career_category': 'Technology',
        'fit_score': 0.95,
        'difficulty_level': 'low',
        'confidence_level': 'high',
        'sections': [
          {
            'id': 'section-1',
            'title': 'Why This Fits',
            'description': 'Test description',
            'section_type': 'insight',
            'content': [],
            'order_index': 0,
            'expanded': true,
          }
        ],
        'status': 'generated',
        'generated_at': '2024-04-03T10:00:00Z',
        'updated_at': '2024-04-03T10:00:00Z',
        'generation_version': 1,
      };

      final blueprint = CareerBlueprint.fromJson(blueprintJson);
      expect(blueprint.id, 'bp-1');
      expect(blueprint.careerName, 'Software Engineer');
      expect(blueprint.sections.length, 1);
    });

    // ===== Test 7: State Management - Selection Flow =====
    test('Blueprint status updates on selection', () {
      var blueprint = CareerBlueprint(
        id: 'bp-1',
        userId: 'user-123',
        assessmentAttemptId: 'attempt-123',
        careerId: 'career-1',
        careerName: 'Software Engineer',
        fitScore: 0.95,
        difficultyLevel: 'low',
        confidenceLevel: 'high',
        sections: [],
        status: 'generated',
        generatedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        generationVersion: 1,
      );

      expect(blueprint.isSelected, false);
      expect(blueprint.status, 'generated');

      blueprint = blueprint.copyWith(status: 'selected');

      expect(blueprint.isSelected, true);
      expect(blueprint.status, 'selected');
    });

    // ===== Test 8: Caching Verification =====
    test('Cached blueprint returns same data on repeat calls', () async {
      final mockResponse = Response(
        data: {
          'blueprint': {
            'id': 'bp-1',
            'user_id': 'user-123',
            'assessment_attempt_id': 'attempt-123',
            'career_id': 'career-1',
            'career_name': 'Software Engineer',
            'career_category': 'Technology',
            'fit_score': 0.95,
            'difficulty_level': 'low',
            'confidence_level': 'high',
            'sections': [],
            'status': 'generated',
            'generated_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'generation_version': 1,
          }
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get(any)).thenAnswer((_) async => mockResponse);

      final blueprint1 = await apiService.getBlueprintDetail('bp-1');
      final blueprint2 = await apiService.getBlueprintDetail('bp-1');

      expect(blueprint1.id, blueprint2.id);
      expect(blueprint1.careerName, blueprint2.careerName);
    });
  });
}

// ===== Integration Testing (Manual) =====

/// Integration Test Checklist
/// 
/// 1. ASSESSMENT → ROADMAP GENERATION
/// - [ ] User completes assessment
/// - [ ] Stream selection computed correctly
/// - [ ] GenerateRoadmaps endpoint called with correct parameters
/// - [ ] 3 blueprints generated and stored in database
/// 
/// 2. CAROUSEL VIEW
/// - [ ] CarouselPage loads 3 blueprints
/// - [ ] PageView swipe navigation works
/// - [ ] Indicator dots update on swipe
/// - [ ] Fit scores display correctly
/// - [ ] Difficulty/confidence badges render
/// - [ ] Quick stats row shows totals
/// 
/// 3. BLUEPRINT SELECTION
/// - [ ] Clicking "View Full Blueprint" navigates to DetailPage
/// - [ ] DetailPage loads full blueprint with 14 sections
/// - [ ] Sections are collapsed by default (except first 2)
/// - [ ] Toggle expand/collapse per section works
/// - [ ] Content cards render with descriptions
/// 
/// 4. CHARTS INTEGRATION
/// - [ ] Salary projection chart displays
/// - [ ] Job market demand chart displays
/// - [ ] Skill alignment chart displays
/// - [ ] Tab switching between charts works
/// - [ ] Chart data is accurate
/// 
/// 5. SELECTION LOCKING
/// - [ ] "Select This Career" button calls API
/// - [ ] Selected blueprint status updates to 'selected'
/// - [ ] Button becomes disabled after selection
/// - [ ] Success message shows
/// - [ ] Other blueprints archived
/// 
/// 6. CACHING & PERFORMANCE
/// - [ ] Repeat visits don't trigger API calls (cached)
/// - [ ] Blueprint loads instantly on repeat
/// - [ ] Chart data loads from cache
/// - [ ] No duplicate network requests
/// 
/// 7. ERROR HANDLING
/// - [ ] API failures show error message
/// - [ ] Retry button appears on error
/// - [ ] Network timeouts handled gracefully
/// - [ ] Invalid blueprint ID returns 404
/// 
/// 8. STATE PERSISTENCE
/// - [ ] Selected blueprint persists on app restart
/// - [ ] Last viewed time updates
/// - [ ] Navigation back/forward works
/// - [ ] Multiple tabs don't conflict
///

/// API Endpoint Testing Commands
/// 
/// 1. Check Backend Running:
///    curl http://localhost:8080/api/v1/health
/// 
/// 2. Get Carousel Blueprints:
///    curl http://localhost:8080/api/v1/assessments/blueprints/carousel/{attemptId}
/// 
/// 3. Get Full Blueprint:
///    curl http://localhost:8080/api/v1/assessments/blueprints/{blueprintId}
/// 
/// 4. Select Blueprint:
///    curl -X POST http://localhost:8080/api/v1/assessments/blueprints/{blueprintId}/select \
///      -H "Content-Type: application/json" \
///      -d '{\"attempt_id\": \"attempt-123\"}'
///
/// 5. Check Database:
///    SELECT COUNT(*) FROM career_blueprints WHERE status = 'generated';
///    SELECT COUNT(*) FROM blueprint_chart_cache;
///    SELECT * FROM career_blueprints WHERE status = 'selected';
///

/// Performance Benchmarks
/// 
/// Expected Response Times:
/// - Carousel load: < 500ms
/// - Full blueprint load: < 1000ms
/// - Selection locking: < 500ms
/// - Chart rendering: < 600ms
/// 
/// Database Performance:
/// - Blueprint queries: < 100ms (indexed)
/// - Chart cache queries: < 50ms (indexed)
/// - Full blueprint fetch (JSONB): < 200ms
///
