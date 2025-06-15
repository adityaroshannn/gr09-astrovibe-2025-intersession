class ZodiacFlashcard {
  final String name;
  final String emoji;
  final String dateRange;
  final List<String> traits;
  final String compatibility;
  final String element;
  final String rulingPlanet;

  const ZodiacFlashcard({
    required this.name,
    required this.emoji,
    required this.dateRange,
    required this.traits,
    required this.compatibility,
    required this.element,
    required this.rulingPlanet,
  });
}

class ZodiacFlashcardData {
  static const List<ZodiacFlashcard> flashcards = [
    ZodiacFlashcard(
      name: 'Aries',
      emoji: '♈',
      dateRange: 'March 21 – April 19',
      traits: ['Bold', 'Energetic', 'Pioneering', 'Competitive', 'Independent'],
      compatibility: 'Best with Leo, Sagittarius, Gemini',
      element: 'Fire',
      rulingPlanet: 'Mars',
    ),
    ZodiacFlashcard(
      name: 'Taurus',
      emoji: '♉',
      dateRange: 'April 20 – May 20',
      traits: ['Reliable', 'Patient', 'Practical', 'Devoted', 'Stable'],
      compatibility: 'Best with Virgo, Capricorn, Cancer',
      element: 'Earth',
      rulingPlanet: 'Venus',
    ),
    ZodiacFlashcard(
      name: 'Gemini',
      emoji: '♊',
      dateRange: 'May 21 – June 20',
      traits: ['Adaptable', 'Curious', 'Witty', 'Communicative', 'Versatile'],
      compatibility: 'Best with Libra, Aquarius, Aries',
      element: 'Air',
      rulingPlanet: 'Mercury',
    ),
    ZodiacFlashcard(
      name: 'Cancer',
      emoji: '♋',
      dateRange: 'June 21 – July 22',
      traits: ['Nurturing', 'Intuitive', 'Protective', 'Emotional', 'Loyal'],
      compatibility: 'Best with Scorpio, Pisces, Taurus',
      element: 'Water',
      rulingPlanet: 'Moon',
    ),
    ZodiacFlashcard(
      name: 'Leo',
      emoji: '♌',
      dateRange: 'July 23 – August 22',
      traits: ['Confident', 'Generous', 'Creative', 'Dramatic', 'Warm-hearted'],
      compatibility: 'Best with Aries, Sagittarius, Gemini',
      element: 'Fire',
      rulingPlanet: 'Sun',
    ),
    ZodiacFlashcard(
      name: 'Virgo',
      emoji: '♍',
      dateRange: 'August 23 – September 22',
      traits: ['Analytical', 'Practical', 'Helpful', 'Perfectionist', 'Modest'],
      compatibility: 'Best with Taurus, Capricorn, Cancer',
      element: 'Earth',
      rulingPlanet: 'Mercury',
    ),
    ZodiacFlashcard(
      name: 'Libra',
      emoji: '♎',
      dateRange: 'September 23 – October 22',
      traits: ['Diplomatic', 'Charming', 'Balanced', 'Social', 'Artistic'],
      compatibility: 'Best with Gemini, Aquarius, Leo',
      element: 'Air',
      rulingPlanet: 'Venus',
    ),
    ZodiacFlashcard(
      name: 'Scorpio',
      emoji: '♏',
      dateRange: 'October 23 – November 21',
      traits: ['Intense', 'Passionate', 'Mysterious', 'Determined', 'Magnetic'],
      compatibility: 'Best with Cancer, Pisces, Virgo',
      element: 'Water',
      rulingPlanet: 'Pluto',
    ),
    ZodiacFlashcard(
      name: 'Sagittarius',
      emoji: '♐',
      dateRange: 'November 22 – December 21',
      traits: ['Adventurous', 'Optimistic', 'Philosophical', 'Free-spirited', 'Honest'],
      compatibility: 'Best with Aries, Leo, Libra',
      element: 'Fire',
      rulingPlanet: 'Jupiter',
    ),
    ZodiacFlashcard(
      name: 'Capricorn',
      emoji: '♑',
      dateRange: 'December 22 – January 19',
      traits: ['Ambitious', 'Disciplined', 'Responsible', 'Patient', 'Practical'],
      compatibility: 'Best with Taurus, Virgo, Scorpio',
      element: 'Earth',
      rulingPlanet: 'Saturn',
    ),
    ZodiacFlashcard(
      name: 'Aquarius',
      emoji: '♒',
      dateRange: 'January 20 – February 18',
      traits: ['Independent', 'Innovative', 'Humanitarian', 'Eccentric', 'Intellectual'],
      compatibility: 'Best with Gemini, Libra, Sagittarius',
      element: 'Air',
      rulingPlanet: 'Uranus',
    ),
    ZodiacFlashcard(
      name: 'Pisces',
      emoji: '♓',
      dateRange: 'February 19 – March 20',
      traits: ['Compassionate', 'Intuitive', 'Artistic', 'Dreamy', 'Empathetic'],
      compatibility: 'Best with Cancer, Scorpio, Capricorn',
      element: 'Water',
      rulingPlanet: 'Neptune',
    ),
  ];

  static ZodiacFlashcard getFlashcard(int index) {
    if (index >= 0 && index < flashcards.length) {
      return flashcards[index];
    }
    return flashcards[0]; // Default to Aries
  }

  static int get totalCards => flashcards.length;
} 