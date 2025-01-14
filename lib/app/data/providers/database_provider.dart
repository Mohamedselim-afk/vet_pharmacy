// lib/app/data/providers/database_provider.dart
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/customer.dart';
import '../models/medicine.dart';
import '../models/sale.dart';
import '../models/report.dart';

class DatabaseProvider {
  static Database? _database;

  // SQL Queries
  static const String CREATE_CUSTOMERS_TABLE = '''
    CREATE TABLE customers(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      phone TEXT,
      address TEXT
    )
  ''';

  static const String CREATE_MEDICINES_TABLE = '''
    CREATE TABLE medicines(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      barcode TEXT,
      quantity INTEGER NOT NULL,
      price REAL NOT NULL,
      image TEXT,
      expiry_date TEXT
    )
  ''';

  static const String CREATE_SALES_TABLE = '''
    CREATE TABLE sales(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      customer_id INTEGER,
      date TEXT NOT NULL,
      total REAL NOT NULL,
      FOREIGN KEY (customer_id) REFERENCES customers (id)
    )
  ''';

  static const String CREATE_SALE_ITEMS_TABLE = '''
    CREATE TABLE sale_items(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      sale_id INTEGER NOT NULL,
      medicine_id INTEGER NOT NULL,
      quantity INTEGER NOT NULL,
      price REAL NOT NULL,
      FOREIGN KEY (sale_id) REFERENCES sales (id),
      FOREIGN KEY (medicine_id) REFERENCES medicines (id)
    )
  ''';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'pharmacy.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(CREATE_CUSTOMERS_TABLE);
        await db.execute(CREATE_MEDICINES_TABLE);
        await db.execute(CREATE_SALES_TABLE);
        await db.execute(CREATE_SALE_ITEMS_TABLE);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Handle database upgrades here
      },
    );
  }

  // Customer Methods
  Future<List<Customer>> getAllCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('customers');
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  Future<Customer?> getCustomerById(int id) async {
    final db = await database;
    final maps = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Customer.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return await db.insert('customers', customer.toMap());
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    return await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await database;
    return await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
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

  // Medicine Methods
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

  Future<int> insertMedicine(Medicine medicine) async {
    final db = await database;
    return await db.insert('medicines', medicine.toMap());
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

  Future<List<Medicine>> searchMedicines(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medicines',
      where: 'name LIKE ? OR barcode LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Medicine.fromMap(maps[i]));
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

  Future<List<Medicine>> getExpiringMedicines(int days) async {
    final expiryDate = DateTime.now().add(Duration(days: days));
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medicines',
      where: 'expiry_date <= ?',
      whereArgs: [expiryDate.toIso8601String()],
    );
    return List.generate(maps.length, (i) => Medicine.fromMap(maps[i]));
  }

  // Sale Methods
  Future<int> insertSale(Sale sale) async {
    final db = await database;
    final batch = db.batch();

    // Insert sale
    final saleMap = sale.toMap();
    batch.insert('sales', saleMap);

    // Get the sale ID
    final List<dynamic> results = await batch.commit();
    final saleId = results[0] as int;

    // Insert sale items
    for (var item in sale.items) {
      await db.insert('sale_items', {
        ...item.toMap(),
        'sale_id': saleId,
      });

      // Update medicine quantity
      await db.rawUpdate('''
        UPDATE medicines 
        SET quantity = quantity - ? 
        WHERE id = ?
      ''', [item.quantity, item.medicineId]);
    }

    return saleId;
  }

  Future<List<SalesReport>> getSalesReport(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        s.date,
        COUNT(*) as total_sales,
        SUM(s.total) as total_amount,
        m.name as medicine_name,
        si.quantity,
        si.price,
        (si.quantity * si.price) as item_total
      FROM sales s
      JOIN sale_items si ON s.id = si.sale_id
      JOIN medicines m ON si.medicine_id = m.id
      WHERE s.date BETWEEN ? AND ?
      GROUP BY s.date
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return List.generate(maps.length, (i) => SalesReport.fromMap(maps[i]));
  }

  Future<InventoryReport> getInventoryReport() async {
    final db = await database;
    final currentDate = DateTime.now();
    
    // Get all medicines
    final List<Map<String, dynamic>> medicineMaps = await db.query('medicines');
    final List<MedicineReportItem> items = medicineMaps.map((map) {
      final medicine = Medicine.fromMap(map);
      return MedicineReportItem(
        medicineName: medicine.name,
        currentStock: medicine.quantity,
        minimumStock: 10, // Configurable
        expiryDate: medicine.expiryDate,
        value: medicine.totalValue,
      );
    }).toList();

    // Calculate total value
    final double totalValue = items.fold(0, (sum, item) => sum + item.value);

    // Get low stock items
    final lowStockItems = await getLowStockMedicines(10);

    // Get expiring items
    final expiringItems = await getExpiringMedicines(30);

    return InventoryReport(
      date: currentDate,
      items: items,
      totalValue: totalValue,
      lowStockItems: lowStockItems,
      expiringItems: expiringItems,
    );
  }

  // Helper Methods
  Future<void> clearTables() async {
    final db = await database;
    await db.delete('sale_items');
    await db.delete('sales');
    await db.delete('medicines');
    await db.delete('customers');
  }
}

