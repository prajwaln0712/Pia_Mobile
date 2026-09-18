import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme.dart';
import 'screens/about_screen.dart';

// ---------------------------------------------------------------------------
// TEMPORARY: shipping the About screen only.
//
// Nothing else has been deleted. main.dart was the only file importing
// splash_screen, and the rest of the app hangs off it in one chain
// (splash -> chat -> emergency / menu_sheet / services), so cutting this single
// import detaches the whole tree and keeps it out of the build.
//
// To restore the full app: uncomment the import below, then swap the two
// `home:` lines in CreatingWingsApp.
// ---------------------------------------------------------------------------
// import 'screens/splash_screen.dart';

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
      home: const AboutScreen(),
      // home: const SplashScreen(), // full app: disclaimer, then chat
    );
  }
}
