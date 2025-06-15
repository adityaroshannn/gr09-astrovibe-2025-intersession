import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

class ReviewHoroscopeScreen extends StatefulWidget {
  const ReviewHoroscopeScreen({super.key});

  @override
  State<ReviewHoroscopeScreen> createState() => _ReviewHoroscopeScreenState();
}

class _ReviewHoroscopeScreenState extends State<ReviewHoroscopeScreen>
    with TickerProviderStateMixin {
  late AnimationController _galaxyController;
  late AnimationController _sliderController;
  late AnimationController _confettiController;
  late Animation<double> _galaxyAnimation;
  late Animation<double> _sliderGlowAnimation;
  late Animation<double> _confettiAnimation;
  
  double _rating = 5.0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _alreadyReviewed = false;
  bool _showConfetti = false;
  String? _error;
  String? _todaysHoroscope;
  String? _zodiacSign;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadTodaysHoroscope();
  }

  void _initAnimations() {
    _galaxyController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _galaxyAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_galaxyController);
    _galaxyController.repeat();

    _sliderController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _sliderGlowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _sliderController, curve: Curves.easeInOut),
    );
    _sliderController.repeat(reverse: true);

    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _confettiAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _confettiController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _galaxyController.dispose();
    _sliderController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadTodaysHoroscope() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() {
            _error = 'Please log in to review your horoscope';
            _isLoading = false;
          });
        }
        return;
      }

      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('dailyHoroscopes')
          .doc(todayString)
          .get();

      if (mounted) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          final bool hasReview = data['review'] != null;
          
          setState(() {
            _todaysHoroscope = data['horoscope'];
            _zodiacSign = data['zodiac'];
            _alreadyReviewed = hasReview;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'No horoscope found for today. Please check your daily horoscope first!';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading today\'s horoscope: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to load today\'s horoscope';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitReview() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('dailyHoroscopes')
          .doc(todayString)
          .update({'review': _rating});

      if (mounted) {
        setState(() {
          _showConfetti = true;
          _alreadyReviewed = true;
          _isSubmitting = false;
        });
        
        _confettiController.forward();
        
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      print('Error submitting review: $e');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getRatingColor(double rating) {
    if (rating >= 8) return Colors.green;
    if (rating >= 6) return Colors.amber;
    if (rating >= 4) return Colors.orange;
    return Colors.red;
  }

  String _getRatingEmoji(double rating) {
    if (rating >= 9) return '🤩';
    if (rating >= 7) return '😍';
    if (rating >= 5) return '😊';
    if (rating >= 3) return '😐';
    return '😔';
  }

  String _getZodiacEmoji(String zodiac) {
    const Map<String, String> zodiacEmojis = {
      'Aries': '♈', 'Taurus': '♉', 'Gemini': '♊', 'Cancer': '♋',
      'Leo': '♌', 'Virgo': '♍', 'Libra': '♎', 'Scorpio': '♏',
      'Sagittarius': '♐', 'Capricorn': '♑', 'Aquarius': '♒', 'Pisces': '♓',
    };
    return zodiacEmojis[zodiac] ?? '⭐';
  }

  @override
  Widget build(BuildContext context) {
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
                CustomPaint(
                  painter: StarsPainter(_galaxyAnimation.value),
                  size: Size.infinite,
                ),
                if (_showConfetti)
                  AnimatedBuilder(
                    animation: _confettiAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: ConfettiPainter(_confettiAnimation.value),
                        size: Size.infinite,
                      );
                    },
                  ),
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
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
                                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                                ),
                                child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Review Horoscope',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator(color: Colors.white))
                            : _error != null
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.error_outline, color: Colors.white, size: 64),
                                        const SizedBox(height: 16),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 40),
                                          child: Text(_error!, style: const TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.center),
                                        ),
                                      ],
                                    ),
                                  )
                                : _alreadyReviewed
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.check_circle, color: Colors.green, size: 80),
                                            const SizedBox(height: 20),
                                            const Text('Already Reviewed Today! 🌟', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 12),
                                            Text('Thank you for sharing your feedback!', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
                                          ],
                                        ),
                                      )
                                    : SingleChildScrollView(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Colors.white.withOpacity(0.25), Colors.white.withOpacity(0.1)],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(_getZodiacEmoji(_zodiacSign ?? ''), style: const TextStyle(fontSize: 24)),
                                                      const SizedBox(width: 12),
                                                      const Text('Today\'s Horoscope', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(_todaysHoroscope ?? '', style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 30),
                                            AnimatedBuilder(
                                              animation: _sliderGlowAnimation,
                                              builder: (context, child) {
                                                return Container(
                                                  padding: const EdgeInsets.all(20),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [Colors.white.withOpacity(0.25), Colors.white.withOpacity(0.1)],
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                    ),
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(color: Colors.white.withOpacity(0.4)),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.purple.withOpacity(_sliderGlowAnimation.value * 0.3),
                                                        blurRadius: 20,
                                                        spreadRadius: 5,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        'Rate Today\'s Horoscope',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                          shadows: [Shadow(color: Colors.purple.withOpacity(_sliderGlowAnimation.value), blurRadius: 10)],
                                                        ),
                                                      ),
                                                      const SizedBox(height: 20),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            colors: [_getRatingColor(_rating).withOpacity(0.3), _getRatingColor(_rating).withOpacity(0.1)],
                                                          ),
                                                          borderRadius: BorderRadius.circular(15),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Icon(Icons.star, color: _getRatingColor(_rating), size: 24),
                                                            const SizedBox(width: 8),
                                                            Text(_rating.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                                            const SizedBox(width: 8),
                                                            Text(_getRatingEmoji(_rating), style: const TextStyle(fontSize: 20)),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(height: 20),
                                                      SliderTheme(
                                                        data: SliderTheme.of(context).copyWith(
                                                          activeTrackColor: _getRatingColor(_rating),
                                                          inactiveTrackColor: Colors.white.withOpacity(0.3),
                                                          thumbColor: _getRatingColor(_rating),
                                                          overlayColor: _getRatingColor(_rating).withOpacity(0.3),
                                                          trackHeight: 6,
                                                        ),
                                                        child: Slider(
                                                          value: _rating,
                                                          min: 0,
                                                          max: 10,
                                                          divisions: 100,
                                                          onChanged: (value) => setState(() => _rating = value),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text('Not helpful 😔', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                                                            Text('Amazing! ✨', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 30),
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 300),
                                              width: double.infinity,
                                              height: 56,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: _isSubmitting
                                                      ? [Colors.grey, Colors.grey.shade600]
                                                      : [_getRatingColor(_rating), _getRatingColor(_rating).withOpacity(0.8)],
                                                ),
                                                borderRadius: BorderRadius.circular(28),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: _getRatingColor(_rating).withOpacity(0.4),
                                                    blurRadius: 15,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  borderRadius: BorderRadius.circular(28),
                                                  onTap: _isSubmitting ? null : _submitReview,
                                                  child: Center(
                                                    child: _isSubmitting
                                                        ? const SizedBox(
                                                            width: 24,
                                                            height: 24,
                                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                                          )
                                                        : const Text('Submit Review ✨', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                                  ),
                                                ),
                                              ),
                                            ),
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
}

class StarsPainter extends CustomPainter {
  final double animationValue;
  StarsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final random = math.Random(42);
    
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final opacity = (math.sin(animationValue * 2 * math.pi + i) + 1) / 2;
      
      paint.color = Colors.white.withOpacity(opacity * 0.8);
      canvas.drawCircle(Offset(x, y), random.nextDouble() * 2 + 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ConfettiPainter extends CustomPainter {
  final double animationValue;
  ConfettiPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(123);
    final colors = [Colors.amber, Colors.purple, Colors.blue, Colors.pink, Colors.green];
    
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final startY = -50.0;
      final endY = size.height + 50;
      final y = startY + (endY - startY) * animationValue;
      
      final paint = Paint()
        ..color = colors[i % colors.length].withOpacity(1 - animationValue)
        ..style = PaintingStyle.fill;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(animationValue * 4 * math.pi + i);
      canvas.drawRect(const Rect.fromLTWH(-3, -8, 6, 16), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 