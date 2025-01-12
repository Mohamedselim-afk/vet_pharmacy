// lib/services/database_helper.dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/medicine.dart';
import '../models/sale.dart';
import '../models/customer.dart';
import 'notifications_service.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

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

  Future<void> _createDB(Database db, int version) async {
    // جدول العملاء
    await db.execute('''
    CREATE TABLE customers(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      phone TEXT,
      address TEXT
    )
    ''');

    // جدول الأدوية
    await db.execute('''
    CREATE TABLE medicines(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      barcode TEXT,
      quantity INTEGER NOT NULL,
      price REAL NOT NULL,
      image TEXT,
      expiry_date TEXT
    )
    ''');

    // جدول المبيعات مع customer_id
    await db.execute('''
    CREATE TABLE sales(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      customer_id INTEGER NOT NULL,
      date TEXT NOT NULL,
      total REAL NOT NULL,
      FOREIGN KEY (customer_id) REFERENCES customers (id)
    )
    ''');

    // جدول تفاصيل المبيعات
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

  // عمليات العملاء
  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return await db.insert('customers', customer.toMap());
  }

  Future<List<Customer>> getAllCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('customers');
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  Future<Customer?> getCustomerById(int id) async {
    final db = await database;
    final maps = await db.query('customers', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return Customer.fromMap(maps.first);
    return null;
  }

  // عمليات الأدوية
  Future<int> insertMedicine(Medicine medicine) async {
    final db = await database;
    return await db.insert('medicines', medicine.toMap());
  }

  Future<Medicine?> getMedicineById(int id) async {
    final db = await database;
    final maps = await db.query('medicines', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return Medicine.fromMap(maps.first);
    return null;
  }

  Future<Medicine?> getMedicineByBarcode(String barcode) async {
    final db = await database;
    final maps =
        await db.query('medicines', where: 'barcode = ?', whereArgs: [barcode]);
    if (maps.isNotEmpty) return Medicine.fromMap(maps.first);
    return null;
  }

  Future<List<Medicine>> getAllMedicines() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('medicines');
    return List.generate(maps.length, (i) => Medicine.fromMap(maps[i]));
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

  Future<List<Customer>> searchCustomers(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'name LIKE ? OR phone LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  Future<void> updateMedicineQuantity(int id, int newQuantity) async {
    final db = await database;
    await db.update(
      'medicines',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [id],
    );

    if (newQuantity < 10) {
      final medicine = await getMedicineById(id);
      if (medicine != null) {
        await NotificationsService().showLowStockNotification(medicine);
      }
    }
  }
  Future<int> updateMedicine(Medicine medicine) async {
  final db = await database;
  return await db.update(
    'medicines',
    medicine.toMap(),
    where: 'id = ?',
    whereArgs: [medicine.id],
  );
}

  Future<int> deleteMedicine(int id) async {
  final db = await database;
  return await db.delete(
    'medicines',
    where: 'id = ?',
    whereArgs: [id],
  );
}

  // عمليات المبيعات
  Future<int> insertSale(Sale sale) async {
    final db = await database;
    final saleId = await db.insert('sales', sale.toMap());

    for (var item in sale.items) {
      await db.insert('sale_items', {
        ...item.toMap(),
        'sale_id': saleId,
      });

      final medicine = await getMedicineById(item.medicineId);
      if (medicine != null) {
        await updateMedicineQuantity(
            item.medicineId, medicine.quantity - item.quantity);
      }
    }

    return saleId;
  }

  Future<List<Map<String, dynamic>>> getCustomerSaleHistory(
      int customerId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        s.id as sale_id,
        s.date,
        s.total,
        m.name as medicine_name,
        si.quantity,
        si.price,
        (si.quantity * si.price) as item_total
      FROM sales s
      JOIN sale_items si ON s.id = si.sale_id
      JOIN medicines m ON si.medicine_id = m.id
      WHERE s.customer_id = ?
      ORDER BY s.date DESC
    ''', [customerId]);
  }

  Future<Map<String, dynamic>> getCustomerStatistics(int customerId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(DISTINCT s.id) as total_visits,
        SUM(s.total) as total_spent,
        MAX(s.date) as last_visit
      FROM sales s
      WHERE s.customer_id = ?
    ''', [customerId]);
    return result.first;
  }

  // تقارير وإحصائيات
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
    final maps = await db.query(
      'medicines',
      where: 'quantity <= ?',
      whereArgs: [threshold],
    );
    return List.generate(maps.length, (i) => Medicine.fromMap(maps[i]));
  }

  Future<List<Medicine>> getExpiringMedicines(int daysThreshold) async {
    final db = await database;
    final thresholdDate = DateTime.now().add(Duration(days: daysThreshold));
    final maps = await db.query(
      'medicines',
      where: 'expiry_date <= ?',
      whereArgs: [thresholdDate.toIso8601String()],
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
