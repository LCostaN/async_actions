import 'package:async_action/async_action.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AsyncAction Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ExampleScreen(),
    );
  }
}

typedef UserProfile = ({String name, String email});

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  // 1. Define actions in your state/viewmodel
  late final loginAction = AsyncAction0<String>(_simulateLogin);
  
  // Example using AsyncAction1 with a typedef for params
  late final fetchProfileAction = AsyncAction1<UserProfile, String>(_fetchProfile);

  Future<Result<String>> _simulateLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    // Simulated random failure
    if (DateTime.now().millisecond % 5 == 0) {
      return Result.error(Exception('Network timeout'));
    }
    return const Result.ok('User logged in!');
  }

  Future<Result<UserProfile>> _fetchProfile(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    return Result.ok((name: 'John Doe', email: 'john@example.com'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AsyncAction Example'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Simulated Login Action',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            // 2. Use AsyncActionButton for automatic loading/error handling
            AsyncActionButton.elevated(
              action: loginAction,
              onTap: loginAction.execute,
              errorBuilder: (context) => const Text('Error! Tap to retry'),
              child: const Text('Login'),
            ),
            
            const SizedBox(height: 32),
            
            const Text(
              'Profile Data (Reactive Builder)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 3. Use buildWidget extension for reactive data views
            fetchProfileAction.buildWidget(
              builder: (context, profile, child) {
                return Card(
                  child: ListTile(
                    title: Text(profile.name),
                    subtitle: Text(profile.email),
                    leading: const Icon(Icons.person),
                  ),
                );
              },
              loadingBuilder: (context) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              errorBuilder: (context, error) => TextButton.icon(
                onPressed: () => fetchProfileAction.execute('123'),
                icon: const Icon(Icons.refresh),
                label: const Text('Fetch Profile'),
              ),
            ),
            
            const Spacer(),
            
            // 4. Manually handling states with ListenableBuilder
            ListenableBuilder(
              listenable: loginAction,
              builder: (context, _) {
                if (loginAction.completed) {
                  return Text(
                    'Success: ${(loginAction.result! as Ok).value}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.green),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
