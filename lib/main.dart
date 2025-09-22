import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/homepage.dart';


void main() async {
  await Supabase.initialize(
    url: "https://nqyixqshvtxzdmphnvwv.supabase.co",
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5xeWl4cXNodnR4emRtcGhudnd2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYxODY0MDUsImV4cCI6MjA3MTc2MjQwNX0.b8JvUpE8fgCj2LNLIvIcyRx9wX24SqqkFvz9Nwyq5h4',
    
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Password Manager',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: Homepage(),
    );
  }
}
