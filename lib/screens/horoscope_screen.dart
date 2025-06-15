import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/horoscope_data.dart';
import 'dart:math' as math;

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({super.key});

  @override
  State<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _sparkleController;
  late AnimationController _backgroundController;
  late AnimationController _sectionsController;
  
  late Animation<double> _cardSlideAnimation;
  late Animation<double> _cardFadeAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _sectionsAnimation;
  
  String? userZodiac;
  String? horoscopeText;
  String? financeText;
  String? relationshipText;
  String? healthText;
  bool isLoading = true;
  bool cardRevealed = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _fetchUserHoroscope();
  }

  void _initAnimations() {
    // Card animation
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _cardSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));
    
    _cardFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Sparkle animation
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOutCubic,
    ));

    // Background animation (cosmic swirling)
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    );
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);
    
    _backgroundController.repeat();

    // Sections animation
    _sectionsController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    
    _sectionsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sectionsController,
      curve: Curves.easeOutBack,
    ));
  }

  Future<void> _fetchUserHoroscope() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final zodiac = data?['zodiac'] as String?;
        
        if (zodiac != null) {
          setState(() {
            userZodiac = zodiac;
            horoscopeText = HoroscopeData.getHoroscopeForZodiac(zodiac);
            financeText = HoroscopeData.getFinanceHoroscope(zodiac);
            relationshipText = HoroscopeData.getRelationshipHoroscope(zodiac);
            healthText = HoroscopeData.getHealthHoroscope(zodiac);
          });
        } else {
          throw Exception('Zodiac sign not found in profile');
        }
      } else {
        throw Exception('User profile not found');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading horoscope: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
      
      // Start animations after loading
      if (horoscopeText != null) {
        _revealCard();
      }
    }
  }

  void _revealCard() {
    setState(() {
      cardRevealed = true;
    });
    _cardAnimationController.forward();
    _sparkleController.forward();
    
    // Delay sections animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _sectionsController.forward();
      }
    });
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _sparkleController.dispose();
    _backgroundController.dispose();
    _sectionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print("Floating home button tapped"); // Debug print
          HapticFeedback.mediumImpact();
          
          // Small delay to ensure gesture is processed
          await Future.delayed(const Duration(milliseconds: 50));
          
          // Navigate back to home with proper pop
          try {
            if (mounted) {
              Navigator.pop(context);
            }
          } catch (e) {
            print("FAB Navigation error: $e");
            // Fallback navigation
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
            }
          }
        },
        backgroundColor: Colors.purple.withOpacity(0.9),
        elevation: 8,
        child: const Icon(
          Icons.home,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    const Color(0xFF0F0C29),
                    const Color(0xFF1A1A2E),
                    _backgroundAnimation.value * 0.3,
                  )!,
                  Color.lerp(
                    const Color(0xFF24243e),
                    const Color(0xFF16213E),
                    _backgroundAnimation.value * 0.4,
                  )!,
                  Color.lerp(
                    const Color(0xFF0F3460),
                    const Color(0xFF533A7B),
                    _backgroundAnimation.value * 0.5,
                  )!,
                  Color.lerp(
                    const Color(0xFF533A7B),
                    const Color(0xFF0F0C29),
                    _backgroundAnimation.value * 0.3,
                  )!,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Cosmic swirling background
                _buildCosmicBackground(),
                
                // Main content
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // App Bar
                        _buildAppBar(),
                        
                        const SizedBox(height: 30),
                        
                        if (isLoading)
                          _buildLoadingState()
                        else if (horoscopeText != null) ...[
                          // Main horoscope card
                          _buildMainHoroscopeCard(),
                          
                          const SizedBox(height: 40),
                          
                          // Additional sections
                          _buildAdditionalSections(),
                        ] else
                          _buildErrorState(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCosmicBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: CosmicBackgroundPainter(_backgroundAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Text(
          'Today\'s Horoscope',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.purple.withOpacity(0.5),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              'Consulting the stars...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainHoroscopeCard() {
    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _cardSlideAnimation.value),
          child: Opacity(
            opacity: _cardFadeAnimation.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.1),
                    Colors.purple.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    userZodiac ?? '',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Playfair Display',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    horoscopeText ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.6,
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

  Widget _buildAdditionalSections() {
    return AnimatedBuilder(
      animation: _sectionsAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _sectionsAnimation.value,
          child: Opacity(
            opacity: _sectionsAnimation.value,
            child: Column(
              children: [
                Text(
                  '✨ Your Cosmic Insights ✨',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Playfair Display',
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
                
                // Finance Section
                _buildSectionCard(
                  '💰 Finance',
                  financeText ?? '',
                  Colors.green,
                  Icons.attach_money,
                ),
                
                const SizedBox(height: 20),
                
                // Relationships Section
                _buildSectionCard(
                  '❤️ Relationships',
                  relationshipText ?? '',
                  Colors.pink,
                  Icons.favorite,
                ),
                
                const SizedBox(height: 20),
                
                // Health Section
                _buildSectionCard(
                  '🧠 Health',
                  healthText ?? '',
                  Colors.blue,
                  Icons.health_and_safety,
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard(String title, String content, Color accentColor, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
            accentColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: accentColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Playfair Display',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.1),
            Colors.red.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            SizedBox(height: 20),
            Text(
              'Unable to load your horoscope',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please check your profile settings',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CosmicBackgroundPainter extends CustomPainter {
  final double animationValue;
  
  CosmicBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = math.Random(42); // Fixed seed for consistent pattern
    
    // Draw swirling cosmic fog
    for (int i = 0; i < 8; i++) {
      final centerX = size.width * (0.2 + 0.6 * random.nextDouble());
      final centerY = size.height * (0.2 + 0.6 * random.nextDouble());
      final radius = size.width * (0.15 + 0.2 * random.nextDouble());
      
      final swirl = (animationValue * 2 * math.pi + i) % (2 * math.pi);
      final offsetX = math.cos(swirl) * 30;
      final offsetY = math.sin(swirl) * 30;
      
      paint.shader = RadialGradient(
        colors: [
          Colors.purple.withOpacity(0.1),
          Colors.blue.withOpacity(0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(centerX + offsetX, centerY + offsetY),
        radius: radius,
      ));
      
      canvas.drawCircle(
        Offset(centerX + offsetX, centerY + offsetY),
        radius,
        paint,
      );
    }
    
    // Draw twinkling stars
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final twinkle = (math.sin(animationValue * 3 * math.pi + i) + 1) / 2;
      
      paint.shader = null;
      paint.color = Colors.white.withOpacity(twinkle * 0.6);
      canvas.drawCircle(Offset(x, y), random.nextDouble() * 1.5 + 0.5, paint);
    }
    
    // Draw floating sparkles
    for (int i = 0; i < 20; i++) {
      final progress = (animationValue + i * 0.05) % 1.0;
      final x = size.width * random.nextDouble();
      final y = progress * size.height;
      
      if (progress > 0.1 && progress < 0.9) {
        paint.color = Colors.white.withOpacity((1 - progress) * 0.4);
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 