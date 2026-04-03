import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {

  static String get clientID => dotenv.env["PLAID_CLIENT_ID"] ?? "";
  static String get secret => dotenv.env["PLAID_SECRET"] ?? "";
  static const String baseUrl = "https://sandbox.plaid.com";
}
