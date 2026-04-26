import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/bill_model.dart';
import '../../../../data/models/customer_model.dart';
import '../../../../data/models/meter_reading_model.dart';
import '../../../../data/models/payment_model.dart';
import 'meter_input_screen.dart';
import 'water_bill_detail_screen.dart';

class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({
    super.key,
    required this.customer,
    required this.readings,
    required this.payments,
    required this.bills,
  });

  final CustomerModel customer;
  final List<MeterReadingModel> readings;
  final List<PaymentModel> payments;
  final List<BillModel> bills;

  @override
  Widget build(BuildContext context) {
    final sortedReadings = [...readings]
      ..sort((a, b) => b.periodMonth.compareTo(a.periodMonth));
    final latestReading = sortedReadings.isNotEmpty
        ? sortedReadings.first
        : null;
    final sortedPayments = [...payments]..sort((a, b) => b.id.compareTo(a.id));
    final selectedBills = bills
        .where((b) => b.customerId == customer.id)
        .toList();
    final usageItems = sortedReadings.isNotEmpty
        ? sortedReadings.take(3).toList()
        : List<MeterReadingModel>.generate(selectedBills.take(3).length, (
            index,
          ) {
            final bill = selectedBills[index];
            return MeterReadingModel(
              id: bill.id,
              customerId: customer.id,
              periodMonth: bill.periodMonth,
              periodYear: bill.periodYear,
              previousMeter: bill.usageM3 * 10,
              currentMeter: bill.usageM3 * 11,
              usageM3: bill.usageM3,
              readingDate: '',
              status: 'validated',
            );
          });

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Detail Pelanggan',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(16, 26, 16, 20),
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
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: const Color(0xFF7D9386),
                      child: Text(
                        customer.fullName
                            .split(' ')
                            .where((e) => e.isNotEmpty)
                            .take(2)
                            .map((e) => e[0])
                            .join(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF25C15A),
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  customer.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: Color(0xFF5B6878),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID : ${customer.phone}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'R1 / 900VA',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: customer.status == 'active'
                            ? const Color(0xFFE7F7EA)
                            : const Color(0xFFFFECEC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        customer.status == 'active' ? 'AKTIF' : 'NON AKTIF',
                        style: TextStyle(
                          fontSize: 11,
                          color: customer.status == 'active'
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFD32F2F),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 6,
                      shadowColor: const Color(0x330A84CF),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => MeterInputScreen(
                            customer: customer,
                            previousMeter: latestReading?.currentMeter ?? 0,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_note_outlined, size: 20),
                    label: const Text(
                      'Input Meter Pelanggan',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _sectionTitle('INFORMASI DASAR'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Color(0xFFD8E0EA)),
            ),
            child: Column(
              children: <Widget>[
                _rowItem(
                  Icons.location_on_outlined,
                  'Alamat',
                  customer.address,
                ),
                _rowItem(Icons.phone_outlined, 'Telepon', customer.phone),
                _rowItem(
                  Icons.calendar_today_outlined,
                  'Siklus Tagihan',
                  'Tanggal 20',
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _sectionTitle('RIWAYAT PENGGUNAAN', action: 'Lihat Detail'),
          SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: usageItems.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = usageItems[index];
                return Container(
                  width: 116,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${item.periodMonth}/${item.periodYear}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${item.usageM3} kW h',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      Container(height: 4, color: AppColors.primary),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          _sectionTitle('RIWAYAT PEMBAYARAN'),
          ...sortedPayments.take(3).map((item) {
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFDCE3EC)),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE6F0FF),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    color: Color(0xFF1C3D63),
                  ),
                ),
                title: Text(item.bill?.invoiceNumber ?? 'Tagihan ${item.id}'),
                subtitle: Text('Status: ${item.status.toUpperCase()}'),
                trailing: Text(
                  Formatters.currency(item.paidAmount),
                  style: TextStyle(
                    color: item.status == 'verified'
                        ? Colors.green
                        : AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                onTap: () {
                  final bill = selectedBills.isNotEmpty
                      ? selectedBills.first
                      : item.bill;
                  if (bill != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => WaterBillDetailScreen(bill: bill),
                      ),
                    );
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, {String? action}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 1.6,
                fontSize: 18,
                color: Color(0xFF657284),
              ),
            ),
          ),
          if (action != null)
            Text(
              action,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _rowItem(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        label,
        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
      ),
      trailing: SizedBox(
        width: 160,
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
