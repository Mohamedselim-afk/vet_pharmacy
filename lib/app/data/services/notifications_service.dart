// lib/app/data/services/notifications_service.dart
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../data/models/medicine.dart';

class NotificationsService extends GetxService {
  static NotificationsService get to => Get.find();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

Future<NotificationsService> init() async {
    try {
      final android = AndroidInitializationSettings('@mipmap/ic_launcher');
      final iOS = DarwinInitializationSettings();
      final settings = InitializationSettings(android: android, iOS: iOS);
      
      await _notifications.initialize(settings);
      return this;
    } catch (e) {
      print('Error initializing notifications: $e');
      return this;
    }
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