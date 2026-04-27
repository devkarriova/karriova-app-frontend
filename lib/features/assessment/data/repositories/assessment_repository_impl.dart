import 'package:dartz/dartz.dart';
import '../../domain/models/assessment_models.dart';
import '../datasources/assessment_remote_datasource.dart';

/// Assessment repository interface
abstract class AssessmentRepository {
  /// Get the active assessment
  Future<Either<String, AssessmentModel>> getActiveAssessment();

  /// Submit assessment responses
  Future<Either<String, AssessmentResultModel>> submitAssessment(
      List<ResponseInput> responses);

  /// Get current user's assessment results
  Future<Either<String, AssessmentResultModel>> getMyResults();

  /// Download KIT report PDF (short or detailed)
  Future<Either<String, QuestionTemplateModel>> downloadKitReportPdf({
    String type = 'short',
    String? blueprintId,
  });

  /// Check if user has completed the assessment
  Future<Either<String, bool>> hasCompletedAssessment();

  /// Get assessment completion status (alias for hasCompletedAssessment)
  Future<Either<String, bool>> getAssessmentStatus();
}

/// Assessment repository implementation with error handling
class AssessmentRepositoryImpl implements AssessmentRepository {
  final AssessmentRemoteDataSource remoteDataSource;

  AssessmentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, AssessmentModel>> getActiveAssessment() async {
    try {
      final assessment = await remoteDataSource.getActiveAssessment();
      return Right(assessment);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, AssessmentResultModel>> submitAssessment(
      List<ResponseInput> responses) async {
    try {
      final result = await remoteDataSource.submitAssessment(responses);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, AssessmentResultModel>> getMyResults() async {
    try {
      final result = await remoteDataSource.getMyResults();
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, QuestionTemplateModel>> downloadKitReportPdf({
    String type = 'short',
    String? blueprintId,
  }) async {
    try {
      final result = await remoteDataSource.downloadKitReportPdf(
        type: type,
        blueprintId: blueprintId,
      );
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, bool>> hasCompletedAssessment() async {
    try {
      final completed = await remoteDataSource.hasCompletedAssessment();
      return Right(completed);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, bool>> getAssessmentStatus() async {
    return hasCompletedAssessment();
  }

  String _handleError(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }
}
