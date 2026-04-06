import 'package:pennywise/src/domain/entities/account_entity.dart';

class AccountModel extends AccountEntity {
  AccountModel({
    required super.accountId,
    required super.balance,
    required super.mask,
    required super.name,
    required super.officialName,
    required super.type,
    required super.subType,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      name: json["name"] ?? "",
      accountId: json["account_id"] ?? "",
      balance: BalanceModel.fromJson(json["balances"] ?? {}),
      mask: json["mask"] ?? "",
      officialName: json["official_name"] ?? "",
      subType: json["subtype"] ?? "",
      type: json["type"] ?? "",
    );
  }
}

class BalanceModel extends BalanceEntity {
  BalanceModel({
    required super.available,
    required super.current,
    required super.isoCurrencyCode,
    required super.limit,
  });

  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    return BalanceModel(
      available: (json["available"] as num?)?.toDouble() ?? 0.0,
      current: (json["current"] as num?)?.toDouble() ?? 0.0,
      isoCurrencyCode: json["iso_currency_code"] ?? "",
      limit: (json["limit"] as num?)?.toDouble(),

    );
  }
}
