import 'package:pennywise/src/domain/entities/account_entity.dart';
import 'package:pennywise/src/domain/entities/transaction_entity.dart';

abstract class FinanceRepository {

  Future<String> getLinkToken();
  Future<List<TransactionEntity>> getTransactions(String accessToken);
  Future<List<AccountEntity>> getAccounts(String accessToken);

}