// lib/app/modules/supplier/views/suppliers_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/supplier_controller.dart';
import '../../../data/models/supplier.dart';

class SuppliersView extends GetView<SupplierController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('المناديب'),
        centerTitle: true,
      ),
      body: Obx(() => ListView.builder(
            itemCount: controller.suppliers.length,
            itemBuilder: (context, index) {
              final supplier = controller.suppliers[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(supplier.name),
                  subtitle:
                      supplier.phone != null ? Text(supplier.phone!) : null,
                  trailing: FutureBuilder<Map<String, dynamic>>(
                    future: controller.getSupplierSummary(supplier.id!),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }

                      final data = snapshot.data!;
                      // تحقق من القيم واستخدام قيم افتراضية في حالة null
                      final remainingAmount = data['remaining_amount'] ?? 0.0;
                      final medicineCount = data['medicine_count'] ?? 0;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'الباقي: ${(remainingAmount as num).toStringAsFixed(2)} جنيه'),
                          Text('عدد الأدوية: $medicineCount'),
                        ],
                      );
                    },
                  ),
                  onTap: () => Get.toNamed(
                    '/SUPPLIER_DETAILS',
                    arguments: supplier,
                  ),
                ),
              );
            },
          )),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddSupplierDialog(context),
      ),
    );
  }

  void _showAddSupplierDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('إضافة مندوب جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'اسم المندوب',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'العنوان',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('إلغاء'),
            onPressed: () => Get.back(),
          ),
          ElevatedButton(
            child: Text('إضافة'),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                controller.addSupplier(Supplier(
                  name: nameController.text,
                  phone: phoneController.text,
                  address: addressController.text,
                ));
                Get.back();
              } else {
                Get.snackbar(
                  'تنبيه',
                  'يرجى إدخال اسم المندوب',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
