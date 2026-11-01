import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/role_provider.dart';
import 'providers/member_provider.dart';
import 'screens/member_list_screen.dart';
import 'providers/dance_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => RoleProvider()),
        ChangeNotifierProvider(create: (_) => DanceProvider()),
      ],
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
