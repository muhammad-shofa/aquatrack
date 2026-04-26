import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../admin/presentation/screens/customer_detail_screen.dart';
import '../../../admin/presentation/screens/meter_input_screen.dart';
import '../../../admin/presentation/screens/water_bill_detail_screen.dart';
import '../../../admin/providers/admin_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../shared/providers/monitoring_provider.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;
  int _paymentTab = 0;
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = '';

  @override
  void initState() {
    super.initState();
    final adminProvider = context.read<AdminProvider>();
    final monitoringProvider = context.read<MonitoringProvider>();
    Future<void>.microtask(() async {
      await adminProvider.loadDashboard();
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
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: <Widget>[
            _buildDashboardTab(),
            _buildCustomerListTab(),
            _buildPaymentVerificationTab(),
            _buildAccountTab(),
          ],
        ),
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
            icon: Icon(Icons.people_alt_outlined),
            label: 'Pelanggan',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            label: 'Tagihan',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Akun',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return Consumer2<AdminProvider, MonitoringProvider>(
      builder: (context, adminProvider, monitoringProvider, _) {
        if (adminProvider.isLoading && adminProvider.dashboard == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final dashboard = adminProvider.dashboard;
        if (dashboard == null) {
          return Center(
            child: Text(adminProvider.error ?? 'Data tidak tersedia'),
          );
        }

        return RefreshIndicator(
          onRefresh: adminProvider.loadDashboard,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 21,
                  color: Color(0xFF9CA8B6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      blurRadius: 10,
                      color: Color(0x12000000),
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 19,
                      backgroundColor: Color(0xFFE9F4FE),
                      child: Icon(
                        Icons.water_drop_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'AquaTrack Admin',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            'Pusat Kendali Air Bersih',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.notifications_none_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Ringkasan Statistik',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 28),
              ),
              const SizedBox(height: 10),
              GridView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.05,
                ),
                children: <Widget>[
                  _statCard(
                    'JUMLAH PELANGGAN',
                    dashboard.totalCustomers.toString(),
                    '+5%',
                    Colors.blue,
                  ),
                  _statCard(
                    'TAGIHAN TERTUNDA',
                    dashboard.totalUnpaidBills.toString(),
                    '-2%',
                    Colors.orange,
                  ),
                  _statCard(
                    'TOTAL (BULAN INI)',
                    Formatters.currency(dashboard.verifiedPaymentsThisMonth),
                    '+12%',
                    Colors.green,
                  ),
                  _statCard(
                    'LAPORAN PENGGUNAAN',
                    '${dashboard.readingsThisMonth} m3',
                    '+8%',
                    Colors.indigo,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Aksi Cepat',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 26),
              ),
              const SizedBox(height: 8),
              _quickAction(
                title: 'Input Meter Air',
                subtitle: 'Catat penggunaan air pelanggan baru',
                filled: true,
                icon: Icons.edit_outlined,
                onTap: () {
                  if (adminProvider.customers.isEmpty) return;
                  final customer = adminProvider.customers.first;
                  final latest =
                      monitoringProvider.usageReport
                          .where((e) => e.customerId == customer.id)
                          .toList()
                        ..sort((a, b) => b.id.compareTo(a.id));

                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => MeterInputScreen(
                        customer: customer,
                        previousMeter: latest.isNotEmpty
                            ? latest.first.currentMeter
                            : 0,
                      ),
                    ),
                  );
                },
              ),
              _quickAction(
                title: 'Generate Tagihan',
                subtitle: 'Terbitkan invoice bulan berjalan',
                icon: Icons.receipt_long_outlined,
                onTap: () async {
                  await context.read<MonitoringProvider>().exportReport('pdf');
                  if (!context.mounted) return;
                  final message = context
                      .read<MonitoringProvider>()
                      .exportMessage;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        message.isNotEmpty
                            ? message
                            : 'Generate tagihan diproses.',
                      ),
                    ),
                  );
                },
              ),
              _quickAction(
                title: 'Verifikasi Pembayaran',
                subtitle: 'Konfirmasi bukti transfer manual',
                icon: Icons.verified_user_outlined,
                onTap: () => setState(() => _selectedIndex = 2),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'Aktifitas Terbaru',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 26,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              _activityTile(
                icon: Icons.person_add_alt_1_outlined,
                iconColor: AppColors.primary,
                title: adminProvider.customers.isNotEmpty
                    ? '${adminProvider.customers.first.fullName} Terdaftar'
                    : 'Pelanggan Baru Terdaftar',
                subtitle: adminProvider.customers.isNotEmpty
                    ? adminProvider.customers.first.address
                    : 'Data pelanggan terbaru',
              ),
              _activityTile(
                icon: Icons.payments_outlined,
                iconColor: Colors.green,
                title: adminProvider.approvedPayments.isNotEmpty
                    ? 'Pembayaran Berhasil'
                    : 'Belum ada pembayaran terverifikasi',
                subtitle: adminProvider.approvedPayments.isNotEmpty
                    ? 'ID ${adminProvider.approvedPayments.first.referenceNumber ?? adminProvider.approvedPayments.first.id}'
                    : 'Menunggu data pembayaran',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomerListTab() {
    return Consumer2<AdminProvider, MonitoringProvider>(
      builder: (context, adminProvider, monitoringProvider, _) {
        return Column(
          children: <Widget>[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.arrow_back, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Data Pelanggan',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _openAddCustomer,
                    icon: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F4FE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) =>
                    adminProvider.searchCustomers(value, status: _statusFilter),
                decoration: InputDecoration(
                  hintText: 'Cari nama atau ID pelanggan...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF9FB0C0),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF9FB0C0),
                    size: 20,
                  ),
                  suffixIcon: const Icon(
                    Icons.tune,
                    color: Color(0xFF7F91A4),
                    size: 20,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE1E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE1E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  _chip('Semua', _statusFilter.isEmpty, () {
                    setState(() => _statusFilter = '');
                    adminProvider.searchCustomers(_searchController.text);
                  }),
                  const SizedBox(width: 8),
                  _chip('Lunas', _statusFilter == 'active', () {
                    setState(() => _statusFilter = 'active');
                    adminProvider.searchCustomers(
                      _searchController.text,
                      status: 'active',
                    );
                  }),
                  const SizedBox(width: 8),
                  _chip('Menunggu', _statusFilter == 'inactive', () {
                    setState(() => _statusFilter = 'inactive');
                    adminProvider.searchCustomers(
                      _searchController.text,
                      status: 'inactive',
                    );
                  }),
                  const SizedBox(width: 8),
                  _chip('Jatuh Temp', _statusFilter == 'overdue', () {
                    setState(() => _statusFilter = 'overdue');
                    adminProvider.searchCustomers(_searchController.text);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: adminProvider.customers.where((customer) {
                  if (_statusFilter != 'overdue') return true;
                  return monitoringProvider.arrearsReport.any(
                    (b) => b.customerId == customer.id,
                  );
                }).length,
                itemBuilder: (context, index) {
                  final filteredCustomers = adminProvider.customers.where((
                    customer,
                  ) {
                    if (_statusFilter != 'overdue') return true;
                    return monitoringProvider.arrearsReport.any(
                      (b) => b.customerId == customer.id,
                    );
                  }).toList();

                  final customer = filteredCustomers[index];
                  final customerReadings = monitoringProvider.usageReport
                      .where((e) => e.customerId == customer.id)
                      .toList();
                  final customerPayments = [
                    ...adminProvider.pendingPayments.where(
                      (e) => e.customerId == customer.id,
                    ),
                    ...adminProvider.approvedPayments.where(
                      (e) => e.customerId == customer.id,
                    ),
                    ...adminProvider.rejectedPayments.where(
                      (e) => e.customerId == customer.id,
                    ),
                  ];
                  final customerBills = monitoringProvider.arrearsReport
                      .where((e) => e.customerId == customer.id)
                      .toList();

                  final initials = customer.fullName
                      .split(' ')
                      .where((e) => e.isNotEmpty)
                      .take(2)
                      .map((e) => e[0])
                      .join();
                  final hasArrears = customerBills.isNotEmpty;
                  final badgeLabel = hasArrears
                      ? 'TERLAMBAT'
                      : customer.status == 'active'
                      ? 'LUNAS'
                      : 'MENUNGGU';
                  final badgeColor = hasArrears
                      ? const Color(0xFFFFECEC)
                      : customer.status == 'active'
                      ? const Color(0xFFE7F7EA)
                      : const Color(0xFFFFF3DF);
                  final badgeTextColor = hasArrears
                      ? const Color(0xFFD32F2F)
                      : customer.status == 'active'
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFB26900);

                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 6,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: _avatarBackground(index),
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      title: Text(
                        customer.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      subtitle: Text(
                        'ID: ${customer.customerNumber}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      trailing: SizedBox(
                        width: 112,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: badgeColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                badgeLabel,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: badgeTextColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF9FB0C0),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => CustomerDetailScreen(
                              customer: customer,
                              readings: customerReadings,
                              payments: customerPayments,
                              bills: customerBills,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentVerificationTab() {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        final list = switch (_paymentTab) {
          0 => provider.pendingPayments,
          1 => provider.approvedPayments,
          _ => provider.rejectedPayments,
        };

        return Column(
          children: <Widget>[
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: <Widget>[
                  Icon(Icons.arrow_back, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Verifikasi Pembayaran',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 19,
                      ),
                    ),
                  ),
                  SizedBox(width: 30),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  _paymentTabButton('Pending', 0),
                  _paymentTabButton('Disetujui', 1),
                  _paymentTabButton('Ditolak', 2),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _paymentTab == 0
                      ? 'Menunggu Persetujuan (${provider.pendingPayments.length})'
                      : _paymentTab == 1
                      ? 'Pembayaran Disetujui (${provider.approvedPayments.length})'
                      : 'Pembayaran Ditolak (${provider.rejectedPayments.length})',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  final thumbnails = <Color>[
                    const Color(0xFFB8E2E2),
                    const Color(0xFF246A6A),
                    const Color(0xFFF2F2F2),
                  ];

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: thumbnails[index % thumbnails.length],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.image_outlined,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              item.customer?.fullName ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  item.paymentDate,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  Formatters.currency(item.paidAmount),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            trailing: _paymentTab == 0
                                ? null
                                : Text(
                                    _paymentTab == 1 ? 'DISETUJUI' : 'DITOLAK',
                                    style: TextStyle(
                                      color: _paymentTab == 1
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFFD32F2F),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                            onTap: () {
                              if (item.bill != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        WaterBillDetailScreen(bill: item.bill!),
                                  ),
                                );
                              }
                            },
                          ),
                          if (_paymentTab == 0)
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF0F2F5),
                                      foregroundColor: const Color(0xFF222B38),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      minimumSize: const Size.fromHeight(36),
                                    ),
                                    onPressed: () =>
                                        provider.verifyPayment(item.id, false),
                                    child: const Text(
                                      'Tolak',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      minimumSize: const Size.fromHeight(36),
                                    ),
                                    onPressed: () =>
                                        provider.verifyPayment(item.id, true),
                                    child: const Text(
                                      'Setujui',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccountTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const CircleAvatar(
            radius: 34,
            child: Icon(Icons.person_outline, size: 34),
          ),
          const SizedBox(height: 10),
          const Text(
            'Admin AQUATRACK',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddCustomer() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController(text: 'password');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tambah Pelanggan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Telepon'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Alamat'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email Login'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password Login',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final ok = await context.read<AdminProvider>().addCustomer(
                  fullName: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                  address: addressController.text.trim(),
                  email: emailController.text.trim(),
                  password: passwordController.text,
                );

                if (!mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? 'Pelanggan berhasil ditambahkan.'
                          : 'Gagal menambahkan pelanggan.',
                    ),
                  ),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Widget _statCard(String label, String value, String trend, Color color) {
    final displayValue = value.startsWith('Rp ')
        ? value.replaceFirst('Rp ', 'Rp\n')
        : value;

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 10,
            color: Color(0x12000000),
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.pie_chart_outline, size: 15, color: color),
              const Spacer(),
              Text(
                trend,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayValue,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 32,
              color: Color(0xFF5B6878),
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: filled ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        shadowColor: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: <Widget>[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: filled
                        ? Colors.white.withValues(alpha: 0.2)
                        : const Color(0xFFE9F4FE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: filled ? Colors.white : AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                          color: filled ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: filled
                              ? Colors.white70
                              : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: filled ? Colors.white : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : const Color(0xFFE8ECF3),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (selected) ...[
              const Icon(Icons.check, size: 14, color: Colors.black),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _avatarBackground(int index) {
    const colors = <Color>[
      Color(0xFFE6F0FF),
      Color(0xFFFFE9D6),
      Color(0xFFFFE3E3),
      Color(0xFFE4ECFF),
      Color(0xFFF0E5FF),
    ];

    return colors[index % colors.length];
  }

  Widget _activityTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: <Widget>[
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentTabButton(String label, int index) {
    final selected = _paymentTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _paymentTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
