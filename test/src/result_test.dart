import 'package:async_action/async_action.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Ok should wrap a value', () {
      const value = 'success';
      const result = Result<String>.ok(value);

      expect(result, isA<Ok<String>>());
      expect((result as Ok<String>).value, value);
      expect(result.toString(), contains('success'));
    });

    test('Error should wrap an exception', () {
      final exception = Exception('fail');
      final result = Result<String>.error(exception);

      expect(result, isA<Error<String>>());
      expect((result as Error<String>).error, exception);
      expect(result.toString(), contains('fail'));
    });

    test('Ok results should not be comparable via value by default', () {
      expect(Result.ok(1) == Result.ok(1), isFalse);
    });
  });
}
