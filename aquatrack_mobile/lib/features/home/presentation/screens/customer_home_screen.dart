import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../../customer/providers/customer_provider.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/bill_model.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _previousMeterController =
      TextEditingController();
  final TextEditingController _currentMeterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final customerProvider = context.read<CustomerProvider>();
    Future<void>.microtask(customerProvider.loadDashboard);
  }

  @override
  void dispose() {
    _previousMeterController.dispose();
    _currentMeterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AQUATRACK Pelanggan'),
        actions: <Widget>[
          IconButton(
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          _dashboardTab(),
          _billsTab(),
          _meterTab(),
          _historyTab(),
        ],
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
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Tagihan',
          ),
          NavigationDestination(
            icon: Icon(Icons.speed_outlined),
            label: 'Meter',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }

  Widget _dashboardTab() {
    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = provider.profile;
        if (profile == null) {
          return Center(child: Text(provider.error ?? 'Data tidak tersedia'));
        }

        final unpaid = provider.bills.where((b) => b.status != 'paid').length;

        return RefreshIndicator(
          onRefresh: provider.loadDashboard,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Card(
                child: ListTile(
                  title: Text(
                    profile.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${profile.customerNumber} • ${profile.phone}',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _stat('Total Tagihan', provider.bills.length.toString()),
              _stat('Belum Dibayar', unpaid.toString()),
              _stat(
                'Total Tunggakan',
                Formatters.currency(
                  provider.arrears.fold<double>(0, (p, e) => p + e.totalAmount),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _billsTab() {
    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.bills.length,
          itemBuilder: (context, index) {
            final bill = provider.bills[index];
            return Card(
              child: ListTile(
                title: Text(bill.invoiceNumber),
                subtitle: Text(
                  'Denda: ${Formatters.currency(bill.penaltyAmount)}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      Formatters.currency(bill.totalAmount),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(bill.status),
                  ],
                ),
                onTap: () => _openBillDetail(bill),
              ),
            );
          },
        );
      },
    );
  }

  Widget _meterTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Consumer<CustomerProvider>(
        builder: (context, provider, _) {
          return ListView(
            children: <Widget>[
              const Text(
                'Input Meter Pelanggan',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _previousMeterController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Meter Sebelumnya',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _currentMeterController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Meter Saat Ini'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final ok = await provider.submitOwnMeter(
                    previousMeter:
                        int.tryParse(_previousMeterController.text) ?? 0,
                    currentMeter:
                        int.tryParse(_currentMeterController.text) ?? 0,
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok
                            ? 'Input meter berhasil.'
                            : (provider.error ?? 'Gagal'),
                      ),
                    ),
                  );
                },
                child: const Text('Kirim Laporan Meter'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _historyTab() {
    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const Text(
              'Riwayat Penggunaan',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 8),
            ...provider.usageHistory.map((item) {
              return Card(
                child: ListTile(
                  title: Text('${item.periodMonth}/${item.periodYear}'),
                  subtitle: Text(
                    'Meter ${item.previousMeter} → ${item.currentMeter}',
                  ),
                  trailing: Text('${item.usageM3} m3'),
                ),
              );
            }),
            const SizedBox(height: 12),
            const Text(
              'Notifikasi',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            ...provider.arrears.map(
              (bill) => ListTile(
                leading: const Icon(Icons.notifications_active_outlined),
                title: Text('Tagihan ${bill.invoiceNumber} belum dibayar'),
                subtitle: Text('Jatuh tempo ${bill.dueDate}'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _stat(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Future<void> _openBillDetail(BillModel bill) async {
    final amountController = TextEditingController(
      text: bill.totalAmount.toStringAsFixed(0),
    );
    final refController = TextEditingController();
    String method = 'transfer';

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
                'Detail Tagihan Air',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text('Invoice: ${bill.invoiceNumber}'),
              Text('Total: ${Formatters.currency(bill.totalAmount)}'),
              Text('Denda: ${Formatters.currency(bill.penaltyAmount)}'),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nominal Bayar'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: method,
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                ],
                onChanged: (value) => method = value ?? 'transfer',
              ),
              const SizedBox(height: 8),
              TextField(
                controller: refController,
                decoration: const InputDecoration(
                  labelText: 'No Referensi / Bukti',
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final provider = context.read<CustomerProvider>();
                    final ok = await provider.submitPayment(
                      billId: bill.id,
                      amount:
                          double.tryParse(amountController.text) ??
                          bill.totalAmount,
                      method: method,
                      reference: refController.text,
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok ? 'Pembayaran diajukan.' : 'Pengajuan gagal.',
                        ),
                      ),
                    );
                  },
                  child: const Text('Kirim Pembayaran'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
