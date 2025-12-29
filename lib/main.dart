import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/home.dart';
import 'services/premium_service.dart';
import 'services/session_service.dart';
import 'services/notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// =======================
// ROOT APP
// =======================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RainGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const InitPage(), // 🔥 PENTING
    );
  }
}

// =======================
// INIT PAGE (ANTI FORCE CLOSE)
// =======================
class InitPage extends StatefulWidget {
  const InitPage({super.key});

  @override
  State<InitPage> createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      // 🔥 SEMUA INIT BERAT DI SINI (BUKAN DI main)
      await NotificationService.init();
      await SessionService.loadSession();
      await PremiumService.loadPremium();

      if (!mounted) return;

      // 🔥 CEK SESSION
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SessionService.userId == null
              ? LoginPage()
              : HomePage(),
        ),
      );
    } catch (e, s) {
      // 🔥 JIKA ADA ERROR → APP TETAP JALAN
      debugPrint("INIT ERROR: $e");
      debugPrint("$s");

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
