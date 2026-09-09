class CheckoutResult {
  CheckoutResult({required this.transactionId, required this.checkoutUrl});

  final int transactionId;
  final String checkoutUrl;

  factory CheckoutResult.fromJson(Map<String, dynamic> json) => CheckoutResult(
        transactionId: json['transactionId'] as int,
        checkoutUrl: json['checkoutUrl'] as String,
      );
}

class OrderStatus {
  OrderStatus({required this.id, required this.status, required this.totalAmount, required this.paidAt});

  final int id;
  final String status;
  final double totalAmount;
  final DateTime? paidAt;

  bool get isPaid => status == 'paid';
  bool get isFailed => status == 'failed';
  bool get isPending => status == 'pending';

  factory OrderStatus.fromJson(Map<String, dynamic> json) => OrderStatus(
        id: json['id'] as int,
        status: json['status'] as String,
        totalAmount: (json['totalAmount'] as num).toDouble(),
        paidAt: json['paidAt'] == null ? null : DateTime.parse(json['paidAt'] as String),
      );
}
