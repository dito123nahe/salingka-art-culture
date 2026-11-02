import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/role_provider.dart';
import 'providers/member_provider.dart';
import 'screens/member_list_screen.dart';
import 'providers/dance_provider.dart';
import 'providers/client_provider.dart';
import 'providers/booking_provider.dart';

import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => RoleProvider()),
        ChangeNotifierProvider(create: (_) => DanceProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
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
