import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AstroVibe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: MaterialColor(
          0xFF9C8FD9, // Soft purple
          <int, Color>{
            50: Color(0xFFF3F1F9),
            100: Color(0xFFE7E3F3),
            200: Color(0xFFD0C8E8),
            300: Color(0xFFB9ADDC),
            400: Color(0xFFA79BD1),
            500: Color(0xFF9C8FD9),
            600: Color(0xFF8F82C7),
            700: Color(0xFF7A6DB0),
            800: Color(0xFF655A99),
            900: Color(0xFF504781),
          },
        ),
        scaffoldBackgroundColor: Color(0xFFF8F7FB),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            color: Color(0xFF504781),
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(color: Color(0xFF655A99)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
