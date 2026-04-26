import 'package:flutter/material.dart';

import '../../../data/models/customer_model.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/models/payment_model.dart';
import '../data/admin_repository.dart';

class AdminProvider extends ChangeNotifier {
  AdminProvider({required AdminRepository repository})
    : _repository = repository;

  final AdminRepository _repository;

  bool isLoading = false;
  String? error;
  AdminDashboardModel? dashboard;
  List<CustomerModel> customers = <CustomerModel>[];
  List<PaymentModel> pendingPayments = <PaymentModel>[];
  List<PaymentModel> approvedPayments = <PaymentModel>[];
  List<PaymentModel> rejectedPayments = <PaymentModel>[];

  Future<void> loadDashboard() async {
    isLoading = true;
    notifyListeners();
    try {
      dashboard = await _repository.fetchDashboardStats();
      customers = await _repository.fetchCustomers();
      pendingPayments = await _repository.fetchPayments(status: 'pending');
      approvedPayments = await _repository.fetchPayments(status: 'verified');
      rejectedPayments = await _repository.fetchPayments(status: 'rejected');
      error = null;
    } catch (e) {
      error = 'Gagal memuat data admin.';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> searchCustomers(String keyword, {String? status}) async {
    isLoading = true;
    notifyListeners();
    try {
      customers = await _repository.fetchCustomers(
        search: keyword,
        status: status,
      );
      error = null;
    } catch (_) {
      error = 'Pencarian pelanggan gagal.';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      await _repository.updateCustomer(customer);
      await searchCustomers('');
    } catch (_) {
      error = 'Update pelanggan gagal.';
      notifyListeners();
    }
  }

  Future<bool> addCustomer({
    required String fullName,
    required String phone,
    required String address,
    required String email,
    required String password,
  }) async {
    try {
      await _repository.createCustomer(
        fullName: fullName,
        phone: phone,
        address: address,
        email: email,
        password: password,
      );
      await loadDashboard();
      return true;
    } catch (_) {
      error = 'Tambah pelanggan gagal.';
      notifyListeners();
      return false;
    }
  }

  Future<void> verifyPayment(int paymentId, bool approved) async {
    try {
      await _repository.verifyPayment(paymentId: paymentId, approved: approved);
      pendingPayments = await _repository.fetchPayments(status: 'pending');
      approvedPayments = await _repository.fetchPayments(status: 'verified');
      rejectedPayments = await _repository.fetchPayments(status: 'rejected');
      notifyListeners();
    } catch (_) {
      error = 'Verifikasi pembayaran gagal.';
      notifyListeners();
    }
  }

  Future<bool> submitMeterReading({
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
