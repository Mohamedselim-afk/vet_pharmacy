// lib/app/data/models/medicine.dart
class Medicine {
  final int? id;
  final String name;
  final String barcode;
  final int quantity;
  final double marketPrice;    // سعر السوق
  final double sellingPrice;   // سعر البيع
  final double purchasePrice;  // سعر الشراء
  final int boxQuantity;       // كمية العلبة الواحدة
  final double boxPrice;       // سعر العلبة الواحدة
  final int totalQuantity;     // الكمية الكلية
  final double amountPaid;     // المبلغ المدفوع
  final int supplierId;        // معرف المندوب
  final String image;
  final DateTime expiryDate;

  Medicine({
    this.id,
    required this.name,
    required this.barcode,
    required this.quantity,
    required this.marketPrice,
    required this.sellingPrice,
    required this.purchasePrice,
    required this.boxQuantity,
    required this.boxPrice,
    required this.totalQuantity,
    required this.amountPaid,
    required this.supplierId,
    required this.image,
    required this.expiryDate,
  });

  double get remainingAmount => (totalQuantity * purchasePrice) - amountPaid;
  double get profit => sellingPrice - purchasePrice;
  double get totalProfit => profit * quantity;
  double get totalValue => quantity * purchasePrice;
  double get price => sellingPrice;


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'quantity': quantity,
      'market_price': marketPrice,
      'selling_price': sellingPrice,
      'purchase_price': purchasePrice,
      'box_quantity': boxQuantity,
      'box_price': boxPrice,
      'total_quantity': totalQuantity,
      'amount_paid': amountPaid,
      'supplier_id': supplierId,
      'image': image,
      'expiry_date': expiryDate.toIso8601String(),
    };
  }

  static Medicine fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'],
      name: map['name'],
      barcode: map['barcode'],
      quantity: map['quantity'],
      marketPrice: map['market_price'],
      sellingPrice: map['selling_price'],
      purchasePrice: map['purchase_price'],
      boxQuantity: map['box_quantity'],
      boxPrice: map['box_price'],
      totalQuantity: map['total_quantity'],
      amountPaid: map['amount_paid'],
      supplierId: map['supplier_id'],
      image: map['image'],
      expiryDate: DateTime.parse(map['expiry_date']),
    );
  }
}