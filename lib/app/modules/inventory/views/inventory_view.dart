// lib/app/modules/inventory/views/inventory_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/inventory_controller.dart';
import '../../../routes/app_pages.dart';

class InventoryView extends GetView<InventoryController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('المخزون'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () => controller.generateInventoryReport(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'بحث عن دواء...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => controller.searchMedicines(value),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.medicines.isEmpty) {
                return Center(child: Text('لا يوجد أدوية في المخزون'));
              }

              return ListView.builder(
                itemCount: controller.medicines.length,
                itemBuilder: (context, index) {
                  final medicine = controller.medicines[index];
                  final daysUntilExpiry = medicine.expiryDate
                      .difference(DateTime.now()).inDays;

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: FileImage(File(medicine.image)),
                      ),
                      title: Text(medicine.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('الكمية: ${medicine.quantity}'),
                          Text('السعر: ${medicine.price} جنيه'),
                          Text(
                            'تاريخ الانتهاء: ${DateFormat('dd/MM/yyyy').format(medicine.expiryDate)}',
                            style: TextStyle(
                              color: daysUntilExpiry <= 30 ? Colors.red : null,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => Get.toNamed(
                              Routes.EDIT_MEDICINE,
                              arguments: medicine,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () => controller.deleteMedicine(medicine),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Get.toNamed(Routes.ADD_MEDICINE),
      ),
    );
  }
}