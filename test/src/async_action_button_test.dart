import 'package:async_action/async_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AsyncActionButton', () {
    testWidgets('should render and handle tap', (tester) async {
      bool tapped = false;
      final action = AsyncAction0<void>(() async => const Result.ok(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncActionButton.elevated(
              action: action,
              onTap: () => tapped = true,
              child: const Text('Button'),
            ),
          ),
        ),
      );

      expect(find.text('Button'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isTrue);
    });

    testWidgets('should show loading overlay when action is running', (tester) async {
      final action = AsyncAction0<void>(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        return const Result.ok(null);
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncActionButton.filled(
              action: action,
              onTap: action.execute,
              child: const Text('Button'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FilledButton));
      await tester.pump(); // Trigger running state

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // The child button content should be hidden (opacity 0)
      final opacityWidget = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacityWidget.opacity, 0.0);

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      
      expect(find.byType(CircularProgressIndicator), findsNothing);
      final opacityWidgetAfter = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacityWidgetAfter.opacity, 1.0);
    });

    testWidgets('should show error overlay when error occurs and errorBuilder is provided', (tester) async {
      final action = AsyncAction0<void>(() async {
        return Result.error(Exception('fail'));
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncActionButton.outlined(
              action: action,
              onTap: action.execute,
              errorBuilder: (context) => const Text('Error View'),
              child: const Text('Button'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      expect(find.text('Error View'), findsOneWidget);
    });

    testWidgets('Icon button should wrap content in IconTheme', (tester) async {
      final action = AsyncAction0<void>(() async => const Result.ok(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncActionButton.icon(
              action: action,
              onTap: action.execute,
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });
  });
}
