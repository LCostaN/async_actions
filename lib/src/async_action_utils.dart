import 'package:flutter/material.dart';

import 'async_action_base.dart';
import 'result.dart';

extension ResultFutureExtensions<T> on Future<Result<T>> {
  /// Returns the successful value or null on error.
  ///
  /// Optional callbacks for loading, finish, error and success (for side effects only).
  Future<T?> handleOrNull({
    void Function()? onLoading,
    void Function(T value)? onSuccess,
    void Function(Exception error)? onError,
    void Function()? onFinish,
  }) async {
    try {
      onLoading?.call();

      final result = await this;

      switch (result) {
        case Ok(:final value):
          onSuccess?.call(value);
          return value;

        case Error(:final error):
          onError?.call(error);
          return null;
      }
    } on Exception catch (e) {
      onError?.call(e);
      return null;
    } catch (e) {
      onError?.call(Exception('Unexpected error: $e'));
      return null;
    } finally {
      onFinish?.call();
    }
  }

  /// Returns the successful value or throws on error.
  ///
  /// Optional callbacks for loading, finish, and success (for side effects only).
  Future<T> handleOrThrow({
    void Function()? onLoading,
    void Function(T value)? onSuccess,
    void Function()? onFinish,
  }) async {
    try {
      onLoading?.call();

      final result = await this;

      switch (result) {
        case Ok(:final value):
          onSuccess?.call(value);
          return value;
        case Error(:final error):
          throw error;
      }
    } on Exception {
      rethrow;
    } catch (e) {
      final wrapped = Exception('Unexpected error: $e');
      throw wrapped;
    } finally {
      onFinish?.call();
    }
  }
}

extension AsyncActionWidgetBuilder<T> on AsyncAction<T> {
  Widget buildWidget({
    required Widget Function(BuildContext context, T value, Widget? child) builder,
    Widget Function(BuildContext context, Exception error)? errorBuilder,
    Widget Function(BuildContext context)? loadingBuilder,
    Widget? child,
  }) => ListenableBuilder(
    listenable: this,
    builder: (context, child) {
      if (running) {
        return loadingBuilder?.call(context) ?? _defaultLoading();
      }

      if (result == null) {
        return _defaultError(context, Exception('Action completed with null result'));
      }

      switch (result!) {
        case Ok(:final value):
          return builder(context, value, child);
        case Error(:final error):
          return errorBuilder?.call(context, error) ?? _defaultError(context, error);
      }
    },
    child: child,
  );

  static Widget _defaultLoading() => const Center(child: CircularProgressIndicator.adaptive());

  static Widget _defaultError(BuildContext context, Exception error) =>
      Center(child: Text('Error: ${error.toString()}'));
}
