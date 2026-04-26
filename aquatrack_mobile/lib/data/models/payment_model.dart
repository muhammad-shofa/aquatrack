import 'bill_model.dart';
import 'customer_model.dart';

class PaymentModel {
  PaymentModel({
    required this.id,
    required this.billId,
    required this.customerId,
    required this.paidAmount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.status,
    this.referenceNumber,
    this.bill,
    this.customer,
  });

  final int id;
  final int billId;
  final int customerId;
  final double paidAmount;
  final String paymentDate;
  final String paymentMethod;
  final String status;
  final String? referenceNumber;
  final BillModel? bill;
  final CustomerModel? customer;

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as int? ?? 0,
      billId: json['bill_id'] as int? ?? 0,
      customerId: json['customer_id'] as int? ?? 0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0,
      paymentDate: json['payment_date'] as String? ?? '',
      paymentMethod: json['payment_method'] as String? ?? '',
      status: json['status'] as String? ?? '',
      referenceNumber: json['reference_number'] as String?,
      bill: json['bill'] is Map<String, dynamic>
          ? BillModel.fromJson(json['bill'] as Map<String, dynamic>)
          : null,
      customer: json['customer'] is Map<String, dynamic>
          ? CustomerModel.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
    );
  }
}
