import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/home/presentation/home_screen.dart';

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
  // The supplied design includes its own status indicators and home bar.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF181A20),
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF181A20),
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
        scaffoldBackgroundColor: const Color(0xFF181A20),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
