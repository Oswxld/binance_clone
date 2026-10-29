import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/auth/binance_auth_gate.dart';
import 'core/notifications/binance_push_service.dart';
import 'firebase_options.dart';
import 'core/theme/binance_palette.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final url = dotenv.env['SUPABASE_URL']?.trim() ?? '';
  final key = (dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ??
          dotenv.env['SUPABASE_ANON_KEY'] ??
          '').trim();
  if (url.isEmpty || key.isEmpty || key == 'YOUR_PUBLISHABLE_KEY') {
    throw StateError('Add SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY to .env.');
  }
  await Supabase.initialize(url: url, publishableKey: key);
  // Run flutterfire configure --project=mail-demo-push --platforms=android
  // before building. It generates firebase_options.dart and native config.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(binanceBackgroundFcmHandler);
  // Let Android render the real clock, notifications, connectivity, battery,
  // and system navigation. SafeArea keeps Flutter content below/above them.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const ProviderScope(child: BinanceCloneApp()));
}

class BinanceCloneApp extends StatelessWidget {
  const BinanceCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Binance Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: BinancePalette.canvas,
        canvasColor: BinancePalette.canvas,
        cardColor: BinancePalette.surface,
        dividerColor: BinancePalette.divider,
        primaryColor: BinancePalette.yellow,
        colorScheme: const ColorScheme.dark(
          primary: BinancePalette.yellow,
          onPrimary: BinancePalette.canvas,
          surface: BinancePalette.surface,
          onSurface: BinancePalette.textPrimary,
          error: BinancePalette.red,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      scaffoldMessengerKey: binanceScaffoldMessengerKey,
      home: const BinanceAuthGate(),
    );
  }
}
