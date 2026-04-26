import 'package:flutter/material.dart';

import '../../../data/models/bill_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/meter_reading_model.dart';
import '../data/customer_repository.dart';

class CustomerProvider extends ChangeNotifier {
  CustomerProvider({required CustomerRepository repository})
    : _repository = repository;

  final CustomerRepository _repository;

  bool isLoading = false;
  String? error;
  CustomerModel? profile;
  List<BillModel> bills = <BillModel>[];
  List<MeterReadingModel> usageHistory = <MeterReadingModel>[];
  List<BillModel> arrears = <BillModel>[];

  Future<void> loadDashboard() async {
    isLoading = true;
    notifyListeners();
    try {
      profile = await _repository.fetchProfile();
      bills = await _repository.fetchBills();
      usageHistory = await _repository.fetchUsageHistory();
      arrears = bills.where((bill) => bill.status != 'paid').toList();
      error = null;
    } catch (_) {
      error = 'Gagal memuat data pelanggan.';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> submitOwnMeter({
    required int previousMeter,
    required int currentMeter,
  }) async {
    if (currentMeter <= previousMeter) {
      error = 'Meter saat ini harus lebih besar dari meter sebelumnya.';
      notifyListeners();
      return false;
    }
    try {
      await _repository.submitOwnMeter(
        previousMeter: previousMeter,
        currentMeter: currentMeter,
      );
      await loadDashboard();
      return true;
    } catch (_) {
      error = 'Input meter mandiri gagal.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitPayment({
    required int billId,
    required double amount,
    required String method,
    String? reference,
  }) async {
    try {
      await _repository.submitPayment(
        billId: billId,
        amount: amount,
        method: method,
        reference: reference,
      );
      await loadDashboard();
      return true;
    } catch (_) {
      error = 'Pengajuan pembayaran gagal.';
      notifyListeners();
      return false;
    }
  }
}
