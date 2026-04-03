import 'package:pennywise/src/data/datasources/plaid_remote_data_source.dart';
import 'package:pennywise/src/domain/entities/transaction_entity.dart';
import 'package:pennywise/src/domain/repositories/finance_repository.dart';

import '../../domain/entities/account_entity.dart';

class FinanceRepositoryImp implements FinanceRepository {
  final PlaidRemoteDataSource remoteDataSource;

  FinanceRepositoryImp(this.remoteDataSource);

  @override
  Future<String> getLinkToken() => remoteDataSource.createLinkToken();

  @override
  Future<List<TransactionEntity>> getTransactions(String accessToken) async {
    final models = await remoteDataSource.getTransactions(accessToken);
    return models;
  }

  @override
  Future<List<AccountEntity>> getAccounts(String accessToken) async {
    final accounts = await remoteDataSource.getAccounts(accessToken);

    return accounts;
  }

  @override
  Future<String> exchangePublicToken(String publicToken) {
    return remoteDataSource.exchangePublicToken(publicToken);
  }
}
