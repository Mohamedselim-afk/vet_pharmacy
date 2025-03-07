class Supplier {
  final int? id;
  final String name;
  final String? phone;
  final String? address;
  final String? notes;

  Supplier({
    this.id,
    required this.name,
    this.phone,
    this.address,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone ?? '',
      'address': address ?? '',
      'notes': notes ?? '',
    };
  }

  static Supplier fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'],
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      notes: map['notes'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Supplier(id: $id, name: $name, phone: $phone, address: $address)';
  }
}