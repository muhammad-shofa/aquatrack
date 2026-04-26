import '../../../core/network/api_client.dart';
import '../../../core/network/api_parser.dart';
import '../../../data/models/api_response.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/models/meter_reading_model.dart';

class CollectorRepository {
  CollectorRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<CollectorDashboardModel> fetchDashboardStats() async {
    final response = await _apiClient.get('/dashboard/collector');
    final payload = ApiResponse<CollectorDashboardModel>.fromJson(
      response.data as Map<String, dynamic>,
      (raw) => CollectorDashboardModel.fromJson(raw as Map<String, dynamic>),
    );
    return payload.data;
  }

  Future<List<CustomerModel>> fetchCustomers({String? search}) async {
    final response = await _apiClient.get(
      '/reports/usage-history',
      queryParameters: <String, dynamic>{'period_year': DateTime.now().year},
    );

    final payload = ApiResponse<List<MeterReadingModel>>.fromJson(
      response.data as Map<String, dynamic>,
      (raw) =>
          ApiParser.extractList(raw).map(MeterReadingModel.fromJson).toList(),
    );

    final map = <int, CustomerModel>{};
    for (final item in payload.data) {
      if (item.customer != null) {
        map[item.customer!.id] = item.customer!;
      }
    }

    final customers = map.values.toList();
    if (search == null || search.isEmpty) {
      return customers;
    }

    final keyword = search.toLowerCase();
    return customers.where((c) {
      return c.fullName.toLowerCase().contains(keyword) ||
          c.customerNumber.toLowerCase().contains(keyword);
    }).toList();
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

  Future<List<MeterReadingModel>> fetchRecentReadings() async {
    final response = await _apiClient.get(
      '/meter-readings',
      queryParameters: <String, dynamic>{
        'period_month': DateTime.now().month,
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
}
