import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/error/result.dart';
import 'task_model.dart';

/// Talks to the mock API and converts transport errors into [AppFailure].
class TaskRemoteDataSource {
  TaskRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Result<List<TaskModel>>> fetchTodos() async {
    try {
      final response = await _dio.get<List<dynamic>>(AppConstants.todosUrl);
      final rows = response.data ?? const [];
      final models = [
        for (final row in rows)
          if (row is Map<String, dynamic>) TaskModel.fromJson(row),
      ];
      return Success(models);
    } on DioException catch (error) {
      return Failure(_failureFor(error));
    } on FormatException {
      return Failure(const ParsingFailure());
    } catch (_) {
      return Failure(const ParsingFailure());
    }
  }

  AppFailure _failureFor(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const TimeoutFailure(),
      DioExceptionType.connectionError => const NetworkFailure(),
      _ => const UnknownFailure(),
    };
  }
}
