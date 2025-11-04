part of dsalink.common;

/// A type representing the result of an operation that can succeed or fail.
///
/// Inspired by Rust's Result<T, E> and Kotlin's Result<T>.
/// Use this instead of throwing exceptions for expected error cases.
///
/// Example:
/// ```dart
/// Result<String, DSAError> loadConfig() {
///   try {
///     final config = readConfigFile();
///     return Success(config);
///   } on FileSystemException catch (e) {
///     return Failure(DSAError('Failed to read config: ${e.message}'));
///   }
/// }
///
/// final result = loadConfig();
/// final message = result.when(
///   success: (config) => 'Loaded: $config',
///   failure: (error) => 'Error: ${error.message}',
/// );
/// ```
sealed class Result<T, E> {
  const Result();

  /// Pattern match on the result
  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  });

  /// Map the success value
  Result<U, E> map<U>(U Function(T) fn) => switch (this) {
        Success(:final value) => Success(fn(value)),
        Failure(:final error) => Failure(error),
      };

  /// Map the error value
  Result<T, F> mapError<F>(F Function(E) fn) => switch (this) {
        Success(:final value) => Success(value),
        Failure(:final error) => Failure(fn(error)),
      };

  /// Flat map for chaining operations
  Result<U, E> flatMap<U>(Result<U, E> Function(T) fn) => switch (this) {
        Success(:final value) => fn(value),
        Failure(:final error) => Failure(error),
      };

  /// Get the value if Success, otherwise return default
  T getOrElse(T Function() defaultValue) => switch (this) {
        Success(:final value) => value,
        Failure() => defaultValue(),
      };

  /// Get the value if Success, otherwise throw the error
  /// Note: Error must be an Object to be throwable
  T getOrThrow() => switch (this) {
        Success(:final value) => value,
        Failure(:final error) => throw Exception(error.toString()),
      };

  /// Check if this is a Success
  bool get isSuccess => this is Success<T, E>;

  /// Check if this is a Failure
  bool get isFailure => this is Failure<T, E>;

  /// Get value if Success, null otherwise
  T? get valueOrNull => switch (this) {
        Success(:final value) => value,
        Failure() => null,
      };

  /// Get error if Failure, null otherwise
  E? get errorOrNull => switch (this) {
        Success() => null,
        Failure(:final error) => error,
      };
}

/// Represents a successful result
final class Success<T, E> extends Result<T, E> {
  final T value;
  const Success(this.value);

  @override
  R when<R>({
    required R Function(T) success,
    required R Function(E) failure,
  }) =>
      success(value);

  @override
  String toString() => 'Success($value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T, E> &&
      runtimeType == other.runtimeType &&
      value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// Represents a failed result
final class Failure<T, E> extends Result<T, E> {
  final E error;
  const Failure(this.error);

  @override
  R when<R>({
    required R Function(T) success,
    required R Function(E) failure,
  }) =>
      failure(error);

  @override
  String toString() => 'Failure($error)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T, E> &&
      runtimeType == other.runtimeType &&
      error == other.error;

  @override
  int get hashCode => error.hashCode;
}

/// DSA-specific error type for use with Result
class DSAError {
  final String message;
  final String? code;
  final Object? cause;
  final StackTrace? stackTrace;

  const DSAError(
    this.message, {
    this.code,
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('DSAError: $message');
    if (code != null) buffer.write(' [code: $code]');
    if (cause != null) buffer.write('\nCause: $cause');
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DSAError &&
      runtimeType == other.runtimeType &&
      message == other.message &&
      code == other.code;

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

/// Extension to convert Future<T> to Future<Result<T, E>>
extension FutureToResult<T> on Future<T> {
  /// Catch exceptions and convert to Result
  ///
  /// Example:
  /// ```dart
  /// final result = await someAsyncOperation().toResult(
  ///   (error) => DSAError('Operation failed: $error'),
  /// );
  /// ```
  Future<Result<T, E>> toResult<E>(E Function(Object error) onError) async {
    try {
      final value = await this;
      return Success(value);
    } catch (e) {
      return Failure(onError(e));
    }
  }

  /// Catch exceptions and convert to Result<T, DSAError>
  Future<Result<T, DSAError>> toDSAResult([String? message]) async {
    try {
      final value = await this;
      return Success(value);
    } catch (e, st) {
      return Failure(DSAError(
        message ?? 'Operation failed: $e',
        cause: e,
        stackTrace: st,
      ));
    }
  }
}
