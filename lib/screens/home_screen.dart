import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _galaxyController;
  late AnimationController _titleController;
  late AnimationController _buttonController;
  late Animation<double> _galaxyAnimation;
  late Animation<double> _titleGlowAnimation;
  late Animation<double> _buttonPulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _setupNotifications();
  }

  void _setupNotifications() async {
    // Setup daily horoscope notifications after a short delay
    // This ensures the user is fully logged in and the screen is loaded
    await Future.delayed(const Duration(seconds: 2));
    NotificationService().setupDailyHoroscope();
  }

  void _initAnimations() {
    // Galaxy background animation
    _galaxyController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _galaxyAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_galaxyController);
    _galaxyController.repeat();

    // Title glow animation
    _titleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _titleGlowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeInOut),
    );
    _titleController.repeat(reverse: true);

    // Button pulse animation
    _buttonController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _buttonPulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
    _buttonController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _galaxyController.dispose();
    _titleController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    // Check if user is authenticated
    if (user == null) {
      // Show error message and redirect to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to access the home screen'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
      });
      
      // Show loading while redirecting
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      body: AnimatedBuilder(
        animation: _galaxyAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(const Color(0xFF0F0C29), const Color(0xFF1A1A2E), _galaxyAnimation.value * 0.5)!,
                  Color.lerp(const Color(0xFF24243e), const Color(0xFF16213E), _galaxyAnimation.value * 0.3)!,
                  Color.lerp(const Color(0xFF0F3460), const Color(0xFF533A7B), _galaxyAnimation.value * 0.4)!,
                  Color.lerp(const Color(0xFF533A7B), const Color(0xFF0F0C29), _galaxyAnimation.value * 0.6)!,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Animated stars background
                _buildAnimatedStars(),
                
                // Main content
                SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      // Custom App Bar with glowing title
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              // Glowing animated title
                              AnimatedBuilder(
                                animation: _titleGlowAnimation,
                                builder: (context, child) {
                                  return ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [
                                        Colors.purple.withOpacity(_titleGlowAnimation.value),
                                        Colors.blue.withOpacity(_titleGlowAnimation.value),
                                        Colors.pink.withOpacity(_titleGlowAnimation.value),
                                      ],
                                    ).createShader(bounds),
                                    child: Text(
                                      'AstroVibe',
                                      style: TextStyle(
                                        fontFamily: 'Playfair Display',
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.purple.withOpacity(_titleGlowAnimation.value),
                                            offset: const Offset(0, 0),
                                            blurRadius: 20,
                                          ),
                                          Shadow(
                                            color: Colors.blue.withOpacity(_titleGlowAnimation.value * 0.8),
                                            offset: const Offset(0, 0),
                                            blurRadius: 30,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/profile'),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.25),
                                        Colors.white.withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.purple.withOpacity(0.3),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.person_outline,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Main Content
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              
                              // Welcome Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(28),
                                margin: const EdgeInsets.only(bottom: 50),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.15),
                                      Colors.white.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.purple.withOpacity(0.2),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '✨ Welcome back, Cosmic Explorer! ✨',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'Playfair Display',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'The universe has aligned to bring you cosmic wisdom today',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                      
                              // Prominent Cosmic Horoscope Button
                              _buildCosmicHoroscopeButton(context),
                              
                              const SizedBox(height: 30),
                              
                              // Zodiac Flashcards Button
                              _buildFlashcardsButton(context),
                              
                              const SizedBox(height: 60),
                      
                              Text(
                                '🌟 Your Cosmic Journey 🌟',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.purple.withOpacity(0.5),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 30),
                              
                              // Active Features Grid (simplified)
                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                childAspectRatio: 1.1,
                                children: [
                                  _buildFeatureCard(
                                    context,
                                    'Daily Horoscope',
                                    Icons.auto_awesome,
                                    '/horoscope',
                                    isActive: true,
                                  ),
                                  _buildFeatureCard(
                                    context,
                                    'Zodiac Cards',
                                    Icons.style,
                                    '/flashcards',
                                    isActive: true,
                                  ),
                                  _buildFeatureCard(
                                    context,
                                    'Birth Chart',
                                    Icons.auto_graph,
                                    null,
                                    isActive: false,
                                  ),
                                  _buildFeatureCard(
                                    context,
                                    'Compatibility',
                                    Icons.favorite,
                                    '/compatibility',
                                    isActive: true,
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedStars() {
    return AnimatedBuilder(
      animation: _galaxyAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: StarsPainter(_galaxyAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildCosmicHoroscopeButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _buttonPulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonPulseAnimation.value,
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/horoscope'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.withOpacity(0.8),
                    Colors.blue.withOpacity(0.6),
                    Colors.pink.withOpacity(0.7),
                    Colors.indigo.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.6),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.3),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '🔮',
                    style: TextStyle(fontSize: 50),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'View Today\'s Horoscope',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Playfair Display',
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Discover what the stars have in store for you',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFlashcardsButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/flashcards'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.withOpacity(0.7),
              Colors.deepPurple.withOpacity(0.6),
              Colors.purple.withOpacity(0.8),
              Colors.blue.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.4),
              blurRadius: 25,
              spreadRadius: 3,
            ),
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🃏',
              style: TextStyle(fontSize: 40),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                                         'Zodiac Cards',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Playfair Display',
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                                         'Learn about zodiac signs with interactive cards',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon, String? route, {required bool isActive}) {
    return GestureDetector(
      onTap: isActive && route != null ? () => Navigator.pushNamed(context, route) : null,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isActive 
              ? [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ]
              : [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive 
              ? Colors.white.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          ),
          boxShadow: isActive 
            ? [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: isActive 
                ? Colors.white
                : Colors.white.withOpacity(0.4),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isActive 
                  ? Colors.white
                  : Colors.white.withOpacity(0.4),
              ),
              textAlign: TextAlign.center,
            ),
            if (!isActive) ...[
              const SizedBox(height: 8),
              Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.3),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StarsPainter extends CustomPainter {
  final double animationValue;
  
  StarsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = math.Random(42); // Fixed seed for consistent stars
    
    // Draw twinkling stars
    for (int i = 0; i < 150; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final opacity = (math.sin(animationValue * 2 * math.pi + i) + 1) / 2;
      
      paint.color = Colors.white.withOpacity(opacity * 0.8);
      canvas.drawCircle(Offset(x, y), random.nextDouble() * 2 + 1, paint);
    }
    
    // Draw shooting stars
    for (int i = 0; i < 3; i++) {
      final progress = (animationValue + i * 0.3) % 1.0;
      final x = progress * size.width * 1.2 - size.width * 0.1;
      final y = size.height * 0.2 + i * size.height * 0.3;
      
      if (progress > 0.1 && progress < 0.9) {
        paint.color = Colors.white.withOpacity((1 - progress) * 0.8);
        canvas.drawCircle(Offset(x, y), 3, paint);
        
        // Tail
        final gradient = LinearGradient(
          colors: [
            Colors.white.withOpacity((1 - progress) * 0.6),
            Colors.transparent,
          ],
        );
        paint.shader = gradient.createShader(Rect.fromLTWH(x - 30, y - 2, 30, 4));
        canvas.drawRect(Rect.fromLTWH(x - 30, y - 2, 30, 4), paint);
        paint.shader = null;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 