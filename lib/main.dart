import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/horoscope_screen.dart';
import 'screens/zodiac_flashcards_screen.dart';
import 'screens/compatibility_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize notification service
  await NotificationService().initialize();
  
  // Show horoscope notification on app start (cold start)
  _showAppStartNotification();
  
  runApp(const MyApp());
}

/// Show notification when app starts (cold start)
void _showAppStartNotification() async {
  try {
    // Wait a bit for the app to fully initialize
    await Future.delayed(const Duration(seconds: 3));
    
    // Check if user is already logged in
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is logged in, show the notification
      await NotificationService().showHoroscopeNotification();
    }
  } catch (e) {
    print('⚠️ App start notification failed: $e');
  }
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
      initialRoute: "/",
      routes: {
        "/": (context) => LoginScreen(),
        "/register": (context) => RegisterScreen(),
        "/home": (context) => HomeScreen(),
        "/profile": (context) => ProfileScreen(),
        "/horoscope": (context) => HoroscopeScreen(),
        "/flashcards": (context) => ZodiacFlashcardsScreen(),
        "/compatibility": (context) => CompatibilityScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // If user is logged in, show home screen
        if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen();
        }
        
        // If no user, show login screen
        return LoginScreen();
      },
    );
  }
}

// Simple router for manual navigation
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      default:
        return MaterialPageRoute(builder: (_) => LoginScreen());
    }
  }
}
