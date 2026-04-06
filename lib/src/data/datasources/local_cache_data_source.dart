import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalCacheDataSource {
  final FlutterSecureStorage _storage;

  LocalCacheDataSource(this._storage);

  Future<String?> getCachedData(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> cacheData(String key, String jsonData) async {
    await _storage.write(key: key, value: jsonData);
  }

  // -- OFFLINE SYNC --
  // Add a Transaction to waitList if no internet...
  Future<void> addToPendingQueue(String transactionJson) async {
    final existingQueueStr = await _storage.read(key: "pending_transactions");

    List<String> queue = [];

    if (existingQueueStr != null) {
      queue = List<String>.from(json.decode(existingQueueStr));
    }

    queue.add(transactionJson);

    await _storage.write(
      key: "pending_transactions",
      value: json.encode(queue),
    );
  }

  Future<List<String>> getPendingQueue() async {
    final existingQueue = await _storage.read(key: "pending_transactions");

    if (existingQueue != null) {
      return List<String>.from(json.decode(existingQueue));
    }

    return [];
  }

  Future<void> clearPendingQueue() async {
    await _storage.delete(key: "pending_transactions");
  }


  Future<void> clearUserCache() async {
    await _storage.delete(key: "offline_tx");
    await _storage.delete(key: "offline_accounts");
    await _storage.delete(key: "pending_transactions");
  }


}
