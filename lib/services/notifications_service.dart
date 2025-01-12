// lib/services/notifications_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vet_pharmacy/models/medicine.dart';

class NotificationsService {
  static final NotificationsService _instance = NotificationsService._internal();
  factory NotificationsService() => _instance;
  NotificationsService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = DarwinInitializationSettings();
    final settings = InitializationSettings(android: android, iOS: iOS);
    
    await _notifications.initialize(settings);
  }

  Future<void> scheduleExpiryNotification(Medicine medicine) async {
    final daysUntilExpiry = medicine.expiryDate.difference(DateTime.now()).inDays;
    
    if (daysUntilExpiry <= 30) {
      await _notifications.show(
        medicine.id!,
        'تنبيه انتهاء الصلاحية',
        'الدواء ${medicine.name} سينتهي خلال $daysUntilExpiry يوم',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'expiry_channel',
            'Expiry Notifications',
            channelDescription: 'تنبيهات انتهاء صلاحية الأدوية',
            importance: Importance.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }

  Future<void> showLowStockNotification(Medicine medicine) async {
    if (medicine.quantity < 10) {
      await _notifications.show(
        medicine.id!,
        'تنبيه انخفاض المخزون',
        'الدواء ${medicine.name} منخفض في المخزون (${medicine.quantity} قطعة)',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'stock_channel',
            'Stock Notifications',
            channelDescription: 'تنبيهات انخفاض المخزون',
            importance: Importance.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }
}