import 'package:pennywise/src/domain/entities/account_entity.dart';
import 'package:pennywise/src/domain/entities/transaction_entity.dart';

abstract class FinanceRepository {
  Future<String> getLinkToken();

  Future<List<TransactionEntity>> getTransactions(String accessToken);

  Future<List<AccountEntity>> getAccounts(String accessToken);

  Future<String> exchangePublicToken(String publicToken);

  // OFFLINE ENDPOINTS...

  Future<void> addManualTransaction(TransactionEntity transaction);

  Future<List<TransactionEntity>> getManualTransactions();

  Future<void> syncOfflineTransactions();

  Future<void> addManualAccount(AccountEntity account);

  Future<List<AccountEntity>> getManualAccounts();
}
