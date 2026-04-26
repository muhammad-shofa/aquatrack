import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../../collector/providers/collector_provider.dart';
import '../../../shared/providers/monitoring_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/customer_model.dart';

class CollectorHomeScreen extends StatefulWidget {
  const CollectorHomeScreen({super.key});

  @override
  State<CollectorHomeScreen> createState() => _CollectorHomeScreenState();
}

class _CollectorHomeScreenState extends State<CollectorHomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final collectorProvider = context.read<CollectorProvider>();
    final monitoringProvider = context.read<MonitoringProvider>();
    Future<void>.microtask(() async {
      await collectorProvider.loadDashboard();
      await monitoringProvider.loadReports();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Penagih'),
        actions: <Widget>[
          IconButton(
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[_dashboardTab(), _customersTab(), _arrearsTab()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) =>
            setState(() => _selectedIndex = value),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            label: 'Pelanggan',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Tunggakan',
          ),
        ],
      ),
    );
  }

  Widget _dashboardTab() {
    return Consumer<CollectorProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.dashboard == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final dashboard = provider.dashboard;
        if (dashboard == null) {
          return Center(child: Text(provider.error ?? 'Data tidak tersedia'));
        }

        return RefreshIndicator(
          onRefresh: provider.loadDashboard,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _infoTile('Input meter', dashboard.readingsInputted.toString()),
              _infoTile(
                'Pembayaran terkumpul',
                Formatters.currency(dashboard.paymentsCollected),
              ),
              _infoTile(
                'Pending verifikasi',
                dashboard.pendingVerificationPayments.toString(),
              ),
              const SizedBox(height: 14),
              const Text(
                'Aktivitas Terbaru',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              const SizedBox(height: 8),
              ...provider.recentReadings.map((item) {
                return Card(
                  child: ListTile(
                    title: Text(item.customer?.fullName ?? '-'),
                    subtitle: Text('Pemakaian: ${item.usageM3} m3'),
                    trailing: Text(item.readingDate),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _customersTab() {
    return Consumer<CollectorProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Cari pelanggan',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: provider.searchCustomers,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.customers.length,
                  itemBuilder: (context, index) {
                    final customer = provider.customers[index];
                    return Card(
                      child: ListTile(
                        title: Text(customer.fullName),
                        subtitle: Text(customer.customerNumber),
                        trailing: ElevatedButton(
                          onPressed: () => _openInputMeter(customer),
                          child: const Text('Input Meter'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _arrearsTab() {
    return Consumer<MonitoringProvider>(
      builder: (context, provider, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: provider.arrearsReport.map((bill) {
            return Card(
              child: ListTile(
                title: Text(bill.customer?.fullName ?? '-'),
                subtitle: Text('Tagihan ${bill.invoiceNumber}'),
                trailing: Text(Formatters.currency(bill.totalAmount)),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _infoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Future<void> _openInputMeter(CustomerModel customer) async {
    final previousController = TextEditingController();
    final currentController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Input Meter - ${customer.fullName}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: previousController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Meter Sebelumnya',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: currentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Meter Saat Ini'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final provider = context.read<CollectorProvider>();
                    final ok = await provider.submitMeter(
                      customerId: customer.id,
                      previousMeter: int.tryParse(previousController.text) ?? 0,
                      currentMeter: int.tryParse(currentController.text) ?? 0,
                    );
                    if (!context.mounted) return;
                    if (ok) {
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(provider.error ?? 'Input meter gagal.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Kirim Laporan Meter'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
