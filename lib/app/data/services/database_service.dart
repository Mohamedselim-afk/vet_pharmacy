// lib/app/data/services/database_service.dart
import 'dart:async';

import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:vet_pharmacy/app/data/models/customer.dart';
import 'package:vet_pharmacy/app/data/models/sale.dart';
import 'package:vet_pharmacy/app/data/models/supplier.dart';
import 'package:vet_pharmacy/app/data/services/notifications_service.dart';
import '../models/medicine.dart';

class DatabaseService extends GetxService {
  static DatabaseService get to => Get.find();
  final NotificationsService _notificationsService =
      Get.find<NotificationsService>();
  Database? _database;

  // Using RxInterface for updates
  final medicinesUpdate = false.obs;
  final salesUpdate = false.obs;
  final suppliersUpdate = false.obs;

  // Notify methods
  void notifyMedicineUpdate() => medicinesUpdate.toggle();
  void notifySalesUpdate() => salesUpdate.toggle();
  void notifySupplierUpdate() => suppliersUpdate.toggle();

  Future<List<Medicine>> getExpiringMedicines(int days) async {
    final db = await database;
    final thresholdDate = DateTime.now().add(Duration(days: days));

    final List<Map<String, dynamic>> maps = await db.query(
      'medicines',
      where: 'expiry_date <= ?',
      whereArgs: [thresholdDate.toIso8601String()],
    );

    return List.generate(maps.length, (i) => Medicine.fromMap(maps[i]));
  }

