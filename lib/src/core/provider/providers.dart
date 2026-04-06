import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pennywise/src/data/datasources/local_cache_data_source.dart';
import 'package:pennywise/src/data/datasources/plaid_remote_data_source.dart';
import 'package:pennywise/src/data/datasources/supabase_auth_data_source.dart';
import 'package:pennywise/src/data/repositories/auth_repository_imp.dart';
import 'package:pennywise/src/data/repositories/finance_repository_imp.dart';
import 'package:pennywise/src/data/repositories/token_repository_imp.dart';
import 'package:pennywise/src/domain/entities/account_entity.dart';
import 'package:pennywise/src/domain/entities/transaction_entity.dart';
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
  final supabase = ref.watch(supabaseClientProvider);
  return TokenRepositoryImp(storage,supabase);
});

final plaidTokenCheckProvider = FutureProvider<bool>((ref) async {

  ref.watch(authStateProvider);

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

final accountsProvider = FutureProvider((ref) async {
  final authState = ref.watch(authStateProvider);

  if (authState.value == false ||
      Supabase.instance.client.auth.currentUser == null) {
    return <AccountEntity>[];
  }

  final repo = ref.watch(financeRepositoryProvider);

  final currentUser = Supabase.instance.client.auth.currentUser;
  debugPrint(
    "🔍 [DEBUG] accountsProvider fetching for User: ${currentUser?.email} (${currentUser?.id})",
  );

  final tokenCheck = await ref.read(plaidTokenCheckProvider.future);

  List<AccountEntity> allAccounts = [];

  if (tokenCheck) {
    try {
      final tokenRepo = ref.read(tokenRepositoryProvider);
      final accessToken = await tokenRepo.getAccessToken();
      final plaidAccounts = await repo.getAccounts(accessToken!);
      allAccounts.addAll(plaidAccounts);
    } catch (e) {
      debugPrint("Could not fetch plaid accounts: $e");
    }
  }

  // Fetch manual accounts...
  try {
    final manualAccounts = await repo.getManualAccounts();
    allAccounts.addAll(manualAccounts);
  } catch (e) {
    debugPrint("Could not fetch manual accounts: $e");
  }

  return allAccounts;
});

final transactionProvider = FutureProvider((ref) async {

  final authState = ref.watch(authStateProvider);
  if (authState.value == false ||
      Supabase.instance.client.auth.currentUser == null) {
    return <TransactionEntity>[];
  }

  final repo = ref.watch(financeRepositoryProvider);
  final tokenCheck = await ref.read(plaidTokenCheckProvider.future);

  repo.syncOfflineTransactions();

  List<TransactionEntity> allTransactions = [];

  if (tokenCheck) {
    //Fetch plaid Transactions..
    try {
      final tokenRepo = ref.read(tokenRepositoryProvider);
      final accessToken = await tokenRepo.getAccessToken();
      final plaidTx = await repo.getTransactions(accessToken!);
      allTransactions.addAll(plaidTx);
    } catch (e) {
      debugPrint("Could not fetch Plaid transactions: $e");
    }
  }

  //Fetch Manual Transactions..
  try {
    final manualTx = await repo.getManualTransactions();
    allTransactions.addAll(manualTx);
  } catch (e) {
    debugPrint("Could not fetch manual transactions: $e");
  }

  allTransactions.sort((a, b) => b.date.compareTo(a.date));

  return allTransactions;
});

final plaidSkippedProvider = FutureProvider<bool>((ref) async {
  final tokenRepo = ref.watch(tokenRepositoryProvider);
  return await tokenRepo.hasSkippedPlaid();
});

final goalsProvider = FutureProvider((ref) async {
  final repo = ref.watch(financeRepositoryProvider);
  return await repo.getGoals();
});
