import 'user_model.dart';

class CustomerModel {
  CustomerModel({
    required this.id,
    required this.customerNumber,
    required this.meterNumber,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.status,
    this.user,
  });

  final int id;
  final String customerNumber;
  final String meterNumber;
  final String fullName;
  final String phone;
  final String address;
  final String status;
  final UserModel? user;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as int? ?? 0,
      customerNumber: json['customer_number'] as String? ?? '',
      meterNumber: json['meter_number'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      status: json['status'] as String? ?? '',
      user: json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
