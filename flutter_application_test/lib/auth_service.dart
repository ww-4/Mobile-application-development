import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // Регистрация через Supabase Auth
  static Future<AuthResponse> signUp(String email, String password) async {
    return await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Вход через Supabase Auth
  static Future<AuthResponse> signIn(String email, String password) async {
    return await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Выход
  static Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  // Проверка текущего пользователя
  static User? getCurrentUser() {
    return Supabase.instance.client.auth.currentUser;
  }
}

