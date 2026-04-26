import 'package:flutter/material.dart';

import '../../../data/models/customer_model.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/models/meter_reading_model.dart';
import '../data/collector_repository.dart';

class CollectorProvider extends ChangeNotifier {
  CollectorProvider({required CollectorRepository repository})
    : _repository = repository;

  final CollectorRepository _repository;

  bool isLoading = false;
  String? error;
  CollectorDashboardModel? dashboard;
  List<CustomerModel> customers = <CustomerModel>[];
  List<MeterReadingModel> recentReadings = <MeterReadingModel>[];

  Future<void> loadDashboard() async {
    isLoading = true;
    notifyListeners();
    try {
      dashboard = await _repository.fetchDashboardStats();
      customers = await _repository.fetchCustomers();
      recentReadings = await _repository.fetchRecentReadings();
      error = null;
    } catch (_) {
      error = 'Gagal memuat dashboard penagih.';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> searchCustomers(String keyword) async {
    isLoading = true;
    notifyListeners();
    try {
      customers = await _repository.fetchCustomers(search: keyword);
      error = null;
    } catch (_) {
      error = 'Pencarian pelanggan gagal.';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> submitMeter({
    required int customerId,
    required int previousMeter,
    required int currentMeter,
  }) async {
    if (currentMeter <= previousMeter) {
      error = 'Meter saat ini harus lebih besar dari meter sebelumnya.';
      notifyListeners();
      return false;
    }

    try {
      await _repository.submitMeterReading(
        customerId: customerId,
        previousMeter: previousMeter,
        currentMeter: currentMeter,
      );
      await loadDashboard();
      return true;
    } catch (_) {
      error = 'Input meter gagal.';
      notifyListeners();
      return false;
    }
  }
}
