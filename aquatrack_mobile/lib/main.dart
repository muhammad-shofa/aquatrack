import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/data/admin_repository.dart';
import 'features/admin/providers/admin_provider.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/collector/data/collector_repository.dart';
import 'features/collector/providers/collector_provider.dart';
import 'features/customer/data/customer_repository.dart';
import 'features/customer/providers/customer_provider.dart';
import 'features/home/presentation/screens/role_gate_screen.dart';
import 'features/shared/data/monitoring_repository.dart';
import 'features/shared/providers/monitoring_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final SecureStorageService storageService = SecureStorageService();
  final ApiClient apiClient = ApiClient(storageService: storageService);
  final AuthRepository authRepository = AuthRepository(
    apiClient: apiClient,
    storageService: storageService,
  );
  final AuthProvider authProvider = AuthProvider(repository: authRepository);

  apiClient.onUnauthorized = authProvider.handleUnauthorized;
  authProvider.initialize();

  runApp(AquatrackApp(authProvider: authProvider, apiClient: apiClient));
}

class AquatrackApp extends StatelessWidget {
  const AquatrackApp({
    super.key,
    required this.authProvider,
    required this.apiClient,
  });

  final AuthProvider authProvider;
  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<AdminProvider>(
          create: (_) =>
              AdminProvider(repository: AdminRepository(apiClient: apiClient)),
        ),
        ChangeNotifierProvider<CollectorProvider>(
          create: (_) => CollectorProvider(
            repository: CollectorRepository(apiClient: apiClient),
          ),
        ),
        ChangeNotifierProvider<CustomerProvider>(
          create: (_) => CustomerProvider(
            repository: CustomerRepository(apiClient: apiClient),
          ),
        ),
        ChangeNotifierProvider<MonitoringProvider>(
          create: (_) => MonitoringProvider(
            repository: MonitoringRepository(apiClient: apiClient),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'AQUATRACK',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const RoleGateScreen(),
      ),
    );
  }
}
