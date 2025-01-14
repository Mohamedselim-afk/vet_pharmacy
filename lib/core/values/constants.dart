// lib/core/values/constants.dart
class AppConstants {
  // Database
  static const String DATABASE_NAME = 'pharmacy.db';
  static const int DATABASE_VERSION = 2;

  // Notifications
  static const String EXPIRY_CHANNEL_ID = 'expiry_channel';
  static const String EXPIRY_CHANNEL_NAME = 'Expiry Notifications';
  static const String EXPIRY_CHANNEL_DESC = 'تنبيهات انتهاء صلاحية الأدوية';
  
  static const String STOCK_CHANNEL_ID = 'stock_channel';
  static const String STOCK_CHANNEL_NAME = 'Stock Notifications';
  static const String STOCK_CHANNEL_DESC = 'تنبيهات انخفاض المخزون';

  // Thresholds
  static const int LOW_STOCK_THRESHOLD = 10;
  static const int EXPIRY_WARNING_DAYS = 30;

  // Date Formats
  static const String DATE_FORMAT = 'dd/MM/yyyy';
  static const String DATE_TIME_FORMAT = 'dd/MM/yyyy HH:mm';
  
  // Currency
  static const String CURRENCY = 'جنيه';
}

// lib/core/values/messages.dart
class AppMessages {
  static const String SUCCESS = 'نجاح';
  static const String ERROR = 'خطأ';
  static const String WARNING = 'تنبيه';
  
  static const String NO_MEDICINES = 'لا يوجد أدوية في المخزون';
  static const String NO_SALES = 'لا توجد مبيعات';
  static const String NO_DATA = 'لا توجد بيانات';
  
  static const String DELETE_CONFIRMATION = 'هل أنت متأكد من الحذف؟';
  static const String SAVE_SUCCESS = 'تم الحفظ بنجاح';
  static const String UPDATE_SUCCESS = 'تم التحديث بنجاح';
  static const String DELETE_SUCCESS = 'تم الحذف بنجاح';
  
  static const String REQUIRED_FIELD = 'هذا الحقل مطلوب';
  static const String INVALID_QUANTITY = 'الكمية غير صحيحة';
  static const String INVALID_PRICE = 'السعر غير صحيح';
  
  static const String LOW_STOCK_WARNING = 'تنبيه: المخزون منخفض';
  static const String EXPIRY_WARNING = 'تنبيه: قرب انتهاء الصلاحية';
}