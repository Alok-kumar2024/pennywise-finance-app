import 'package:pennywise/src/domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  TransactionModel({
    required super.accountId,
    required super.amount,
    required super.category,
    required super.date,
    required super.finance,
    required super.name,
    required super.pending,
    required super.transactionId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      accountId: json["account_id"] ?? "",
      amount: (json["amount"] as num).toDouble() * -1,
      category: List<String>.from(json["category"] ?? []),
      date: json["date"] ?? "",
      name: json["name"] ?? "",
      pending: json["pending"] ?? false,
      transactionId: json["transaction_id"] ?? "",
      finance: PrimaryFinanceModel.fromJson(
        json["personal_finance_category"] ?? {},
      ),
    );
  }
}

class PrimaryFinanceModel extends PrimaryFinanceEntity {
  PrimaryFinanceModel({required super.primary, required super.detailed});

  factory PrimaryFinanceModel.fromJson(Map<String, dynamic> json) {
    return PrimaryFinanceModel(
      primary: json["primary"] ?? "other",
      detailed: json["detailed"] ?? "other",
    );
  }
}
