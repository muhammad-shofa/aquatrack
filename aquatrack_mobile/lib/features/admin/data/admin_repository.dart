import '../../../core/network/api_client.dart';
import '../../../core/network/api_parser.dart';
import '../../../data/models/api_response.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/models/payment_model.dart';

class AdminRepository {
  AdminRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<AdminDashboardModel> fetchDashboardStats() async {
    final response = await _apiClient.get('/dashboard/admin');
    final payload = ApiResponse<AdminDashboardModel>.fromJson(
      response.data as Map<String, dynamic>,
      (raw) => AdminDashboardModel.fromJson(raw as Map<String, dynamic>),
    );
    return payload.data;
  }

  Future<List<CustomerModel>> fetchCustomers({
    String? search,
    String? status,
  }) async {
    final response = await _apiClient.get(
      '/customers',
      queryParameters: <String, dynamic>{
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    final payload = ApiResponse<List<CustomerModel>>.fromJson(
      response.data as Map<String, dynamic>,
      (raw) => ApiParser.extractList(raw).map(CustomerModel.fromJson).toList(),
    );

    return payload.data;
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    await _apiClient.put(
      '/customers/${customer.id}',
      data: <String, dynamic>{
        'full_name': customer.fullName,
        'customer_number': customer.customerNumber,
        'meter_number': customer.meterNumber,
        'phone': customer.phone,
        'address': customer.address,
        'status': customer.status,
      },
    );
  }

  Future<void> createCustomer({
    required String fullName,
    required String phone,
    required String address,
    required String email,
    required String password,
  }) async {
    final stamp = DateTime.now().millisecondsSinceEpoch.toString();
    final suffix = stamp.substring(stamp.length - 6);

    await _apiClient.post(
      '/customers',
      data: <String, dynamic>{
        'full_name': fullName,
        'customer_number': 'CUST-$suffix',
        'meter_number': 'MTR-$suffix',
        'phone': phone,
        'address': address,
        'status': 'active',
        'email': email,
        'password': password,
      },
    );
  }

  Future<List<PaymentModel>> fetchPayments({String? status}) async {
    final response = await _apiClient.get(
      '/payments',
      queryParameters: <String, dynamic>{
        ...?status == null ? null : <String, dynamic>{'status': status},
      },
    );

    final payload = ApiResponse<List<PaymentModel>>.fromJson(
      response.data as Map<String, dynamic>,
      (raw) => ApiParser.extractList(raw).map(PaymentModel.fromJson).toList(),
    );

    return payload.data;
  }

  Future<List<PaymentModel>> fetchPendingPayments() {
    return fetchPayments(status: 'pending');
  }

  Future<void> verifyPayment({
    required int paymentId,
    required bool approved,
  }) async {
    await _apiClient.post(
      '/payments/$paymentId/verify',
      data: <String, dynamic>{
        'status': approved ? 'verified' : 'rejected',
        'verification_notes': approved ? 'Disetujui admin' : 'Ditolak admin',
      },
    );
  }

  Future<void> submitMeterReading({
    required int customerId,
    required int previousMeter,
    required int currentMeter,
  }) async {
    final now = DateTime.now();
    await _apiClient.post(
      '/meter-readings',
      data: <String, dynamic>{
        'customer_id': customerId,
        'period_month': now.month,
        'period_year': now.year,
        'previous_meter': previousMeter,
        'current_meter': currentMeter,
        'reading_date': now.toIso8601String().substring(0, 10),
      },
    );
  }
}
