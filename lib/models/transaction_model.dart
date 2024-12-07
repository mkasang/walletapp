import 'package:intl/intl.dart';

enum TransactionType {
  deposit,
  withdrawal,
  transfer,
  payment,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
}

class TransactionModel {
  final int? id;
  final int userId;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime date;
  final TransactionStatus status;
  final String? recipientId;
  final String? billReference;

  TransactionModel({
    this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    this.status = TransactionStatus.completed,
    this.recipientId,
    this.billReference,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.toString(),
      'amount': amount,
      'description': description,
      'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(date),
      'status': status.toString(),
      'recipient_id': recipientId,
      'bill_reference': billReference,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      userId: map['user_id'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == map['type'],
      ),
      amount: map['amount'],
      description: map['description'],
      date: DateFormat('yyyy-MM-dd HH:mm:ss').parse(map['date']),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
      ),
      recipientId: map['recipient_id'],
      billReference: map['bill_reference'],
    );
  }
}
