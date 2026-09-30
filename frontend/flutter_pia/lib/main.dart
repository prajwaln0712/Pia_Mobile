import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  // Must complete before any widget reads dotenv.env — AuthService resolves
  // its Auth0 domain and client ID at construction time.
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const CreatingWingsApp());
}

class CreatingWingsApp extends StatelessWidget {
  const CreatingWingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CreatingWings',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const SplashScreen(), // disclaimer, then chat
    );
  }
}
