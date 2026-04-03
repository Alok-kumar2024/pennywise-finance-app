// {
// "account_id": "vye73vba...",
// "balances": {
// "available": 100.00,   // This is what the user CAN spend
// "current": 110.00,     // Total in account (including pending)
// "iso_currency_code": "USD",
// "limit": null
// },
// "mask": "0000",
// "name": "Plaid Checking",
// "official_name": "Plaid Gold Standard 0 Checking",
// "type": "depository",
// "subtype": "checking"
// }

class AccountEntity {
  final String accountId;
  final BalanceEntity balance;
  final String mask;
  final String name;
  final String officialName;
  final String type;
  final String subType;

  AccountEntity({
    required this.accountId,
    required this.balance,
    required this.mask,
    required this.name,
    required this.officialName,
    required this.type,
    required this.subType,
  });
}

class BalanceEntity {
  final double available;
  final double current;
  final String isoCurrencyCode;
  final double? limit;

  BalanceEntity({
    required this.available,
    required this.current,
    required this.isoCurrencyCode,
    required this.limit,
  });
}
