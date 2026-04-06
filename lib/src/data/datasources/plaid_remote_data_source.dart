import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:pennywise/src/core/constants/api_constants.dart';
import 'package:pennywise/src/data/models/account_model.dart';
import 'package:pennywise/src/data/models/transaction_model.dart';

class PlaidRemoteDataSource {
  final Dio _dio;

  PlaidRemoteDataSource(this._dio);

  Future<String> createLinkToken() async {
    try {
      final response = await _dio.post(
        "${ApiConstants.baseUrl}/link/token/create",
        data: {
          'client_id': ApiConstants.clientID,
          'secret': ApiConstants.secret,
          'client_name': 'PennyWise',
          'products': ['transactions'],
          'country_codes': ['US'],
          'language': 'en',
          'user': {'client_user_id': 'unique_user_id_0588'},
        },
      );

      return response.data["link_token"];
    } catch (e) {
      throw Exception("Plaid Link Token Creation Failed: $e");
    }
  }

  Future<List<TransactionModel>> getTransactions(String accessToken) async {
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      final response = await _dio.post(
        '${ApiConstants.baseUrl}/transactions/get',
        data: {
          'client_id': ApiConstants.clientID,
          'secret': ApiConstants.secret,
          'access_token': accessToken,
          'start_date': thirtyDaysAgo.toIso8601String().substring(0, 10),
          'end_date': now.toIso8601String().substring(0, 10),
        },
      );

      final List rawTransactions = response.data['transactions'];

      if (rawTransactions.isNotEmpty) {
        debugPrint("🚨 PLAID RAW JSON SAMPLE: ${rawTransactions.first}");
      }

      return rawTransactions
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception("Plaid Transaction Fetch Failed: $e");
    }
  }

  Future<List<AccountModel>> getAccounts(String accesstoken) async {
    try {
      final response = await _dio.post(
        "${ApiConstants.baseUrl}/accounts/get",
        data: {
          'client_id': ApiConstants.clientID,
          'secret': ApiConstants.secret,
          'access_token': accesstoken,
        },
      );

      final List rawAccounts = response.data['accounts'];
      return rawAccounts.map((json) => AccountModel.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint("🚨 PLAID DIO ERROR: ${e.response?.data}");
      throw Exception("Plaid Account Fetch Failed: $e");
    } catch (e) {
      debugPrint("🚨 PLAID CRASH ERROR: $e");
      throw Exception("Plaid Account Fetch Failed: $e");
    }
  }

  Future<String> exchangePublicToken(String publicToken) async {
    try {
      final response = await _dio.post(
        "${ApiConstants.baseUrl}/item/public_token/exchange",
        data: {
          'client_id': ApiConstants.clientID,
          'secret': ApiConstants.secret,
          'public_token': publicToken,
        },
      );

      return response.data["access_token"];
    } catch (e) {
      throw Exception("Plaid Token Exchange Failed: $e");
    }
  }
}