  Future<List<Map<String, dynamic>>> getCustomDateRangeSalesReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        COUNT(*) as total_sales,
        SUM(total) as total_amount,
        date(date) as sale_date
      FROM sales
      WHERE date BETWEEN ? AND ?
      GROUP BY date(date)
      ORDER BY date(date)
    ''', [
      startDate.toIso8601String(),
      endDate.toIso8601String(),
    ]);
  }

  Future<int> updateMedicineQuantity(int id, int newQuantity) async {
    final db = await database;
    final result = await db.update(
      'medicines',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [id],
    );

    // Notify about the change
    notifyMedicineUpdate();

    // Check for low stock
    if (newQuantity <= 10) {
      final medicine = await getMedicineById(id);
      if (medicine != null) {
        await _notificationsService.showLowStockNotification(medicine);
      }
    }

    return result;
  }

  Future<DatabaseService> init() async {
    await initializeDatabase();
    return this;
  }

  Future<void> initializeDatabase() async {
    try {
      if (_database != null) return;
      _database = await _initDB('pharmacy.db');
      print('تم تهيئة قاعدة البيانات بنجاح');
    } catch (e) {
      print('خطأ في تهيئة قاعدة البيانات: $e');
      rethrow;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pharmacy.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> updateSupplier(Supplier supplier) async {
    try {
      final db = await database;
      await db.update(
        'suppliers',
        supplier.toMap(),
        where: 'id = ?',
        whereArgs: [supplier.id],
      );
    } catch (e) {
      print('Error updating supplier: $e');
      throw Exception('فشل في تحديث بيانات المندوب');
    }
  }

  Future<void> deleteSupplier(int id) async {
    try {
      final db = await database;
      await db.delete(
        'suppliers',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting supplier: $e');
      throw Exception('فشل في حذف المندوب');
    }
  }

  Future<void> addSupplierPayment(
      int supplierId, double amount, String notes) async {
    try {
      final db = await database;
      await db.insert('supplier_payments', {
        'supplier_id': supplierId,
        'amount': amount,
        'payment_date': DateTime.now().toIso8601String(),
        'notes': notes,
      });
    } catch (e) {
      print('Error adding supplier payment: $e');
      throw Exception('فشل في تسجيل الدفعة');
    }
  }

  // دالة لجلب سجل مدفوعات المندوب
  Future<List<Map<String, dynamic>>> getSupplierPayments(int supplierId) async {
    try {
      final db = await database;
      return await db.query(
        'supplier_payments',
        where: 'supplier_id = ?',
        whereArgs: [supplierId],
        orderBy: 'payment_date DESC',
      );
    } catch (e) {
      print('Error getting supplier payments: $e');
      throw Exception('فشل في تحميل سجل المدفوعات');
    }
  }

  Future<int> updateMedicinePaidAmount(
      int medicineId, double newAmountPaid) async {
    final db = await database;
    return await db.update(
      'medicines',
      {'amount_paid': newAmountPaid},
      where: 'id = ?',
      whereArgs: [medicineId],
    );
  }

  Future<List<Map<String, dynamic>>> getSupplierPaymentHistory(
      int supplierId) async {
    final db = await database;
    return await db.query(
      'medicine_payments',
      where: 'supplier_id = ?',
      whereArgs: [supplierId],
      orderBy: 'payment_date DESC',
    );
  }

  Future<int> addMedicinePayment(Map<String, dynamic> payment) async {
    final db = await database;
    return await db.insert('medicine_payments', payment);
  }

  Future<void> _createDB(Database db, int version) async {
    try {
      // إضافة IF NOT EXISTS لمنع الخطأ عند وجود الجدول
      await db.execute('''
      CREATE TABLE IF NOT EXISTS suppliers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        address TEXT,
        notes TEXT
      )
    ''');
      print('تم تجهيز جدول المناديب');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        address TEXT
      )
    ''');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS medicines(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        barcode TEXT,
        quantity INTEGER NOT NULL,
        market_price REAL NOT NULL,
        selling_price REAL NOT NULL,
        purchase_price REAL NOT NULL,
        box_quantity INTEGER NOT NULL,
        box_price REAL NOT NULL,
        total_quantity INTEGER NOT NULL,
        amount_paid REAL NOT NULL,
        supplier_id INTEGER NOT NULL,
        image TEXT,
        expiry_date TEXT,
        FOREIGN KEY (supplier_id) REFERENCES suppliers (id)
      )
    ''');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS sales(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers (id)
      )
    ''');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS sale_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        medicine_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales (id),
        FOREIGN KEY (medicine_id) REFERENCES medicines (id)
      )
    ''');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS medicine_payments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicine_id INTEGER NOT NULL,
        supplier_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        payment_date TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (medicine_id) REFERENCES medicines (id),
        FOREIGN KEY (supplier_id) REFERENCES suppliers (id)
      )
    ''');

      print('تم إنشاء جميع الجداول بنجاح');
    } catch (e) {
      print('خطأ في إنشاء قاعدة البيانات: $e');
      rethrow;
    }
  }

  // Supplier Methods
  Future<int> insertSupplier(Supplier supplier) async {
    try {
      final db = await database;

      // تجهيز البيانات
      final data = {
        'name': supplier.name,
        'phone': supplier.phone ?? '',
        'address': supplier.address ?? '',
        'notes': supplier.notes ?? '',
      };

      print('Inserting supplier data: $data');

      // محاولة الإدخال
      final id = await db.rawInsert('''
      INSERT INTO suppliers (name, phone, address, notes)
      VALUES (?, ?, ?, ?)
    ''', [data['name'], data['phone'], data['address'], data['notes']]);

      print('Inserted supplier with id: $id');
      notifySupplierUpdate();
      return id;
    } catch (e, stackTrace) {
      print('Error inserting supplier: $e');
      print('Stack trace: $stackTrace');
      throw Exception('فشل في إضافة المندوب: $e');
    }
  }

  Future<List<Supplier>> getAllSuppliers() async {
    try {
      final db = await database;

      // نستخدم rawQuery بدل query للتحكم الكامل في الاستعلام
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT id, name, phone, address, notes 
      FROM suppliers 
      ORDER BY name ASC
    ''');

      print('Raw query result: $maps'); // للتشخيص

      if (maps.isEmpty) {
        print('No suppliers found in database');
        return [];
      }

      final suppliers = maps.map((map) {
        final supplier = Supplier(
          id: map['id'] as int,
          name: map['name'] as String,
          phone: map['phone'] as String?,
          address: map['address'] as String?,
          notes: map['notes'] as String?,
        );
        print('Created supplier: $supplier'); // للتشخيص
        return supplier;
      }).toList();

      print('Returning ${suppliers.length} suppliers');
      return suppliers;
    } catch (e, stackTrace) {
      print('Error in getAllSuppliers: $e');
      print('Stack trace: $stackTrace');
      throw Exception('فشل في تحميل قائمة المناديب: $e');
    }
  }

  Future<Supplier?> getSupplierById(int id) async {
    try {
      final db = await database;
      final maps = await db.query(
        'suppliers',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Supplier.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting supplier by id: $e');
      throw Exception('فشل في تحميل بيانات المندوب');
    }
  }

  Future<List<Medicine>> getMedicinesBySupplier(int supplierId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medicines',
      where: 'supplier_id = ?',
      whereArgs: [supplierId],
    );
    return List.generate(maps.length, (i) => Medicine.fromMap(maps[i]));
  }

  Future<Map<String, dynamic>> getSupplierSummary(int supplierId) async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT 
      COALESCE(SUM(total_quantity * purchase_price), 0.0) as total_amount,
      COALESCE(SUM(amount_paid), 0.0) as total_paid,
      COALESCE(SUM(total_quantity * purchase_price - amount_paid), 0.0) as remaining_amount,
      COUNT(DISTINCT id) as medicine_count
    FROM medicines
    WHERE supplier_id = ?
  ''', [supplierId]);

    if (result.isEmpty) {
      return {
        'total_amount': 0.0,
        'total_paid': 0.0,
        'remaining_amount': 0.0,
        'medicine_count': 0
      };
    }

    return {
      'total_amount': result.first['total_amount'] ?? 0.0,
      'total_paid': result.first['total_paid'] ?? 0.0,
      'remaining_amount': result.first['remaining_amount'] ?? 0.0,
      'medicine_count': result.first['medicine_count'] ?? 0
    };
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS suppliers(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT,
          address TEXT,
          notes TEXT
        )
      ''');
      print('تحديث قاعدة البيانات من الإصدار $oldVersion إلى $newVersion');
    }
  }

  // Medicine Operations
  Future<int> insertMedicine(Medicine medicine) async {
    final db = await database;
    final result = await db.insert('medicines', medicine.toMap());

    notifyMedicineUpdate();
    return result;
  }

  Future<List<Medicine>> getAllMedicines() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('medicines');
    return List.generate(maps.length, (i) => Medicine.fromMap(maps[i]));
  }

  Future<Medicine?> getMedicineById(int id) async {
    final db = await database;
    final maps = await db.query(
      'medicines',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Medicine.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Medicine>> searchMedicines(String query) async {
    final db = await database;
    final maps = await db.query(
      'medicines',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    return List.generate(maps.length, (i) => Medicine.fromMap(maps[i]));
  }

  Future<int> updateMedicine(Medicine medicine) async {
    final db = await database;
    final result = await db.update(
      'medicines',
      medicine.toMap(),
      where: 'id = ?',
      whereArgs: [medicine.id],
    );

    notifyMedicineUpdate();
    return result;
  }

  Future<int> deleteMedicine(int id) async {
    final db = await database;
    final result = await db.delete(
      'medicines',
      where: 'id = ?',
      whereArgs: [id],
    );

    notifyMedicineUpdate();
    return result;
  }

  // Sales Operations
  Future<int> insertSale(Sale sale) async {
    final db = await database;
    final batch = db.batch();

    // Insert sale
    batch.insert('sales', sale.toMap());
    final results = await batch.commit();
    final saleId = results[0] as int;

    // Insert sale items and update quantities
    for (var item in sale.items) {
      await db.insert('sale_items', {
        ...item.toMap(),
        'sale_id': saleId,
      });

      // Update medicine quantity
      final medicine = await getMedicineById(item.medicineId);
      if (medicine != null) {
        await updateMedicineQuantity(
          item.medicineId,
          medicine.quantity - item.quantity,
        );
      }
    }

    // Notify about changes
    notifySalesUpdate();
    notifyMedicineUpdate();

    return saleId;
  }

  @override
  void onClose() {
    super.onClose();
  }

  // Customer Operations
  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return await db.insert('customers', customer.toMap());
  }

  Future<List<Customer>> getAllCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('customers');
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  Future<List<Customer>> searchCustomers(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'name LIKE ? OR phone LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  // Reports Operations
  Future<List<Map<String, dynamic>>> getDailySalesReport(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().substring(0, 10);
    return await db.rawQuery('''
      SELECT 
        COUNT(*) as total_sales,
        SUM(total) as total_amount
      FROM sales
      WHERE date LIKE ?
    ''', ['$dateStr%']);
  }

  Future<List<Map<String, dynamic>>> getTopSellingMedicines(
      {int limit = 10}) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        m.id,
        m.name,
        COUNT(*) as times_sold,
        SUM(si.quantity) as total_quantity
      FROM sale_items si
      JOIN medicines m ON si.medicine_id = m.id
      GROUP BY m.id
      ORDER BY total_quantity DESC
      LIMIT ?
    ''', [limit]);
  }

  Future<List<Medicine>> getLowStockMedicines(int threshold) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medicines',
      where: 'quantity <= ?',
      whereArgs: [threshold],
    );
    return List.generate(maps.length, (i) => Medicine.fromMap(maps[i]));
  }

  Future<double> calculateInventoryValue() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(quantity * price) as total_value
      FROM medicines
    ''');
    return result.first['total_value'] as double? ?? 0.0;
  }
}
