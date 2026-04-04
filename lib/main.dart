import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pennywise/src/core/constants/api_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Load secrets before the app starts..
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("Dotenv loaded successfully");

    await Supabase.initialize(
      url: ApiConstants.supabaseUrl,
      anonKey: ApiConstants.supabaseAnonKey,
    );
  } catch (e) {
    debugPrint("Error loading dotenv: $e");
    // You can decide to provide fallback values here
  }
  runApp(
    //Enables RiverPod for the whole App...
    ProviderScope(child: MyApp()),
  );
}
