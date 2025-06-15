import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

class PreviousHoroscopesScreen extends StatefulWidget {
  const PreviousHoroscopesScreen({super.key});

  @override
  State<PreviousHoroscopesScreen> createState() => _PreviousHoroscopesScreenState();
}

class _PreviousHoroscopesScreenState extends State<PreviousHoroscopesScreen>
    with TickerProviderStateMixin {
  late AnimationController _galaxyController;
  late AnimationController _fadeController;
  late Animation<double> _galaxyAnimation;
  late Animation<double> _fadeAnimation;
  
  List<Map<String, dynamic>> _horoscopes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadHoroscopes();
  }

  void _initAnimations() {
    // Galaxy background animation
    _galaxyController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _galaxyAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_galaxyController);
    _galaxyController.repeat();

    // Fade in animation for cards
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _galaxyController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadHoroscopes() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() {
            _error = 'Please log in to view your horoscope history';
            _isLoading = false;
          });
        }
        return;
      }

      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('dailyHoroscopes')
          .orderBy('date', descending: true)
          .get();

      final List<Map<String, dynamic>> horoscopes = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        horoscopes.add(data);
      }

      if (mounted) {
        setState(() {
          _horoscopes = horoscopes;
          _isLoading = false;
        });
        _fadeController.forward();
      }
    } catch (e) {
      print('Error loading horoscopes: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to load horoscope history';
          _isLoading = false;
        });
      }
    }
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

  Widget _buildHoroscopeCard(Map<String, dynamic> horoscope, int index) {
    final DateTime date = (horoscope['date'] as Timestamp).toDate();
    final String zodiac = horoscope['zodiac'] ?? 'Unknown';
    final String horoscopeText = horoscope['horoscope'] ?? 'No horoscope available';
    final double? review = horoscope['review']?.toDouble();
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _fadeAnimation.value)),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 16,
                top: index == 0 ? 20 : 0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: review != null 
                      ? Colors.amber.withOpacity(0.6)
                      : Colors.white.withOpacity(0.3),
                  width: review != null ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: review != null 
                        ? Colors.amber.withOpacity(0.3)
                        : Colors.purple.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with date and zodiac
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.withOpacity(0.3),
                                Colors.blue.withOpacity(0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            _formatDate(date),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getZodiacEmoji(zodiac),
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          zodiac,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        if (review != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.withOpacity(0.3),
                                  Colors.orange.withOpacity(0.3),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  review.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Horoscope text
                    Text(
                      horoscopeText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    
                    if (review != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.rate_review,
                            color: Colors.amber.withOpacity(0.8),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'You rated this ${_getRatingText(review)}',
                            style: TextStyle(
                              color: Colors.amber.withOpacity(0.9),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getZodiacEmoji(String zodiac) {
    const Map<String, String> zodiacEmojis = {
      'Aries': '♈',
      'Taurus': '♉',
      'Gemini': '♊',
      'Cancer': '♋',
      'Leo': '♌',
      'Virgo': '♍',
      'Libra': '♎',
      'Scorpio': '♏',
      'Sagittarius': '♐',
      'Capricorn': '♑',
      'Aquarius': '♒',
      'Pisces': '♓',
    };
    return zodiacEmojis[zodiac] ?? '⭐';
  }

  String _getRatingText(double rating) {
    if (rating >= 9) return 'amazing! ✨';
    if (rating >= 7) return 'great! 🌟';
    if (rating >= 5) return 'good 👍';
    if (rating >= 3) return 'okay 😐';
    return 'not so great 😔';
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
                // Animated stars background
                _buildAnimatedStars(),
                
                // Main content
                SafeArea(
                  child: Column(
                    children: [
                      // Custom App Bar
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
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Previous Horoscopes',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Content
                      Expanded(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : _error != null
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          color: Colors.white,
                                          size: 64,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          _error!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                                : _horoscopes.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.history,
                                              color: Colors.white,
                                              size: 64,
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'No horoscope history yet',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Check your daily horoscope to start building your cosmic history!',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.8),
                                                fontSize: 14,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: _horoscopes.length,
                                        itemBuilder: (context, index) {
                                          return _buildHoroscopeCard(_horoscopes[index], index);
                                        },
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
    final random = math.Random(42); // Fixed seed for consistent stars
    
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