import 'customer_model.dart';

class MeterReadingModel {
  MeterReadingModel({
    required this.id,
    required this.customerId,
    required this.periodMonth,
    required this.periodYear,
    required this.previousMeter,
    required this.currentMeter,
    required this.usageM3,
    required this.readingDate,
    required this.status,
    this.customer,
  });

  final int id;
  final int customerId;
  final int periodMonth;
  final int periodYear;
  final int previousMeter;
  final int currentMeter;
  final int usageM3;
  final String readingDate;
  final String status;
  final CustomerModel? customer;

  factory MeterReadingModel.fromJson(Map<String, dynamic> json) {
    return MeterReadingModel(
      id: json['id'] as int? ?? 0,
      customerId: json['customer_id'] as int? ?? 0,
      periodMonth: json['period_month'] as int? ?? 0,
      periodYear: json['period_year'] as int? ?? 0,
      previousMeter: json['previous_meter'] as int? ?? 0,
      currentMeter: json['current_meter'] as int? ?? 0,
      usageM3: json['usage_m3'] as int? ?? 0,
      readingDate: json['reading_date'] as String? ?? '',
      status: json['status'] as String? ?? '',
      customer: json['customer'] is Map<String, dynamic>
          ? CustomerModel.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
    );
  }
}
