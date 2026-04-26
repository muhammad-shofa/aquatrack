class AdminDashboardModel {
  AdminDashboardModel({
    required this.totalCustomers,
    required this.activeCustomers,
    required this.totalUnpaidBills,
    required this.totalArrearsAmount,
    required this.verifiedPaymentsThisMonth,
    required this.readingsThisMonth,
  });

  final int totalCustomers;
  final int activeCustomers;
  final int totalUnpaidBills;
  final double totalArrearsAmount;
  final double verifiedPaymentsThisMonth;
  final int readingsThisMonth;

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardModel(
      totalCustomers: json['total_customers'] as int? ?? 0,
      activeCustomers: json['active_customers'] as int? ?? 0,
      totalUnpaidBills: json['total_unpaid_bills'] as int? ?? 0,
      totalArrearsAmount:
          (json['total_arrears_amount'] as num?)?.toDouble() ?? 0,
      verifiedPaymentsThisMonth:
          (json['verified_payments_this_month'] as num?)?.toDouble() ?? 0,
      readingsThisMonth: json['readings_this_month'] as int? ?? 0,
    );
  }
}

class CollectorDashboardModel {
  CollectorDashboardModel({
    required this.readingsInputted,
    required this.paymentsCollected,
    required this.pendingVerificationPayments,
  });

  final int readingsInputted;
  final double paymentsCollected;
  final int pendingVerificationPayments;

  factory CollectorDashboardModel.fromJson(Map<String, dynamic> json) {
    return CollectorDashboardModel(
      readingsInputted: json['readings_inputted'] as int? ?? 0,
      paymentsCollected: (json['payments_collected'] as num?)?.toDouble() ?? 0,
      pendingVerificationPayments:
          json['pending_verification_payments'] as int? ?? 0,
    );
  }
}
