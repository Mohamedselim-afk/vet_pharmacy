// lib/models/sale.dart
import 'dart:ui';

class Sale {
  final int? id;
  final int? customerId;  
  final DateTime date;
  final List<SaleItem> items;
  final double total;

  Sale({
    this.id,
    this.customerId,
    required this.date,
    required this.items,
    required this.total,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'customer_id': customerId,
    'date': date.toIso8601String(),
    'total': total,
  };
}


class SaleItem {
  final int? id;
  final int medicineId;
  final int quantity;
  final double price;

  SaleItem({
    this.id,
    required this.medicineId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicine_id': medicineId,
      'quantity': quantity,
      'price': price,
    };
  }
}

class ChartData {
  final String name;
  final double value;
  final Color color;

  ChartData(this.name, this.value, this.color);
}