import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/zodiac_flashcard_data.dart';
import 'dart:math' as math;

class ZodiacFlashcardsScreen extends StatefulWidget {
  const ZodiacFlashcardsScreen({super.key});

  @override
  State<ZodiacFlashcardsScreen> createState() => _ZodiacFlashcardsScreenState();
}

class _ZodiacFlashcardsScreenState extends State<ZodiacFlashcardsScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _flipController;
  late AnimationController _sparkleController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _flipAnimation;
  late Animation<double> _sparkleAnimation;

  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Background cosmic animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_backgroundController);
    _backgroundController.repeat();

    // Card flip animation
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    // Sparkle animation for flip effect
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _flipController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  void _flipCard() async {
    if (_isAnimating) return;
    
    setState(() {
      _isAnimating = true;
    });

    HapticFeedback.lightImpact();
    _sparkleController.forward(from: 0);

    if (_isFlipped) {
      await _flipController.reverse();
    } else {
      await _flipController.forward();
    }

    setState(() {
      _isFlipped = !_isFlipped;
      _isAnimating = false;
    });
  }

  void _nextCard() {
    if (_isAnimating) return;
    
    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = (_currentIndex + 1) % ZodiacFlashcardData.totalCards;
      _isFlipped = false;
    });
    _flipController.reset();
  }

  void _previousCard() {
    if (_isAnimating) return;
    
    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = (_currentIndex - 1 + ZodiacFlashcardData.totalCards) % ZodiacFlashcardData.totalCards;
      _isFlipped = false;
    });
    _flipController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = ZodiacFlashcardData.getFlashcard(_currentIndex);
    
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(const Color(0xFF0F0C29), const Color(0xFF1A1A2E), _backgroundAnimation.value * 0.3)!,
                  Color.lerp(const Color(0xFF24243e), const Color(0xFF16213E), _backgroundAnimation.value * 0.4)!,
                  Color.lerp(const Color(0xFF0F3460), const Color(0xFF533A7B), _backgroundAnimation.value * 0.5)!,
                  Color.lerp(const Color(0xFF533A7B), const Color(0xFF0F0C29), _backgroundAnimation.value * 0.3)!,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Cosmic background
                _buildCosmicBackground(),
                
                // Sparkle overlay
                AnimatedBuilder(
                  animation: _sparkleAnimation,
                  builder: (context, child) {
                    return _sparkleAnimation.value > 0
                        ? CustomPaint(
                            painter: SparklePainter(_sparkleAnimation.value),
                            size: Size.infinite,
                          )
                        : const SizedBox.shrink();
                  },
                ),
                
                // Main content
                SafeArea(
                  child: Column(
                    children: [
                      // Custom App Bar with back button
                      _buildAppBarWithBackButton(context),
                      
                      // Card counter
                      _buildCardCounter(),
                      
                      // Main flashcard
                      Expanded(
                        child: Center(
                          child: _buildFlashcard(currentCard),
                        ),
                      ),
                      
                      // Navigation controls
                      _buildNavigationControls(),
                      
                      const SizedBox(height: 20),
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

  Widget _buildCosmicBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: CosmicFlashcardPainter(_backgroundAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildAppBarWithBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
            },
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
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
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          
          // Centered title
          Expanded(
            child: Center(
              child: Text(
                '🃏 Zodiac Cards',
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
          ),
          
          // Spacer to balance the layout
          const SizedBox(width: 45),
        ],
      ),
    );
  }

  Widget _buildCardCounter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            child: Text(
              '${_currentIndex + 1} / ${ZodiacFlashcardData.totalCards}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcard(ZodiacFlashcard card) {
    return GestureDetector(
      onTap: _flipCard,
      child: Container(
        width: 320,
        height: 450,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            final isShowingFront = _flipAnimation.value < 0.5;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_flipAnimation.value * math.pi),
              child: isShowingFront
                  ? _buildCardFront(card)
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: _buildCardBack(card),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardFront(ZodiacFlashcard card) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.1),
            Colors.purple.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
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
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              card.emoji,
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 20),
            Text(
              card.name,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Playfair Display',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              card.dateRange,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: Text(
                '${card.element} • ${card.rulingPlanet}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Tap to learn more',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(ZodiacFlashcard card) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.1),
            Colors.indigo.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.purple.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '✨ Traits ✨',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Playfair Display',
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: card.traits.map((trait) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  trait,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 30),
            Text(
              '💕 Compatibility',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Playfair Display',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: Text(
                card.compatibility,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Tap to flip back',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavButton(
            icon: Icons.arrow_back_ios,
            onTap: _previousCard,
          ),
          Expanded(
            child: Center(
              child: Text(
                'Swipe or tap arrows',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          _buildNavButton(
            icon: Icons.arrow_forward_ios,
            onTap: _nextCard,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.1),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

class CosmicFlashcardPainter extends CustomPainter {
  final double animationValue;
  
  CosmicFlashcardPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = math.Random(42);
    
    // Draw swirling cosmic fog
    for (int i = 0; i < 6; i++) {
      final centerX = size.width * (0.2 + 0.6 * random.nextDouble());
      final centerY = size.height * (0.2 + 0.6 * random.nextDouble());
      final radius = size.width * (0.1 + 0.15 * random.nextDouble());
      
      final swirl = (animationValue * 2 * math.pi + i) % (2 * math.pi);
      final offsetX = math.cos(swirl) * 20;
      final offsetY = math.sin(swirl) * 20;
      
      paint.shader = RadialGradient(
        colors: [
          Colors.purple.withOpacity(0.08),
          Colors.blue.withOpacity(0.04),
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
    for (int i = 0; i < 80; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final twinkle = (math.sin(animationValue * 2 * math.pi + i) + 1) / 2;
      
      paint.shader = null;
      paint.color = Colors.white.withOpacity(twinkle * 0.5);
      canvas.drawCircle(Offset(x, y), random.nextDouble() * 1.5 + 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SparklePainter extends CustomPainter {
  final double animationValue;
  
  SparklePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (animationValue == 0.0) return;
    
    final paint = Paint()
      ..color = Colors.white.withOpacity(animationValue * 0.8)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw sparkles around the center
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30.0) * (math.pi / 180);
      final distance = 100.0 + (animationValue * 80.0);
      final x = center.dx + distance * math.cos(angle) * (1 - animationValue);
      final y = center.dy + distance * math.sin(angle) * (1 - animationValue);
      
      final sparkleOpacity = (1.0 - animationValue).clamp(0.0, 1.0);
      paint.color = Colors.white.withOpacity(sparkleOpacity * 0.8);
      
      // Draw sparkle as a small star
      _drawStar(canvas, Offset(x, y), 4.0 * (1 - animationValue), paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45.0) * (math.pi / 180);
      final distance = i % 2 == 0 ? size : size / 2;
      final x = center.dx + distance * math.cos(angle);
      final y = center.dy + distance * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 