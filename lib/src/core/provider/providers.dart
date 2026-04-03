import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pennywise/src/data/datasources/plaid_remote_data_source.dart';
import 'package:pennywise/src/data/repositories/finance_repository_imp.dart';
import 'package:pennywise/src/data/repositories/token_repository_imp.dart';

final dioProvider = Provider((ref) => Dio());

final plaidDataSourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return PlaidRemoteDataSource(dio);
});

final financeRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(plaidDataSourceProvider);

  return FinanceRepositoryImp(dataSource);
});

final secureStorageProvider = Provider((ref) {
  return const FlutterSecureStorage();
});

final tokenRepositoryProvider = Provider((ref) {
  final storage = ref.watch(secureStorageProvider);
  return TokenRepositoryImp(storage);
});
