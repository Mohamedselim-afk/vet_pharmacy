// lib/models/medicine.dart
class Medicine {
  final int? id;
  final String name;
  final String barcode;
  final int quantity;
  final double price;
  final String image;
  final DateTime expiryDate;

  Medicine({
    this.id,
    required this.name,
    required this.barcode,
    required this.quantity,
    required this.price,
    required this.image,
    required this.expiryDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'quantity': quantity,
      'price': price,
      'image': image,
      'expiry_date': expiryDate.toIso8601String(),
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'],
      name: map['name'],
      barcode: map['barcode'],
      quantity: map['quantity'],
      price: map['price'],
      image: map['image'],
      expiryDate: DateTime.parse(map['expiry_date']),
    );
  }
}