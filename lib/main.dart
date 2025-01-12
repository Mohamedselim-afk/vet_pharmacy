import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'screens/home_screen.dart';
import 'services/database_helper.dart';
import 'services/notifications_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة قاعدة البيانات
  await DatabaseHelper.instance.initializeDatabase();

  // تهيئة نظام الإشعارات
  final notificationsService = NotificationsService();
  await notificationsService.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'الصيدلية البيطرية',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'BahijTheSansArabic',
      ),
      locale: const Locale('ar', 'EG'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'EG'),
      ],
      home: HomeScreen(),
    );
  }
}
