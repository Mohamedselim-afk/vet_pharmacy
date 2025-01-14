// lib/app/modules/supplier/views/supplier_details_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/supplier_controller.dart';
import '../../../data/models/supplier.dart';

class SupplierDetailsView extends GetView<SupplierController> {
  final Supplier supplier = Get.arguments;

  @override
  Widget build(BuildContext context) {
    controller.loadSupplierMedicines(supplier.id!);

    return Scaffold(
      appBar: AppBar(
        title: Text(supplier.name),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Supplier Summary Card
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: FutureBuilder<Map<String, dynamic>>(
                future: controller.getSupplierSummary(supplier.id!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ملخص الحساب',
                          style: Theme.of(context).textTheme.titleLarge),
                      Divider(),
                      _buildSummaryRow('إجمالي المشتريات',
                          '${data['total_amount'].toStringAsFixed(2)} جنيه'),
                      _buildSummaryRow('إجمالي المدفوع',
                          '${data['total_paid'].toStringAsFixed(2)} جنيه'),
                      _buildSummaryRow('المبلغ المتبقي',
                          '${data['remaining_amount'].toStringAsFixed(2)} جنيه',
                          isHighlighted: true),
                      _buildSummaryRow(
                          'عدد الأدوية', data['medicine_count'].toString()),
                    ],
                  );
                },
              ),
            ),
          ),

          // Medicines List
          Expanded(
            child: Obx(() => ListView.builder(
              itemCount: controller.supplierMedicines.length,
              itemBuilder: (context, index) {
                final medicine = controller.supplierMedicines[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(medicine.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الكمية: ${medicine.totalQuantity}'),
                        Text(
                            'المدفوع: ${medicine.amountPaid.toStringAsFixed(2)} من ${(medicine.totalQuantity * medicine.purchasePrice).toStringAsFixed(2)}'),
                      ],
                    ),
                    trailing: Text(
                      'متبقي: ${medicine.remainingAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: medicine.remainingAmount > 0 ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isHighlighted = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }
}