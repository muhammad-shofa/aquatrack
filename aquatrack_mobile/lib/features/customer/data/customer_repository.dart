import '../../../core/network/api_client.dart';
import '../../../core/network/api_parser.dart';
import '../../../data/models/api_response.dart';
import '../../../data/models/bill_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/meter_reading_model.dart';

class CustomerRepository {
  CustomerRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<CustomerModel> fetchProfile() async {
    final response = await _apiClient.get('/me/customer-profile');
    final payload = ApiResponse<CustomerModel>.fromJson(
      response.data as Map<String, dynamic>,
      (raw) => CustomerModel.fromJson(raw as Map<String, dynamic>),
    );
    return payload.data;
  }

  Future<List<BillModel>> fetchBills() async {
    final response = await _apiClient.get('/bills');
    final payload = ApiResponse<List<BillModel>>.fromJson(
      response.data as Map<String, dynamic>,
      (raw) => ApiParser.extractList(raw).map(BillModel.fromJson).toList(),
    );
    return payload.data;
  }

  Future<List<MeterReadingModel>> fetchUsageHistory() async {
    final response = await _apiClient.get('/meter-readings');
    final payload = ApiResponse<List<MeterReadingModel>>.fromJson(
      response.data as Map<String, dynamic>,
      (raw) =>
          ApiParser.extractList(raw).map(MeterReadingModel.fromJson).toList(),
    );
    return payload.data;
  }

  Future<void> submitOwnMeter({
    required int previousMeter,
    required int currentMeter,
  }) async {
    final now = DateTime.now();
    await _apiClient.post(
      '/meter-readings',
      data: <String, dynamic>{
        'period_month': now.month,
        'period_year': now.year,
        'previous_meter': previousMeter,
        'current_meter': currentMeter,
        'reading_date': now.toIso8601String().substring(0, 10),
      },
    );
  }

  Future<void> submitPayment({
    required int billId,
    required double amount,
    required String method,
    String? reference,
  }) async {
    await _apiClient.post(
      '/payments',
      data: <String, dynamic>{
        'bill_id': billId,
        'paid_amount': amount,
        'payment_date': DateTime.now().toIso8601String().substring(0, 10),
        'payment_method': method,
        'reference_number': reference,
      },
    );
  }
}
