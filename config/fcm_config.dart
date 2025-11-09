// FCM Configuration
// Replace this with your actual FCM Server Key from Firebase Console

class FCMConfig {
  // Get your Server Key from:
  // Firebase Console > Project Settings > Cloud Messaging > Server Key
  
  static const String serverKey = 'YOUR_FCM_SERVER_KEY_HERE';
  
  // For production, use environment variables instead:
  // static String get serverKey => const String.fromEnvironment('FCM_SERVER_KEY');
}

