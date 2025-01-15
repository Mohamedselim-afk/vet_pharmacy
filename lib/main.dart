// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'app/routes/app_pages.dart';
import 'app/data/services/database_service.dart';
import 'app/data/services/notifications_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // حذف قاعدة البيانات القديمة (اختياري، فقط للتجربة)
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pharmacy.db');
    await deleteDatabase(path);
    print('تم حذف قاعدة البيانات القديمة');

    // تهيئة الخدمات
    await Get.putAsync(() => NotificationsService().init());
    await Get.putAsync(() => DatabaseService().init());
    print('تم تهيئة الخدمات بنجاح');

  } catch (e) {
    print('خطأ في تهيئة التطبيق: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'الصيدلية البيطرية',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('ar', 'EG'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'EG'),
      ],
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      initialBinding: BindingsBuilder(() {
        Get.put(DatabaseService());
        // ... أي services أخرى
      }),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}