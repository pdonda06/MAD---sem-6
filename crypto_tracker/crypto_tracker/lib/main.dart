import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:crypto_tracker/providers/crypto_provider.dart';
import 'package:crypto_tracker/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CryptoProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Crypto Tracker',
      theme: ThemeData(
        useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0D111C),
          primaryColor: const Color(0xFF2196F3),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF2196F3),
            secondary: Color(0xFF64B5F6),
            background: Color(0xFF0D111C),
            surface: Color(0xFF1A1F2C),
          ),
          textTheme: GoogleFonts.interTextTheme(
            ThemeData.dark().textTheme,
          ),
          cardTheme: CardTheme(
            color: const Color(0xFF1A1F2C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
