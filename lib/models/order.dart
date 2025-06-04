import 'order_item.dart';

class Order {
  final int? id;
  final int sessionId;
  final String? userName;
  final double totalAmount;
  final String status;
  final DateTime? createdAt;
  final List<OrderItem>? items;

  Order({
    this.id,
    required this.sessionId,
    this.userName,
    this.totalAmount = 0.0,
    this.status = 'pending',
    this.createdAt,
    this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'user_name': userName,
      'total_amount': totalAmount,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      sessionId: map['session_id'],
      userName: map['user_name'],
      totalAmount: map['total_amount'].toDouble(),
      status: map['status'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }
}
