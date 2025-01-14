import 'package:vet_pharmacy/app/data/models/medicine.dart';

class SalesReport {
  final DateTime date;
  final int totalSales;
  final double totalAmount;
  final List<SaleReportItem> items;

  SalesReport({
    required this.date,
    required this.totalSales,
    required this.totalAmount,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'total_sales': totalSales,
      'total_amount': totalAmount,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  static SalesReport fromMap(Map<String, dynamic> map) {
    return SalesReport(
      date: DateTime.parse(map['date']),
      totalSales: map['total_sales'],
      totalAmount: map['total_amount'],
      items: List<SaleReportItem>.from(
        map['items']?.map((x) => SaleReportItem.fromMap(x)),
      ),
    );
  }
}

class SaleReportItem {
  final String medicineName;
  final int quantity;
  final double price;
  final double total;

  SaleReportItem({
    required this.medicineName,
    required this.quantity,
    required this.price,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'medicine_name': medicineName,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }

  static SaleReportItem fromMap(Map<String, dynamic> map) {
    return SaleReportItem(
      medicineName: map['medicine_name'],
      quantity: map['quantity'],
      price: map['price'],
      total: map['total'],
    );
  }
}

class InventoryReport {
  final DateTime date;
  final List<MedicineReportItem> items;
  final double totalValue;
  final List<Medicine> lowStockItems;
  final List<Medicine> expiringItems;

  InventoryReport({
    required this.date,
    required this.items,
    required this.totalValue,
    required this.lowStockItems,
    required this.expiringItems,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'items': items.map((item) => item.toMap()).toList(),
      'total_value': totalValue,
      'low_stock_items': lowStockItems.map((item) => item.toMap()).toList(),
      'expiring_items': expiringItems.map((item) => item.toMap()).toList(),
    };
  }

  static InventoryReport fromMap(Map<String, dynamic> map) {
    return InventoryReport(
      date: DateTime.parse(map['date']),
      items: List<MedicineReportItem>.from(
        map['items']?.map((x) => MedicineReportItem.fromMap(x)),
      ),
      totalValue: map['total_value'],
      lowStockItems: List<Medicine>.from(
        map['low_stock_items']?.map((x) => Medicine.fromMap(x)),
      ),
      expiringItems: List<Medicine>.from(
        map['expiring_items']?.map((x) => Medicine.fromMap(x)),
      ),
    );
  }
}

class MedicineReportItem {
  final String medicineName;
  final int currentStock;
  final int minimumStock;
  final DateTime expiryDate;
  final double value;

  MedicineReportItem({
    required this.medicineName,
    required this.currentStock,
    required this.minimumStock,
    required this.expiryDate,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'medicine_name': medicineName,
      'current_stock': currentStock,
      'minimum_stock': minimumStock,
      'expiry_date': expiryDate.toIso8601String(),
      'value': value,
    };
  }

  static MedicineReportItem fromMap(Map<String, dynamic> map) {
    return MedicineReportItem(
      medicineName: map['medicine_name'],
      currentStock: map['current_stock'],
      minimumStock: map['minimum_stock'],
      expiryDate: DateTime.parse(map['expiry_date']),
      value: map['value'],
    );
  }
}