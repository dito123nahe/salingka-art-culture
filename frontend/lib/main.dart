import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/member_provider.dart';
import 'screens/member_list_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => MemberProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salingka Art & Culture',
      theme: ThemeData(colorSchemeSeed: Colors.red, useMaterial3: true),
      home: const MemberListScreen(),
    );
  }
}