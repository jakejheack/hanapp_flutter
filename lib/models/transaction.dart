class Transaction {
  final int id;
  final int userId;
  final String type; // e.g., 'withdrawal', 'cash_in', 'bonus', 'payment'
  final String description;
  final double amount;
  final String status; // e.g., 'completed', 'in_process', 'cancelled'
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.description,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      type: json['type'],
      description: json['description'],
      amount: double.parse(json['amount'].toString()),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'description': description,
      'amount': amount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}