class HoroscopeData {
  static const Map<String, String> dailyHoroscopes = {
    'Aries ♈': 'Today brings fiery energy and new opportunities, Aries! Your natural leadership will shine as you tackle challenges head-on. A chance encounter could spark something meaningful. Trust your instincts and take that bold step forward.',
    
    'Taurus ♉': 'Steady progress leads to lasting rewards, dear Taurus. Your patience and determination are your greatest assets today. Focus on building something beautiful and enduring. A financial opportunity may present itself.',
    
    'Gemini ♊': 'Communication is your superpower today, Gemini! Your wit and charm will open doors and create connections. Multiple opportunities may arise - trust your adaptability to handle them all with grace.',
    
    'Cancer ♋': 'Your intuition is especially strong today, Cancer. Trust those emotional insights and nurture the relationships that matter most. Home and family bring comfort and joy. A heartfelt conversation could heal old wounds.',
    
    'Leo ♌': 'The spotlight is calling your name, magnificent Leo! Your creativity and confidence will inspire others today. Share your talents with the world - recognition and appreciation are coming your way.',
    
    'Virgo ♍': 'Attention to detail pays off beautifully today, Virgo. Your practical approach and helpful nature will solve problems others can\'t. Organization brings clarity, and a small gesture makes a big impact.',
    
    'Libra ♎': 'Balance and harmony guide your path today, lovely Libra. Your diplomatic skills help resolve conflicts and bring people together. Beauty surrounds you - take time to appreciate art, music, or nature.',
    
    'Scorpio ♏': 'Your intense focus and determination unlock secrets today, Scorpio. Trust your investigative instincts and dig deeper into what truly matters. Transformation and renewal are on the horizon.',
    
    'Sagittarius ♐': 'Adventure calls to your free spirit today, Sagittarius! Your optimism and philosophical outlook inspire those around you. Learning something new or planning a journey feeds your soul.',
    
    'Capricorn ♑': 'Your ambitious nature and disciplined approach create solid foundations today, Capricorn. Hard work begins to show tangible results. Authority figures take notice of your reliability and skill.',
    
    'Aquarius ♒': 'Innovation and originality set you apart today, Aquarius! Your unique perspective offers solutions others haven\'t considered. Community and friendship bring unexpected benefits.',
    
    'Pisces ♓': 'Your compassionate heart and creative spirit flow beautifully today, Pisces. Artistic endeavors flourish, and helping others brings deep satisfaction. Trust your dreams - they hold important messages.',
  };

  // Finance horoscopes
  static const Map<String, String> financeHoroscopes = {
    'Aries ♈': 'Bold financial decisions pay off today. Trust your instincts with investments.',
    'Taurus ♉': 'Steady savings and practical spending bring financial security your way.',
    'Gemini ♊': 'Multiple income streams or financial opportunities present themselves.',
    'Cancer ♋': 'Family finances or home investments show promising returns.',
    'Leo ♌': 'Your generous nature attracts abundance. Luxury purchases feel justified.',
    'Virgo ♍': 'Careful budgeting and attention to detail improve your financial health.',
    'Libra ♎': 'Balanced spending and smart partnerships enhance your wealth.',
    'Scorpio ♏': 'Hidden financial opportunities or investments reveal their potential.',
    'Sagittarius ♐': 'International markets or travel-related expenses bring good fortune.',
    'Capricorn ♑': 'Long-term investments and career advancement boost your income.',
    'Aquarius ♒': 'Innovative financial strategies or tech investments show promise.',
    'Pisces ♓': 'Intuitive financial decisions and charitable giving bring unexpected returns.',
  };

  // Relationship horoscopes
  static const Map<String, String> relationshipHoroscopes = {
    'Aries ♈': 'Passionate connections ignite. Take the lead in matters of the heart.',
    'Taurus ♉': 'Stable relationships deepen. Comfort and loyalty strengthen bonds.',
    'Gemini ♊': 'Stimulating conversations bring you closer to someone special.',
    'Cancer ♋': 'Emotional intimacy and nurturing gestures heal relationship wounds.',
    'Leo ♌': 'Romance takes center stage. Your charm attracts admiration and love.',
    'Virgo ♍': 'Practical acts of service show your love in meaningful ways.',
    'Libra ♎': 'Harmony and balance create beautiful moments with your partner.',
    'Scorpio ♏': 'Deep emotional connections and intense passion transform relationships.',
    'Sagittarius ♐': 'Adventure and shared experiences bring excitement to love.',
    'Capricorn ♑': 'Commitment and reliability strengthen long-term partnerships.',
    'Aquarius ♒': 'Unique connections and friendship-based love flourish beautifully.',
    'Pisces ♓': 'Compassionate understanding and spiritual connection deepen bonds.',
  };

  // Health horoscopes
  static const Map<String, String> healthHoroscopes = {
    'Aries ♈': 'High energy levels fuel your fitness goals. Channel that fire positively.',
    'Taurus ♉': 'Slow, steady wellness routines bring lasting health improvements.',
    'Gemini ♊': 'Mental stimulation and varied activities keep you sharp and healthy.',
    'Cancer ♋': 'Emotional wellness and comfort foods nourish your body and soul.',
    'Leo ♌': 'Confidence in your appearance boosts overall health and vitality.',
    'Virgo ♍': 'Attention to health details and preventive care pays off beautifully.',
    'Libra ♎': 'Balance in diet and exercise creates harmony in your physical well-being.',
    'Scorpio ♏': 'Intense workouts and transformative health practices show results.',
    'Sagittarius ♐': 'Outdoor activities and adventurous fitness routines energize you.',
    'Capricorn ♑': 'Disciplined health habits and structured routines build strength.',
    'Aquarius ♒': 'Innovative wellness approaches and group fitness bring benefits.',
    'Pisces ♓': 'Gentle, flowing exercises and mindful practices restore your energy.',
  };
  
  static String getHoroscopeForZodiac(String zodiac) {
    return dailyHoroscopes[zodiac] ?? 'The stars are aligning to bring you wisdom and insight today. Trust in your journey and embrace the cosmic energy surrounding you.';
  }

  static String getFinanceHoroscope(String zodiac) {
    return financeHoroscopes[zodiac] ?? 'Financial wisdom flows to you today. Trust your instincts with money matters.';
  }

  static String getRelationshipHoroscope(String zodiac) {
    return relationshipHoroscopes[zodiac] ?? 'Love and connection surround you. Open your heart to meaningful relationships.';
  }

  static String getHealthHoroscope(String zodiac) {
    return healthHoroscopes[zodiac] ?? 'Your body and mind are in harmony. Embrace wellness in all its forms.';
  }
  
  static List<String> getAllZodiacSigns() {
    return dailyHoroscopes.keys.toList();
  }
} 