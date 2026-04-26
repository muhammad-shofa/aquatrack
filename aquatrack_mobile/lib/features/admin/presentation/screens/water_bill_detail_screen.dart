import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/bill_model.dart';

class WaterBillDetailScreen extends StatelessWidget {
  const WaterBillDetailScreen({super.key, required this.bill});

  final BillModel bill;

  @override
  Widget build(BuildContext context) {
    final previous = bill.usageM3 > 0 ? (bill.usageM3 * 49) : 0;
    final current = previous + bill.usageM3;
    final subtotal = bill.totalAmount - bill.penaltyAmount;
    final isPaid = bill.status == 'paid';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Detail Tagihan Air',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.info_outline, size: 20, color: Color(0xFF6D7E90)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                const Text(
                  'Ringkasan Penggunaan',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
                ),
                Text(
                  'Periode Tagihan: ${_monthName(bill.periodMonth)} ${bill.periodYear}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(child: _meterCard('Meter Awal', '$previous m3')),
                    const SizedBox(width: 8),
                    Expanded(child: _meterCard('Meter Akhir', '$current m3')),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCEDFED)),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'TOTAL PEMAKAIAN',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${bill.usageM3}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 38,
                          height: 1,
                        ),
                      ),
                      const Text(
                        ' m3',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD5EAFE),
                          borderRadius: BorderRadius.circular(27),
                        ),
                        child: const Icon(
                          Icons.water_drop_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Rincian Biaya',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
                ),
                const SizedBox(height: 8),
                _line(
                  'Tarif Dasar',
                  Formatters.currency(subtotal),
                  subtitle: 'Rp 4.500 per m3',
                ),
                _line(
                  'Biaya Administrasi',
                  Formatters.currency(10000),
                  subtitle: 'Biaya bulanan tetap',
                ),
                _line(
                  'Denda Keterlambatan',
                  Formatters.currency(bill.penaltyAmount),
                  subtitle: bill.penaltyAmount > 0
                      ? 'Melewati jatuh tempo 20 (Okt)'
                      : '-',
                  highlight: bill.penaltyAmount > 0,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFD8E0EA),
                      style: BorderStyle.solid,
                    ),
                    color: const Color(0xFFF9FBFD),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Total Tagihan',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            Text(
                              Formatters.currency(bill.totalAmount),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 40,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isPaid
                              ? const Color(0xFFE7F7EA)
                              : const Color(0xFFEAF4E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isPaid ? 'LUNAS' : 'BELUM BAYAR',
                          style: TextStyle(
                            fontSize: 11,
                            color: isPaid
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFF3E8D50),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'LOKASI METERAN',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: <Color>[Color(0xFF5D9759), Color(0xFF6AA366)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: CircleAvatar(
                      radius: 13,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF5D9759),
                        size: 16,
                      ),
                    ),
                  ),
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Generate PDF masih placeholder.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text(
                      'Generate Tagihan (PDF)',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'PUDAM TIRTA KENCANA © 2023',
                    style: TextStyle(fontSize: 10, color: Color(0xFF9EADBD)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _meterCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD8DFEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 28),
          ),
        ],
      ),
    );
  }

  Widget _line(
    String label,
    String value, {
    String? subtitle,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: highlight
                          ? const Color(0xFFD32F2F)
                          : AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: highlight
                  ? const Color(0xFFD32F2F)
                  : const Color(0xFF2E3642),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = <String>[
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    if (month < 1 || month > 12) return '-';
    return months[month - 1];
  }
}
