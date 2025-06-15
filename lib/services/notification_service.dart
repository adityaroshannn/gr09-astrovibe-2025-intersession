import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/horoscope_data.dart';
import 'dart:math';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _channelId = 'astro_vibe_daily';
  static const String _channelName = 'Daily Horoscope';
  static const String _channelDescription = 'Daily zodiac horoscope notifications';
  static const int _notificationId = 1001;

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  DateTime? _lastNotificationTime;

  /// Initialize the notification service
  Future<void> initialize() async {
    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      
      // Android initialization settings
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS initialization settings (for future use)
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = true;
      print('✅ NotificationService: Initialized successfully');
    } catch (e) {
      print('⚠️ NotificationService: Failed to initialize - $e');
      _isInitialized = false;
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Notification tapped: ${response.payload}');
    // Could navigate to horoscope screen here if needed
  }

  /// Request notification permissions (Android 13+)
  Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      print('⚠️ NotificationService: Not initialized, skipping permission request');
      return false;
    }

    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? granted = await androidImplementation.requestNotificationsPermission();
        print('🔔 Notification permission granted: ${granted ?? false}');
        return granted ?? false;
      }
      
      return true; // Assume granted for older Android versions
    } catch (e) {
      print('⚠️ NotificationService: Permission request failed - $e');
      return false;
    }
  }

  /// Setup daily horoscope notifications for the current user
  Future<void> setupDailyHoroscope() async {
    try {
      // Check if user is logged in
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('⚠️ NotificationService: No user logged in, skipping setup');
        return;
      }

      // Check if notifications are initialized
      if (!_isInitialized) {
        print('⚠️ NotificationService: Not initialized, skipping setup');
        return;
      }

      // Request permissions first
      final bool hasPermission = await requestPermissions();
      if (!hasPermission) {
        print('⚠️ NotificationService: No permission granted, skipping setup');
        return;
      }

      // Get user's zodiac sign from Firestore
      final String? zodiacSign = await _getUserZodiacSign(user.uid);
      if (zodiacSign == null) {
        print('⚠️ NotificationService: No zodiac sign found for user');
        return;
      }

      // Cancel any existing notifications
      await _notifications.cancel(_notificationId);

      // Schedule daily notification at 10:00 AM
      await _scheduleDailyNotification(zodiacSign);
      
      print('✅ NotificationService: Daily horoscope setup complete for $zodiacSign');
    } catch (e) {
      print('⚠️ NotificationService: Setup failed - $e');
    }
  }

  /// Get user's zodiac sign from Firestore
  Future<String?> _getUserZodiacSign(String uid) async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        return data?['zodiac'] as String?;
      }
      return null;
    } catch (e) {
      print('⚠️ NotificationService: Failed to get zodiac sign - $e');
      return null;
    }
  }

  /// Schedule daily notification at 10:00 AM
  Future<void> _scheduleDailyNotification(String zodiacSign) async {
    try {
      // Use local timezone
      final tz.Location location = tz.local;
      
      // Schedule for 10:00 AM today, or tomorrow if it's already past 10:00 AM
      tz.TZDateTime scheduledDate = tz.TZDateTime(location, 
          DateTime.now().year, 
          DateTime.now().month, 
          DateTime.now().day, 
          10, 0); // 10:00 AM

      // If it's already past 10:00 AM today, schedule for tomorrow
      if (scheduledDate.isBefore(tz.TZDateTime.now(location))) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Get horoscope content
      final String horoscopeText = _getDailyHoroscope(zodiacSign);
      final String zodiacEmoji = _getZodiacEmoji(zodiacSign);

      await _notifications.zonedSchedule(
        _notificationId,
        '$zodiacEmoji Daily Horoscope for $zodiacSign',
        horoscopeText,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
            largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            styleInformation: const BigTextStyleInformation(''),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      );

      print('✅ NotificationService: Scheduled daily notification for $zodiacSign at ${scheduledDate.toString()}');
    } catch (e) {
      print('⚠️ NotificationService: Failed to schedule notification - $e');
    }
  }

  /// Get daily horoscope text for the zodiac sign
  String _getDailyHoroscope(String zodiacSign) {
    try {
      // Add zodiac emoji to sign name to match HoroscopeData format
      final String zodiacWithEmoji = '$zodiacSign ${_getZodiacEmoji(zodiacSign)}';
      
      // Use existing horoscope data
      String horoscope = HoroscopeData.getHoroscopeForZodiac(zodiacWithEmoji);
      
      if (horoscope.isEmpty) {
        // Fallback motivational messages
        final List<String> fallbackMessages = [
          'Today brings new opportunities your way! ✨',
          'The stars are aligned in your favor today! 🌟',
          'Trust your intuition - it will guide you well! 🔮',
          'A positive mindset will attract good fortune! 💫',
          'Today is perfect for new beginnings! 🌅',
          'Your cosmic energy is particularly strong today! ⭐',
          'The universe has wonderful surprises in store! 🎁',
          'Let your inner light shine bright today! ✨',
        ];
        
        final Random random = Random();
        horoscope = fallbackMessages[random.nextInt(fallbackMessages.length)];
      }

      // Truncate if too long for notification
      if (horoscope.length > 120) {
        horoscope = '${horoscope.substring(0, 117)}...';
      }

      return horoscope;
    } catch (e) {
      print('⚠️ NotificationService: Failed to get horoscope - $e');
      return 'The stars have something special planned for you today! ✨';
    }
  }

  /// Get zodiac emoji
  String _getZodiacEmoji(String zodiacSign) {
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
    
    return zodiacEmojis[zodiacSign] ?? '⭐';
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      print('✅ NotificationService: All notifications cancelled');
    } catch (e) {
      print('⚠️ NotificationService: Failed to cancel notifications - $e');
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? enabled = await androidImplementation.areNotificationsEnabled();
        return enabled ?? false;
      }
      
      return false;
    } catch (e) {
      print('⚠️ NotificationService: Failed to check notification status - $e');
      return false;
    }
  }

  /// Show instant horoscope notification (for login/app start)
  Future<void> showHoroscopeNotification() async {
    try {
      // Check if notifications are initialized
      if (!_isInitialized) {
        print('⚠️ NotificationService: Not initialized, skipping instant notification');
        return;
      }

      // Prevent duplicate notifications within 5 minutes
      final DateTime now = DateTime.now();
      if (_lastNotificationTime != null) {
        final Duration timeSinceLastNotification = now.difference(_lastNotificationTime!);
        if (timeSinceLastNotification.inMinutes < 5) {
          print('⚠️ NotificationService: Skipping duplicate notification (${timeSinceLastNotification.inMinutes} minutes ago)');
          return;
        }
      }

      // Check if notifications are enabled
      final bool hasPermission = await areNotificationsEnabled();
      if (!hasPermission) {
        print('⚠️ NotificationService: No permission for instant notification');
        return;
      }

      // Show instant notification
      await _notifications.show(
        _notificationId + 1, // Different ID from daily notifications
        'Your Stars Are Ready ✨',
        'Check your daily horoscope now on AstroVibe!',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            styleInformation: const BigTextStyleInformation(''),
            showWhen: true,
          ),
        ),
      );

      // Update last notification time
      _lastNotificationTime = now;
      
      print('✅ NotificationService: Instant horoscope notification shown');
    } catch (e) {
      print('⚠️ NotificationService: Failed to show instant notification - $e');
    }
  }

  /// Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      print('⚠️ NotificationService: Failed to get pending notifications - $e');
      return [];
    }
  }
} 