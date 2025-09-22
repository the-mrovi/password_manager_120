import 'package:flutter/material.dart';
import 'package:password_manager/pages/signin.dart';
import 'package:password_manager/pages/vault.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Authgate extends StatelessWidget {
  const Authgate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: CircularProgressIndicator());
        }
        final session = snapshot.hasData ? snapshot.data!.session : null;
        if (session == null) {
          return Signin();
        } else {
          return VaultPage();
        }
      },
    );
  }
}
