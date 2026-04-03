// "transactions": [
// {
// "account_id": "vye73vba...",
// "amount": 12.00,               // POSITIVE = Expense (Money out)
// "category": ["Food and Drink", "Restaurants"],
// "date": "2026-04-01",
// "name": "Starbucks",           // The Merchant Name
// "pending": false,
// "transaction_id": "l98v7d...",
// "personal_finance_category": { // Use this for your "Insights" screen!
// "primary": "FOOD_AND_DRINK",
// "detailed": "FOOD_AND_DRINK_COFFEE_SHOP"
// }
// }

class TransactionEntity {
  final String accountId;
  final double amount;
  final String date;
  final String name;
  final List<String> category;
  final bool pending;
  final String transactionId;
  final PrimaryFinanceEntity finance;

  TransactionEntity({
    required this.accountId,
    required this.amount,
    required this.date,
    required this.name,
    required this.category,
    required this.pending,
    required this.transactionId,
    required this.finance,
  });
}

class PrimaryFinanceEntity {
  final String primary;
  final String detailed;

  PrimaryFinanceEntity({
    required this.primary,
    required this.detailed
  });
}
