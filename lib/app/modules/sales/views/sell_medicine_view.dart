// lib/app/modules/sales/views/sell_medicine_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sales_controller.dart';

class SellMedicineView extends GetView<SalesController> {
  final TextEditingController _customerSearchController =
      TextEditingController();
  final TextEditingController _medicineSearchController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('بيع دواء')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _customerSearchController,
                  decoration: InputDecoration(
                    labelText: 'بحث/إضافة عميل',
                    prefixIcon: Icon(Icons.person_search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (query) => controller.searchCustomers(query),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _medicineSearchController,
                  decoration: InputDecoration(
                    labelText: 'بحث عن دواء',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (query) => controller.searchMedicines(query),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: controller.selectedMedicines.length,
                  itemBuilder: (context, index) {
                    final medicine = controller.selectedMedicines[index];
                    final item = controller.cartItems[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        leading: Image.file(File(medicine.image)),
                        title: Text(medicine.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('سعر البيع: ${medicine.sellingPrice} جنيه'),
                            Text('سعر الشراء: ${medicine.purchasePrice} جنيه'),
                            Text('سعر السوق: ${medicine.marketPrice} جنيه'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                if (item.quantity > 1) {
                                  controller.updateItemQuantity(
                                    index,
                                    item.quantity - 1,
                                  );
                                }
                              },
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                if (item.quantity < medicine.quantity) {
                                  controller.updateItemQuantity(
                                    index,
                                    item.quantity + 1,
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () =>
                                  controller.removeMedicineFromCart(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Obx(() {
                  if (controller.selectedCustomer.value != null) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'العميل: ${controller.selectedCustomer.value!.name}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                }),
                Obx(() => Text(
                      'الإجمالي: ${controller.total.value} جنيه',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.camera_alt),
                        label: Text('مسح باركود'),
                        onPressed: () {
                          // TODO: Implement barcode scanning
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Obx(() => ElevatedButton.icon(
                            icon: Icon(Icons.check),
                            label: Text('إتمام البيع'),
                            onPressed: controller.cartItems.isNotEmpty
                                ? () => controller.completeSale()
                                : null,
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
