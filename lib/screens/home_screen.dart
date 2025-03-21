import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  final _authController = Get.find<AuthController>();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Obx(() {
        if (_authController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = _authController.user;
        if (user == null) {
          return const Center(child: Text('No user data available'));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${user.name}!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Name'),
                        subtitle: Text(user.name),
                      ),
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text('Email'),
                        subtitle: Text(user.email),
                      ),
                      ListTile(
                        leading: const Icon(Icons.numbers),
                        title: const Text('User ID'),
                        subtitle: Text(user.id.toString()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await _authController.logout();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
