import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {

  final SupabaseClient _Supabase = Supabase.instance.client;

  Future<AuthResponse> SignInWithEmailPassword(String email, String password) async {
    return await _Supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  Future<AuthResponse> SignUpWIthEmailPassword(String email,String password,) async{
    return _Supabase.auth.signUp(
    password:  password,
    email: email
    );
  }
  Future<void> SignOut() async {
    await _Supabase.auth.signOut();
  }

  String? getCurrentEmail(){
    final Session = _Supabase.auth.currentSession;
    final user = Session?.user;
    return user?.email;
  }

  String? getCurrentUserId(){
    final user = _Supabase.auth.currentUser;
    return user?.id;
  }
}