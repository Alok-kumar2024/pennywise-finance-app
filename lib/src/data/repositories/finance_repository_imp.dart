import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:pennywise/src/data/datasources/local_cache_data_source.dart';
import 'package:pennywise/src/data/datasources/plaid_remote_data_source.dart';
import 'package:pennywise/src/domain/entities/account_entity.dart';
import 'package:pennywise/src/domain/entities/transaction_entity.dart';
import 'package:pennywise/src/domain/repositories/finance_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FinanceRepositoryImp implements FinanceRepository {
  final PlaidRemoteDataSource remoteDataSource;
  final LocalCacheDataSource _localCache;
  final SupabaseClient _supabase;

  FinanceRepositoryImp(this.remoteDataSource, this._localCache, this._supabase);

  // PLAID METHODS...
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

  // SUPABASE MANUAL ACCOUNTS...
  @override
  Future<void> addManualAccount(AccountEntity account) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from("manual_accounts").insert({
      'user_id': userId,
      'name': account.name,
      'balance': account.balance.current,
    });
  }

  @override
  Future<List<AccountEntity>> getManualAccounts() async {
    final userId = _supabase.auth.currentUser!.id;

    final response = await _supabase
        .from('manual_accounts')
        .select()
        .eq('user_id', userId);

    return (response as List)
        .map(
          (row) => AccountEntity(
            accountId: row['id'].toString(),
            name: row['name'],
            officialName: "Manual Cash Wallet",
            mask: "CASH",
            type: "manual",
            subType: "cash",
            balance: BalanceEntity(
              available: double.parse(row['balance'].toString()),
              current: double.parse(row['balance'].toString()),
              isoCurrencyCode: "USD",
              limit: null,
            ),
          ),
        )
        .toList();
  }

  @override
  Future<void> addManualTransaction(TransactionEntity transaction) async {
    final userId = _supabase.auth.currentUser!.id;

    final row = {
      'user_id': userId,
      'account_id': transaction.accountId,
      'amount': transaction.amount,
      'date': transaction.date,
      'name': transaction.name,
      'category': transaction.category.isNotEmpty
          ? transaction.category.first
          : "General",
    };

    try {
      await _supabase.from("manual_transactions").insert(row);
    } catch (e) {
      await _localCache.addToPendingQueue(jsonEncode(row));
    }
  }

  @override
  Future<List<TransactionEntity>> getManualTransactions() async {
    final userId = _supabase.auth.currentUser!.id;
    final response = await _supabase
        .from("manual_transactions")
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);

    return (response as List)
        .map(
          (row) => TransactionEntity(
            transactionId: row['id'].toString(),
            accountId: row['account_id'].toString(),
            amount: double.parse(row['amount'].toString()),
            date: row['date'],
            name: row['name'],
            category: [row['category']],
            pending: false,
            finance: PrimaryFinanceEntity(
              primary: row['category'],
              detailed: "MANUAL",
            ),
          ),
        )
        .toList();
  }

  @override
  Future<void> syncOfflineTransactions() async {
    final queue = await _localCache.getPendingQueue();

    if(queue.isEmpty) return;

    try{
      for(String jsonItem in queue)
        {
          final row = jsonDecode(jsonItem);
          await _supabase.from('manual_transactions').insert(row);
        }

      await _localCache.clearPendingQueue();
    }catch (e)
    {
      debugPrint("Upload failed..");
    }
  }
}
