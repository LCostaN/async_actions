import 'package:async_action/async_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AsyncActionUtils', () {
    test('handleOrNull should return value on success', () async {
      final future = Future.value(const Result.ok('success'));
      final result = await future.handleOrNull();
      expect(result, 'success');
    });

    test('handleOrNull should return null on error', () async {
      final future = Future.value(Result<String>.error(Exception('fail')));
      final result = await future.handleOrNull();
      expect(result, isNull);
    });

    test('handleOrThrow should return value on success', () async {
      final future = Future.value(const Result.ok('success'));
      final result = await future.handleOrThrow();
      expect(result, 'success');
    });

    test('handleOrThrow should throw on error', () async {
      final future = Future.value(Result<String>.error(Exception('fail')));
      expect(() => future.handleOrThrow(), throwsA(isA<Exception>()));
    });

    testWidgets('AsyncActionWidgetBuilder.buildWidget should show states', (tester) async {
      final action = AsyncAction0<String>(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        return const Result.ok('content');
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: action.buildWidget(
              builder: (context, value, child) => Text(value),
              loadingBuilder: (context) => const Text('loading'),
              errorBuilder: (context, error) => const Text('error'),
            ),
          ),
        ),
      );

      // Initially, it might show error if result is null and not running
      // But let's trigger it.
      expect(find.text('Error: Exception: Action completed with null result'), findsOneWidget);

      action.execute();
      await tester.pump(); // Start running
      expect(find.text('loading'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100)); // Finish execution
      await tester.pump();
      expect(find.text('content'), findsOneWidget);
    });
  });
}
