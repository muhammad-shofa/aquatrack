import 'customer_model.dart';

class BillModel {
  BillModel({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.periodMonth,
    required this.periodYear,
    required this.usageM3,
    required this.totalAmount,
    required this.penaltyAmount,
    required this.dueDate,
    required this.status,
    this.customer,
  });

  final int id;
  final String invoiceNumber;
  final int customerId;
  final int periodMonth;
  final int periodYear;
  final int usageM3;
  final double totalAmount;
  final double penaltyAmount;
  final String dueDate;
  final String status;
  final CustomerModel? customer;

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'] as int? ?? 0,
      invoiceNumber: json['invoice_number'] as String? ?? '',
      customerId: json['customer_id'] as int? ?? 0,
      periodMonth: json['period_month'] as int? ?? 0,
      periodYear: json['period_year'] as int? ?? 0,
      usageM3: json['usage_m3'] as int? ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      penaltyAmount: (json['penalty_amount'] as num?)?.toDouble() ?? 0,
      dueDate: json['due_date'] as String? ?? '',
      status: json['status'] as String? ?? '',
      customer: json['customer'] is Map<String, dynamic>
          ? CustomerModel.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
    );
  }
}
