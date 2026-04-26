import 'package:flutter/material.dart';

import '../../../data/models/bill_model.dart';
import '../../../data/models/meter_reading_model.dart';
import '../data/monitoring_repository.dart';

class MonitoringProvider extends ChangeNotifier {
  MonitoringProvider({required MonitoringRepository repository})
    : _repository = repository;

  final MonitoringRepository _repository;

  bool isLoading = false;
  String? error;
  List<BillModel> arrearsReport = <BillModel>[];
  List<MeterReadingModel> usageReport = <MeterReadingModel>[];
  String exportMessage = '';

  Future<void> loadReports() async {
    isLoading = true;
    notifyListeners();
    try {
      arrearsReport = await _repository.fetchArrearsReport();
      usageReport = await _repository.fetchUsageReport();
      error = null;
    } catch (_) {
      error = 'Gagal memuat laporan.';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> exportReport(String format) async {
    try {
      exportMessage = await _repository.requestExport(format);
      notifyListeners();
    } catch (_) {
      error = 'Export laporan gagal.';
      notifyListeners();
    }
  }

  Future<void> sendBillAlert(int billId) => _repository.sendBillAlert(billId);

  Future<void> sendDueReminder(int billId) =>
      _repository.sendDueReminder(billId);
}
