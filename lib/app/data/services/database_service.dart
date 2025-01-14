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

  // Using RxInterface instead of Streams
  final medicinesUpdate = false.obs;
  final salesUpdate = false.obs;

  // Notify methods
  void notifyMedicineUpdate() => medicinesUpdate.toggle();
  void notifySalesUpdate() => salesUpdate.toggle();

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
    if (_database != null) return;
    _database = await _initDB('pharmacy.db');
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
    // 1. إنشاء جدول المناديب أولاً
    await db.execute('''
    CREATE TABLE suppliers(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      phone TEXT,
      address TEXT,
      notes TEXT
    )
    ''');

    // 2. إنشاء جدول العملاء
    await db.execute('''
    CREATE TABLE customers(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      phone TEXT,
      address TEXT
    )
    ''');

    // 3. إنشاء جدول الأدوية مرة واحدة فقط مع كل الحقول المطلوبة
    await db.execute('''
    CREATE TABLE medicines(
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

    // 4. إنشاء جدول المبيعات
    await db.execute('''
    CREATE TABLE sales(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      customer_id INTEGER NOT NULL,
      date TEXT NOT NULL,
      total REAL NOT NULL,
      FOREIGN KEY (customer_id) REFERENCES customers (id)
    )
    ''');

    // 5. إنشاء جدول عناصر المبيعات
    await db.execute('''
    CREATE TABLE sale_items(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      sale_id INTEGER NOT NULL,
      medicine_id INTEGER NOT NULL,
      quantity INTEGER NOT NULL,
      price REAL NOT NULL,
      FOREIGN KEY (sale_id) REFERENCES sales (id),
      FOREIGN KEY (medicine_id) REFERENCES medicines (id)
    )
    ''');

    // 6. إنشاء جدول مدفوعات الأدوية
    await db.execute('''
    CREATE TABLE medicine_payments(
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

    await db.execute('''
CREATE TABLE IF NOT EXISTS suppliers(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  phone TEXT,
  address TEXT,
  notes TEXT
)
''');
    print('Suppliers table created successfully');
  }

  Future<int> insertSupplier(Supplier supplier) async {
    try {
      final db = await database;
      final Map<String, dynamic> supplierMap = supplier.toMap();
      // Remove the id field as it's auto-generated
      supplierMap.remove('id');

      final id = await db.insert(
        'suppliers',
        supplierMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e) {
      print('Error inserting supplier: $e');
      throw Exception('فشل في إضافة المندوب');
    }
  }

  Future<List<Supplier>> getAllSuppliers() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'suppliers',
        orderBy: 'name ASC',
      );

      // Add error checking for empty or invalid data
      if (maps.isEmpty) {
        return [];
      }

      return List.generate(maps.length, (i) {
        try {
          return Supplier.fromMap(maps[i]);
        } catch (e) {
          print('Error parsing supplier data: $e');
          // Return a dummy supplier if data is corrupt
          return Supplier(
            id: -1,
            name: 'بيانات تالفة',
            phone: '',
            address: '',
          );
        }
      }).where((supplier) => supplier.id != -1).toList();
    } catch (e) {
      print('Error getting suppliers: $e');
      throw Exception('فشل في تحميل قائمة المناديب');
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
        SUM(total_quantity * purchase_price) as total_amount,
        SUM(amount_paid) as total_paid,
        SUM(total_quantity * purchase_price - amount_paid) as remaining_amount,
        COUNT(DISTINCT id) as medicine_count
      FROM medicines
      WHERE supplier_id = ?
    ''', [supplierId]);

    return result.first;
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        address TEXT
      )
      ''');
      await db.execute(
          'ALTER TABLE sales ADD COLUMN customer_id INTEGER REFERENCES customers(id)');
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
