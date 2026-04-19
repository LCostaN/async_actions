# Async Action

**AsyncAction** is a library for Flutter designed to make asynchronous actions highly reactive to UI changes. 

The main goal is to encapsulate asynchronous logic in a way that allows the UI to easily react to running, completed, and error states without manually managing boolean flags or error variables in your ViewModels.

## Features

- **Reactivity**: Automatically notifies listeners when an action starts, finishes, or fails.
- **Concurrency Control**: Prevents multiple overlapping executions of the same action.
- **State Management**: Built-in support for `running`, `error`, and `result` states.
- **UI Interaction**: Includes `AsyncActionButton` and `AsyncActionWidgetBuilder` for seamless integration.

## Usage Guidelines

### 1. UI Reactivity, Not Background Processing
`AsyncAction` is intended for **UI reactivity**. It facilitates interaction between a ViewModel/Store and the View. It is **not** meant to be used inside background processes or repositories. Use standard `Future` or `Stream` patterns for those layers.

### 2. Scoped State Changes
The library expects to be used with `ListenableBuilder` (or similar listenable-based widgets) to handle scoped state changes efficiently.

### 3. Best Practices for AsyncAction1
When using `AsyncAction1` (actions with one argument), it is a best practice to create a `typedef` for your input type. This improves readability and maintainability compared to using anonymous tuples or multiple positional arguments.

```dart
typedef LoginParams = ({String email, String password});

// In your ViewModel
final loginAction = AsyncAction1<User, LoginParams>(_login);
```

## Getting Started

Add `async_action` to your `pubspec.yaml`:

```yaml
dependencies:
  async_action: ^<latest_version>
```

## Quick Start

```dart
// 1. Define your action using a named function (Best Practice)
late final myAction = AsyncAction0<String>(_doSomething);

Future<Result<String>> _doSomething() async {
  await Future.delayed(const Duration(seconds: 2));
  return Result.ok("Success!");
}

// 2. Use it in your UI
AsyncActionButton.elevated(
  action: myAction,
  onTap: myAction.execute,
  child: const Text("Run Action"),
)
```

## Additional information

This package is designed for lean and reactive Flutter applications. Contributions and issues are welcome in the repository.
