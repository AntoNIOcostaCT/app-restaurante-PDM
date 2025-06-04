import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/database_helper.dart';
import 'providers/app_state.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/client/client_home.dart';
import 'screens/admin/admin_home.dart';
import 'screens/kitchen/kitchen_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database; // Initialize database
  runApp(const NoWaiterApp());
}

class NoWaiterApp extends StatelessWidget {
  const NoWaiterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp(
        title: 'NoWaiter',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          // CORREÇÃO: backgroundColor foi deprecated, use colorScheme
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            surface: const Color.fromARGB(238, 207, 169, 201),
          ),
          scaffoldBackgroundColor: const Color.fromARGB(238, 207, 169, 201),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/client': (context) => const ClientHome(),
          '/admin': (context) => const AdminHome(),
          '/kitchen': (context) => const KitchenScreen(),
        },
      ),
    );
  }
}