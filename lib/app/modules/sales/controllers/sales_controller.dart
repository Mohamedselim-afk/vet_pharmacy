// lib/app/modules/sales/controllers/sales_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/medicine.dart';
import '../../../data/models/sale.dart';
import '../../../data/models/customer.dart';
import '../../../data/services/database_service.dart';

class SalesController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  final cartItems = <SaleItem>[].obs;
  final selectedMedicines = <Medicine>[].obs;
  final selectedCustomer = Rxn<Customer>();

  final total = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    ever(cartItems, (_) => _calculateTotal());
  }

  void _calculateTotal() {
    total.value = cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  Future<void> searchMedicines(String query) async {
    if (query.isEmpty) return;

    final medicines = await _databaseService.searchMedicines(query);
    if (medicines.isNotEmpty) {
      Get.dialog(
        AlertDialog(
          title: Text('نتائج البحث'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final medicine = medicines[index];
                return ListTile(
                  title: Text(medicine.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('سعر البيع: ${medicine.sellingPrice} جنيه'),
                      Text('سعر الشراء: ${medicine.purchasePrice} جنيه'),
                      Text('سعر السوق: ${medicine.marketPrice} جنيه'),
                    ],
                  ),
                  onTap: () {
                    Get.back();
                    addMedicineToCart(medicine);
                  },
                );
              },
            ),
          ),
        ),
      );
    }
  }

  void addMedicineToCart(Medicine medicine) {
    selectedMedicines.add(medicine);
    cartItems.add(SaleItem(
      medicineId: medicine.id!,
      quantity: 1,
      price: medicine.sellingPrice, 
    ));
}

  void removeMedicineFromCart(int index) {
    selectedMedicines.removeAt(index);
    cartItems.removeAt(index);
  }

  void updateItemQuantity(int index, int newQuantity) {
    if (newQuantity > 0 && newQuantity <= selectedMedicines[index].quantity) {
      final item = cartItems[index];
      cartItems[index] = SaleItem(
        medicineId: item.medicineId,
        quantity: newQuantity,
        price: item.price,
      );
    }
  }

  Future<void> searchCustomers(String query) async {
    if (query.isEmpty) return;

    final customers = await _databaseService.searchCustomers(query);
    Get.dialog(
      AlertDialog(
        title: Text('نتائج البحث'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text('إضافة عميل جديد'),
                onPressed: () {
                  Get.back();
                  addNewCustomer(query);
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return ListTile(
                      title: Text(customer.name),
                      subtitle:
                          customer.phone != null ? Text(customer.phone!) : null,
                      onTap: () {
                        selectedCustomer.value = customer;
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addNewCustomer(String name) async {
    final nameController = TextEditingController(text: name);
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text('إضافة عميل جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'اسم العميل'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'رقم الهاتف'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'العنوان'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('إلغاء'),
            onPressed: () => Get.back(result: false),
          ),
          ElevatedButton(
            child: Text('حفظ'),
            onPressed: () => Get.back(result: true),
          ),
        ],
      ),
    );

    if (result == true) {
      final customer = Customer(
        name: nameController.text,
        phone: phoneController.text,
        address: addressController.text,
      );

      final id = await _databaseService.insertCustomer(customer);
      selectedCustomer.value = Customer(
        id: id,
        name: customer.name,
        phone: customer.phone,
        address: customer.address,
      );
    }
  }

  Future<void> completeSale() async {
    if (cartItems.isEmpty || selectedCustomer.value == null) return;

    final sale = Sale(
      customerId: selectedCustomer.value?.id,
      date: DateTime.now(),
      items: cartItems,
      total: total.value,
    );

    await _databaseService.insertSale(sale);

    // Update medicine quantities
    for (var i = 0; i < cartItems.length; i++) {
      final medicine = selectedMedicines[i];
      await _databaseService.updateMedicineQuantity(
        medicine.id!,
        medicine.quantity - cartItems[i].quantity,
      );
    }

    // TODO: Implement invoice printing here

    Get.back();
  }
}
