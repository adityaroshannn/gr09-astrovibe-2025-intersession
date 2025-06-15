import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/compatibility_data.dart';
import 'dart:math' as math;

class CompatibilityScreen extends StatefulWidget {
  const CompatibilityScreen({super.key});

  @override
  State<CompatibilityScreen> createState() => _CompatibilityScreenState();
}

class _CompatibilityScreenState extends State<CompatibilityScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _resultController;
  late AnimationController _pulseController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _resultAnimation;
  late Animation<double> _pulseAnimation;

  String _selectedSign1 = '';
  String _selectedSign2 = '';
  Map<String, String>? _compatibilityResult;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Background cosmic animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    );
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_backgroundController);
    _backgroundController.repeat();

    // Result card animation
    _resultController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _resultAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.elasticOut),
    );

    // Button pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _resultController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _checkCompatibility() async {
    if (_selectedSign1.isEmpty || _selectedSign2.isEmpty) {
      _showSnackBar('Please select both zodiac signs! 🌟');
      return;
    }

    HapticFeedback.mediumImpact();
    
    setState(() {
      _showResult = false;
    });

    // Add a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 300));

    final result = CompatibilityData.getCompatibility(_selectedSign1, _selectedSign2);
    
    setState(() {
      _compatibilityResult = result;
      _showResult = true;
    });

    _resultController.forward(from: 0);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.purple.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                
                // Main content
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Custom App Bar
                        _buildAppBar(context),
                        
                        const SizedBox(height: 30),
                        
                        // Title
                        _buildTitle(),
                        
                        const SizedBox(height: 40),
                        
                        // Sign selectors
                        _buildSignSelectors(),
                        
                        const SizedBox(height: 40),
                        
                        // Check compatibility button
                        _buildCheckButton(),
                        
                        const SizedBox(height: 40),
                        
                        // Result card
                        if (_showResult && _compatibilityResult != null)
                          _buildResultCard(),
                        
                        const SizedBox(height: 20),
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
          painter: CosmicCompatibilityPainter(_backgroundAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
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
              '💖 Cosmic Compatibility',
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 24,
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
        
        // Spacer to balance layout
        const SizedBox(width: 45),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          '🌟 Discover Your Cosmic Connection 🌟',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.blue.withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Select two zodiac signs to explore their compatibility',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSignSelectors() {
    return Column(
      children: [
        // First sign selector
        _buildSignSelector(
          title: 'First Sign',
          selectedSign: _selectedSign1,
          onChanged: (sign) {
            setState(() {
              _selectedSign1 = sign;
              _showResult = false;
            });
            HapticFeedback.selectionClick();
          },
        ),
        
        const SizedBox(height: 30),
        
        // Hearts connector
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('💫', style: TextStyle(fontSize: 30)),
            const SizedBox(width: 10),
            Text('💖', style: TextStyle(fontSize: 35)),
            const SizedBox(width: 10),
            Text('💫', style: TextStyle(fontSize: 30)),
          ],
        ),
        
        const SizedBox(height: 30),
        
        // Second sign selector
        _buildSignSelector(
          title: 'Second Sign',
          selectedSign: _selectedSign2,
          onChanged: (sign) {
            setState(() {
              _selectedSign2 = sign;
              _showResult = false;
            });
            HapticFeedback.selectionClick();
          },
        ),
      ],
    );
  }

  Widget _buildSignSelector({
    required String title,
    required String selectedSign,
    required Function(String) onChanged,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.purple.withOpacity(0.5),
                blurRadius: 5,
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedSign.isEmpty ? null : selectedSign,
              hint: Text(
                'Select a zodiac sign',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              dropdownColor: const Color(0xFF2A2A4A),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white.withOpacity(0.8),
              ),
              items: CompatibilityData.zodiacSigns.map((sign) {
                return DropdownMenuItem<String>(
                  value: sign,
                  child: Row(
                    children: [
                      Text(
                        CompatibilityData.getZodiacEmoji(sign),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        sign,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: GestureDetector(
            onTap: _checkCompatibility,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.withOpacity(0.8),
                    Colors.purple.withOpacity(0.9),
                    Colors.pink.withOpacity(0.7),
                    Colors.indigo.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.4),
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
                    '🔮',
                    style: TextStyle(fontSize: 30),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    'Check Compatibility',
                    style: TextStyle(
                      fontSize: 20,
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultCard() {
    final result = _compatibilityResult!;
    final rating = result['rating']!;
    final description = result['description']!;
    
    Color ratingColor;
    if (rating.contains('High')) {
      ratingColor = Colors.red;
    } else if (rating.contains('Medium')) {
      ratingColor = Colors.orange;
    } else {
      ratingColor = Colors.blue;
    }

    return AnimatedBuilder(
      animation: _resultAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _resultAnimation.value,
          child: Opacity(
            opacity: _resultAnimation.value.clamp(0.0, 1.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.1),
                    ratingColor.withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ratingColor.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Signs display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            CompatibilityData.getZodiacEmoji(_selectedSign1),
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _selectedSign1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(width: 30),
                      
                      Text('💖', style: TextStyle(fontSize: 35)),
                      
                      const SizedBox(width: 30),
                      
                      Column(
                        children: [
                          Text(
                            CompatibilityData.getZodiacEmoji(_selectedSign2),
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _selectedSign2,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // Rating
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: ratingColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: ratingColor.withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      rating,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: ratingColor.withOpacity(0.5),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Description
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
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
}

class CosmicCompatibilityPainter extends CustomPainter {
  final double animationValue;
  
  CosmicCompatibilityPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = math.Random(123);
    
    // Draw swirling cosmic fog
    for (int i = 0; i < 8; i++) {
      final centerX = size.width * (0.1 + 0.8 * random.nextDouble());
      final centerY = size.height * (0.1 + 0.8 * random.nextDouble());
      final radius = size.width * (0.08 + 0.12 * random.nextDouble());
      
      final swirl = (animationValue * 2 * math.pi + i * 0.5) % (2 * math.pi);
      final offsetX = math.cos(swirl) * 15;
      final offsetY = math.sin(swirl) * 15;
      
      paint.shader = RadialGradient(
        colors: [
          Colors.pink.withOpacity(0.06),
          Colors.purple.withOpacity(0.04),
          Colors.blue.withOpacity(0.03),
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
      final twinkle = (math.sin(animationValue * 2 * math.pi + i * 0.1) + 1) / 2;
      
      paint.shader = null;
      paint.color = Colors.white.withOpacity(twinkle * 0.6);
      canvas.drawCircle(Offset(x, y), random.nextDouble() * 1.5 + 0.5, paint);
    }
    
    // Draw floating hearts
    for (int i = 0; i < 5; i++) {
      final progress = (animationValue + i * 0.2) % 1.0;
      final x = size.width * (0.1 + 0.8 * random.nextDouble());
      final y = size.height * progress;
      
      if (progress > 0.1 && progress < 0.9) {
        paint.color = Colors.pink.withOpacity((1 - progress) * 0.3);
        _drawHeart(canvas, Offset(x, y), 8.0, paint);
      }
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    
    // Simple heart shape using curves
    path.moveTo(center.dx, center.dy + size * 0.3);
    path.cubicTo(
      center.dx - size * 0.5, center.dy - size * 0.1,
      center.dx - size * 0.5, center.dy - size * 0.5,
      center.dx, center.dy - size * 0.2,
    );
    path.cubicTo(
      center.dx + size * 0.5, center.dy - size * 0.5,
      center.dx + size * 0.5, center.dy - size * 0.1,
      center.dx, center.dy + size * 0.3,
    );
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 