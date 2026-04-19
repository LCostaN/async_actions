import 'package:async_action/async_action.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AsyncAction', () {
    test('AsyncAction0 should execute and update state', () async {
      final action = AsyncAction0<String>(() async {
        await Future.delayed(const Duration(milliseconds: 50));
        return const Result.ok('done');
      });

      expect(action.running, isFalse);
      expect(action.result, isNull);

      final future = action.execute();

      expect(action.running, isTrue);
      
      await future;

      expect(action.running, isFalse);
      expect(action.completed, isTrue);
      expect((action.result as Ok<String>).value, 'done');
    });

    test('AsyncAction1 should pass argument and update state', () async {
      final action = AsyncAction1<int, int>((val) async {
        return Result.ok(val * 2);
      });

      await action.execute(21);

      expect((action.result as Ok<int>).value, 42);
    });

    test('Should handle error results', () async {
      final exception = Exception('error');
      final action = AsyncAction0<void>(() async {
        return Result.error(exception);
      });

      await action.execute();

      expect(action.error, isTrue);
      expect((action.result as Error).error, exception);
    });

    test('Should prevent concurrent execution', () async {
      int callCount = 0;
      final action = AsyncAction0<void>(() async {
        callCount++;
        await Future.delayed(const Duration(milliseconds: 100));
        return const Result.ok(null);
      });

      final f1 = action.execute();
      final f2 = action.execute(); // Should be ignored

      await Future.wait([f1, f2]);

      expect(callCount, 1);
    });

    test('clearResult should reset state', () async {
      final action = AsyncAction0<String>(() async => const Result.ok('ok'));
      await action.execute();
      expect(action.result, isNotNull);

      action.clearResult();
      expect(action.result, isNull);
    });

    test('Should notify listeners during execution', () async {
      final action = AsyncAction0<void>(() async => const Result.ok(null));
      int notifyCount = 0;
      action.addListener(() => notifyCount++);

      await action.execute();

      // Notified when:
      // 1. Started (running = true)
      // 2. Finished (running = false)
      expect(notifyCount, 2);
    });
  });
}
