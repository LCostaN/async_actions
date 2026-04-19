import 'dart:async';

import 'package:flutter/foundation.dart';

import 'result.dart';

typedef AsyncActionCallback0<T> = Future<Result<T>> Function();
typedef AsyncActionCallback1<T, A> = Future<Result<T>> Function(A);

/// Facilitates interaction between a ViewModel/Store and the UI.
///
/// Encapsulates an asynchronous action, exposes its running and error states,
/// and ensures that it can't be launched again until it finishes.
///
/// **Guidelines:**
/// - **UI Reactivity**: main goal is to make actions reactive to UI changes.
///   Not intended for background processes or repositories.
/// - **Scoped State**: Use [ListenableBuilder] for scoped state changes.
///
/// Use [AsyncAction0] for actions without arguments.
/// Use [AsyncAction1] for actions with one argument.
///
/// Actions must return a [Result].
///
/// Consume the action result by listening to changes,
/// then call to [clearResult] when the state is consumed.
abstract class AsyncAction<T> extends ChangeNotifier {
  AsyncAction();

  bool _running = false;

  /// True when the action is running.
  bool get running => _running;

  Result<T>? _result;

  /// true if action completed with error
  bool get error => _result is Error;

  /// true if action completed successfully
  bool get completed => _result is Ok;

  /// Get last action result
  Result<T>? get result => _result;

  /// Clear last action result
  void clearResult() {
    _result = null;
    notifyListeners();
  }

  /// Internal execute implementation
  Future<void> _execute(AsyncActionCallback0<T> action) async {
    // Ensure the action can't launch multiple times.
    if (_running) return;

    // Notify listeners.
    _running = true;
    _result = null;
    notifyListeners();

    try {
      _result = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

/// [AsyncAction] without arguments.
/// Takes a [AsyncActionCallback0] as action.
class AsyncAction0<T> extends AsyncAction<T> {
  AsyncAction0(this._action);

  final AsyncActionCallback0<T> _action;

  /// Executes the action.
  Future<void> execute() async {
    await _execute(_action);
  }
}

/// [AsyncAction] with one argument.
/// Takes a [AsyncActionCallback1] as action.
///
/// **Best Practice:** Create a `typedef` for the argument type [A]
/// instead of using anonymous tuples or multiple positional arguments.
///
/// ```dart
/// typedef MyParams = ({String id, String name});
/// final action = AsyncAction1<void, MyParams>(_myFunc);
/// ```
class AsyncAction1<T, A> extends AsyncAction<T> {
  AsyncAction1(this._action);

  final AsyncActionCallback1<T, A> _action;

  /// Executes the action with the argument.
  Future<void> execute(A argument) async {
    await _execute(() => _action(argument));
  }
}
