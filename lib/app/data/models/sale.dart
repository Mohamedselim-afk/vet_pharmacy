
import 'package:get/get.dart';
import 'package:flutter/material.dart';

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'date': date.toIso8601String(),
      'total': total,
    };
  }

  static Sale fromMap(Map<String, dynamic> map, List<SaleItem> items) {
    return Sale(
      id: map['id'],
      customerId: map['customer_id'],
      date: DateTime.parse(map['date']),
      items: items,
      total: map['total'],
    );
  }

  Sale copyWith({
    int? id,
    int? customerId,
    DateTime? date,
    List<SaleItem>? items,
    double? total,
  }) {
    return Sale(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      date: date ?? this.date,
      items: items ?? this.items,
      total: total ?? this.total,
    );
  }
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

  static SaleItem fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'],
      medicineId: map['medicine_id'],
      quantity: map['quantity'],
      price: map['price'],
    );
  }

  double get total => quantity * price;

  SaleItem copyWith({
    int? id,
    int? medicineId,
    int? quantity,
    double? price,
  }) {
    return SaleItem(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }
}
