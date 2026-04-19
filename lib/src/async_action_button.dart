import 'package:flutter/material.dart';

import 'async_action_base.dart';

typedef WidgetBuilderCallback = Widget Function(BuildContext context);

enum ButtonType { elevated, filled, outlined, text, icon }

/// A button widget that integrates with an [AsyncAction] and behaves similarly to
/// Flutter's standard button widgets.
///
/// This widget provides additional functionality to handle loading and error
/// states by allowing custom widgets to be displayed during these states.
class AsyncActionButton extends StatelessWidget {
  /// The [AsyncAction] instance that this button interacts with. It
  /// determines the button's behavior and state.
  final AsyncAction action;

  /// An optional callback that builds a widget to display
  /// when the button is in a loading state.
  final WidgetBuilderCallback loadingBuilder;

  /// An optional callback that builds a widget to display
  /// when the button is in an error state.
  final WidgetBuilderCallback? errorBuilder;

  /// An optional [ButtonStyle] to customize the appearance of the
  /// button.
  final ButtonStyle? style;

  /// Specifies the type of button, allowing customization of
  /// its behavior and appearance.
  final ButtonType buttonType;

  /// The widget to display when the button is neither loading nor
  /// showing an error. This is typically the main content of the button.
  final Widget child;

  /// A callback function that is triggered when the button is tapped.
  ///
  /// This `onTap` is expected to be derived from the `action` passed to the
  /// `AsyncActionButton`. It ensures that the button correctly tracks the state
  /// of the `action` and performs the associated actions.
  final VoidCallback? onTap;

  const AsyncActionButton._({
    required this.action,
    required this.child,
    required this.buttonType,
    required this.onTap,
    this.loadingBuilder = _defaultLoadingBuilder,
    this.errorBuilder,
    this.style,
    super.key,
  });

  /// A factory constructor for creating an elevated [AsyncActionButton].
  factory AsyncActionButton.elevated({
    required AsyncAction action,
    required Widget child,
    required VoidCallback? onTap,
    WidgetBuilderCallback? loadingBuilder,
    WidgetBuilderCallback? errorBuilder,
    ButtonStyle? style,
    Key? key,
  }) => AsyncActionButton._(
    action: action,
    onTap: onTap,
    buttonType: ButtonType.elevated,
    loadingBuilder: loadingBuilder ?? _defaultLoadingBuilder,
    errorBuilder: errorBuilder,
    style: style,
    key: key,
    child: child,
  );

  /// A factory constructor for creating a filled [AsyncActionButton].
  factory AsyncActionButton.filled({
    required AsyncAction action,
    required Widget child,
    required VoidCallback? onTap,
    WidgetBuilderCallback? loadingBuilder,
    WidgetBuilderCallback? errorBuilder,
    ButtonStyle? style,
    Key? key,
  }) => AsyncActionButton._(
    action: action,
    onTap: onTap,
    buttonType: ButtonType.filled,
    loadingBuilder: loadingBuilder ?? _defaultLoadingBuilder,
    errorBuilder: errorBuilder,
    style: style,
    key: key,
    child: child,
  );

  /// A factory constructor for creating an outlined [AsyncActionButton].
  factory AsyncActionButton.outlined({
    required AsyncAction action,
    required Widget child,
    required VoidCallback? onTap,
    WidgetBuilderCallback? loadingBuilder,
    WidgetBuilderCallback? errorBuilder,
    ButtonStyle? style,
    Key? key,
  }) => AsyncActionButton._(
    action: action,
    onTap: onTap,
    buttonType: ButtonType.outlined,
    loadingBuilder: loadingBuilder ?? _defaultLoadingBuilder,
    errorBuilder: errorBuilder,
    style: style,
    key: key,
    child: child,
  );

  /// A factory constructor for creating a text [AsyncActionButton].
  factory AsyncActionButton.text({
    required AsyncAction action,
    required Widget child,
    required VoidCallback? onTap,
    WidgetBuilderCallback? loadingBuilder,
    WidgetBuilderCallback? errorBuilder,
    ButtonStyle? style,
    Key? key,
  }) => AsyncActionButton._(
    action: action,
    onTap: onTap,
    buttonType: ButtonType.text,
    loadingBuilder: loadingBuilder ?? _defaultLoadingBuilder,
    errorBuilder: errorBuilder,
    style: style,
    key: key,
    child: child,
  );

  /// A factory constructor for creating an icon [AsyncActionButton].
  factory AsyncActionButton.icon({
    required AsyncAction action,
    required Widget child,
    required VoidCallback? onTap,
    WidgetBuilderCallback? loadingBuilder,
    WidgetBuilderCallback? errorBuilder,
    ButtonStyle? style,
    Key? key,
  }) => AsyncActionButton._(
    action: action,
    onTap: onTap,
    buttonType: ButtonType.icon,
    loadingBuilder: loadingBuilder ?? _defaultLoadingBuilder,
    errorBuilder: errorBuilder,
    style: style,
    key: key,
    child: child,
  );

  static Widget _defaultLoadingBuilder(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(8.0),
      child: AspectRatio(aspectRatio: 1, child: CircularProgressIndicator(strokeWidth: 2)),
    ),
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: action,
    builder: (context, content) {
      Widget? loadingOverlay;
      if (action.running) {
        loadingOverlay = Positioned.fill(child: loadingBuilder(context));
      }

      Widget? errorOverlay;
      if (action.error && errorBuilder != null) {
        errorOverlay = Positioned.fill(child: errorBuilder!(context));
      }

      final buttonContent = Opacity(
        opacity: loadingOverlay == null || errorOverlay != null ? 1 : 0,
        child: buttonType == ButtonType.icon ? IconTheme(data: IconTheme.of(context), child: child) : child,
      );

      Widget button;
      switch (buttonType) {
        case ButtonType.elevated:
          button = ElevatedButton(onPressed: onTap, style: style, child: buttonContent);
          break;
        case ButtonType.filled:
          button = FilledButton(onPressed: onTap, style: style, child: buttonContent);
          break;
        case ButtonType.outlined:
          button = OutlinedButton(onPressed: onTap, style: style, child: buttonContent);
          break;
        case ButtonType.text:
          button = TextButton(onPressed: onTap, style: style, child: buttonContent);
          break;
        case ButtonType.icon:
          button = IconButton(onPressed: onTap, style: style, icon: buttonContent);
          break;
      }

      return Stack(
        alignment: Alignment.center,
        children: [button, if (loadingOverlay != null) loadingOverlay, if (errorOverlay != null) errorOverlay],
      );
    },
  );
}
