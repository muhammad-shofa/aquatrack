import '../../../core/network/api_client.dart';
import '../../../core/network/api_parser.dart';
import '../../../data/models/api_response.dart';
import '../../../data/models/bill_model.dart';
import '../../../data/models/meter_reading_model.dart';

class MonitoringRepository {
  MonitoringRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<BillModel>> fetchArrearsReport() async {
    final response = await _apiClient.get('/reports/arrears');
    final payload = ApiResponse<List<BillModel>>.fromJson(
      response.data as Map<String, dynamic>,
      (raw) => ApiParser.extractList(raw).map(BillModel.fromJson).toList(),
    );
    return payload.data;
  }

  Future<List<MeterReadingModel>> fetchUsageReport({int? customerId}) async {
    final response = await _apiClient.get(
      '/reports/usage-history',
      queryParameters: <String, dynamic>{
        ...?customerId == null
            ? null
            : <String, dynamic>{'customer_id': customerId},
        'period_year': DateTime.now().year,
      },
    );

    final payload = ApiResponse<List<MeterReadingModel>>.fromJson(
      response.data as Map<String, dynamic>,
      (raw) =>
          ApiParser.extractList(raw).map(MeterReadingModel.fromJson).toList(),
    );
    return payload.data;
  }

  Future<String> requestExport(String format) async {
    final response = await _apiClient.post(
      '/reports/export',
      data: <String, dynamic>{'format': format},
    );
    final payload = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data as Map<String, dynamic>,
      (raw) => ApiParser.extractMap(raw),
    );
    return payload.data['message'] as String? ?? payload.message;
  }

  Future<void> sendBillAlert(int billId) async {
    await _apiClient.post('/notifications/bills/$billId/alert');
  }

  Future<void> sendDueReminder(int billId) async {
    await _apiClient.post('/notifications/bills/$billId/reminder');
  }
}
