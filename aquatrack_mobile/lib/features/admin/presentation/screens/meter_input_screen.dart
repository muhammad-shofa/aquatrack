import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/customer_model.dart';
import '../../providers/admin_provider.dart';

class MeterInputScreen extends StatefulWidget {
  const MeterInputScreen({
    super.key,
    required this.customer,
    required this.previousMeter,
  });

  final CustomerModel customer;
  final int previousMeter;

  @override
  State<MeterInputScreen> createState() => _MeterInputScreenState();
}

class _MeterInputScreenState extends State<MeterInputScreen> {
  late final TextEditingController _previousController;
  final TextEditingController _currentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final previous = widget.previousMeter == 0
        ? '1240'
        : widget.previousMeter.toString();
    _previousController = TextEditingController(text: previous);
  }

  @override
  void dispose() {
    _previousController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Input Meter Pelanggan',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
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
                  color: Color(0x10000000),
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Informasi Pelanggan',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Data identitas pelanggan yang terdaftar.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                const Text(
                  'ID Pelanggan',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  initialValue: widget.customer.customerNumber,
                  enabled: false,
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.lock_outline, size: 18),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE3E8EF)),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF1F4F8),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Data Meteran',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Masukkan angka stand meter terbaru Anda.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Meteran Sebelumnya (kWh)',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _previousController,
                  enabled: false,
                  decoration: InputDecoration(
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE3E8EF)),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF1F4F8),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Meteran Saat Ini (kWh)',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _currentController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: const TextStyle(color: Color(0xFF9EB0C1)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFB9D5E9)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FBFE),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Foto Meteran',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFBFD2E5),
                      style: BorderStyle.solid,
                    ),
                    color: const Color(0xFFFBFDFF),
                  ),
                  child: const Column(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(0xFFE6F1FB),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Ambil Foto Meteran',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Pastikan angka pada meteran terlihat jelas dan\ntidak buram',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF6E8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF4DFBB)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFFE29D2C),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Penginputan meteran yang tidak sesuai dapat\nmengakibatkan tagihan yang tidak akurat. Pastikan\ndata benar sebelum mengirim.',
                          style: TextStyle(
                            color: Color(0xFF9E6B22),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final previous = _toIntMeter(_previousController.text);
                      final current = _toIntMeter(_currentController.text);

                      final ok = await context
                          .read<AdminProvider>()
                          .submitMeterReading(
                            customerId: widget.customer.id,
                            previousMeter: previous,
                            currentMeter: current,
                          );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? 'Laporan meter terkirim.'
                                : 'Gagal mengirim meter.',
                          ),
                        ),
                      );
                      if (ok) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Kirim Laporan Meter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _toIntMeter(String value) {
    final normalized = value.replaceAll('.', '').trim();
    final whole = normalized.contains(',')
        ? normalized.split(',').first
        : normalized;

    return int.tryParse(whole) ?? 0;
  }
}
