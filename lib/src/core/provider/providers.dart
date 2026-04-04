import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pennywise/src/data/datasources/local_cache_data_source.dart';
import 'package:pennywise/src/data/datasources/plaid_remote_data_source.dart';
import 'package:pennywise/src/data/datasources/supabase_auth_data_source.dart';
import 'package:pennywise/src/data/repositories/auth_repository_imp.dart';
import 'package:pennywise/src/data/repositories/finance_repository_imp.dart';
import 'package:pennywise/src/data/repositories/token_repository_imp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final dioProvider = Provider((ref) => Dio());

final plaidDataSourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return PlaidRemoteDataSource(dio);
});

final financeRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(plaidDataSourceProvider);
  final localCache = ref.watch(localCacheProvider);
  final supabase = ref.watch(supabaseClientProvider);

  return FinanceRepositoryImp(dataSource, localCache, supabase);
});

final secureStorageProvider = Provider((ref) {
  return const FlutterSecureStorage();
});

final tokenRepositoryProvider = Provider((ref) {
  final storage = ref.watch(secureStorageProvider);
  return TokenRepositoryImp(storage);
});

final plaidTokenCheckProvider = FutureProvider<bool>((ref) async {
  final tokenRepo = ref.watch(tokenRepositoryProvider);
  final token = await tokenRepo.getAccessToken();

  return token != null && token.isNotEmpty;
});

//Supabase Cliend Provider
final supabaseClientProvider = Provider((ref) {
  return Supabase.instance.client;
});

final supabaseAuthDataSourceProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseAuthDataSource(client);
});

//Login Status track.
final authStateProvider = StreamProvider(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges,
);

final authRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(supabaseAuthDataSourceProvider);
  return AuthRepositoryImp(dataSource);
});

final localCacheProvider = Provider((ref) {
  final storage = ref.watch(secureStorageProvider);

  return LocalCacheDataSource(storage);
});
