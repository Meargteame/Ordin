import 'package:hive/hive.dart';

part 'finance_transaction.g.dart';

@HiveType(typeId: 64)
class FinanceTransaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  TransactionType type;

  @HiveField(3)
  String category;

  @HiveField(4)
  double amount;

  @HiveField(5)
  String description;

  FinanceTransaction({
    required this.id,
    required this.date,
    required this.type,
    required this.category,
    required this.amount,
    required this.description,
  });
}

@HiveType(typeId: 65)
enum TransactionType {
  @HiveField(0)
  expense,
  @HiveField(1)
  income,
}
