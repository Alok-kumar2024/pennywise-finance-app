import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthDataSource {
  final SupabaseClient _supabaseClient;

  SupabaseAuthDataSource(this._supabaseClient);

  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("An unexpected error occurred.");
    }
  }

  Future<void> signUpWithEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': name},
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("An unexpected error occurred.");
    }
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  Stream<bool> get authStateChanges {
    return _supabaseClient.auth.onAuthStateChange.map((event) {
      return event.session != null;
    });
  }

  Future<void> updatePassword(String password) async {
    await _supabaseClient.auth.updateUser(UserAttributes(password: password));
  }

  Future<void> resetPasswordForEmail(String email) async {
    await _supabaseClient.auth.resetPasswordForEmail(email);
  }

  Future<void> signInWithGoogle() async {
    await _supabaseClient.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: "pw://login-callback/",
    );
  }
}
