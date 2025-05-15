import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_template/src/presentation/core/router/routes.dart';
import 'package:go_router/go_router.dart';
import '../../../core/application_state/logout_provider/logout_provider.dart';
import '../../../core/widgets/loading_indicator.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(logoutProvider, (previous, next) {
      if (next.isSuccess) context.go(Routes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logoutProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        actions: [

          IconButton(
            icon: ref.watch(logoutProvider).isLoading
                ? const LoadingIndicator()
                : const Icon(Icons.logout),
            onPressed: ref.watch(logoutProvider).isLoading
                ? null // Disable button during loading
                : () {
              ref.read(logoutProvider.notifier).call();
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(
                  'assets/profile.jpg'), // Replace with actual image path
            ),
            SizedBox(height: 16),
            Text(
              'John Doe', // Replace with dynamic username if needed
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Welcome to the Profile Page!',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
