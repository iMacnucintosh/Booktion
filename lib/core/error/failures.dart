import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// Base failure class using freezed for union types
@freezed
class Failure with _$Failure {
  const factory Failure.server({
    required String message,
    int? statusCode,
  }) = ServerFailure;

  const factory Failure.network({
    required String message,
  }) = NetworkFailure;

  const factory Failure.notFound({
    required String message,
  }) = NotFoundFailure;

  const factory Failure.unauthorized({
    required String message,
  }) = UnauthorizedFailure;

  const factory Failure.unknown({
    required String message,
  }) = UnknownFailure;
}

extension FailureX on Failure {
  String get displayMessage => when(
        server: (message, _) => message,
        network: (message) => message,
        notFound: (message) => message,
        unauthorized: (message) => message,
        unknown: (message) => message,
      );
}
