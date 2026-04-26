import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/providers/auth_provider.dart';
import 'admin_home_screen.dart';
import 'collector_home_screen.dart';
import 'customer_home_screen.dart';

class RoleGateScreen extends StatelessWidget {
  const RoleGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.status == AuthStatus.initial ||
            authProvider.status == AuthStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authProvider.isAuthenticated || authProvider.user == null) {
          return const LoginScreen();
        }

        switch (authProvider.user!.role) {
          case 'admin':
            return const AdminHomeScreen();
          case 'penagih':
            return const CollectorHomeScreen();
          default:
            return const CustomerHomeScreen();
        }
      },
    );
  }
}
