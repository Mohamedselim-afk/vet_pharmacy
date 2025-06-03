// lib/app/modules/supplier/views/supplier_details_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/supplier_controller.dart';
import '../../../data/models/supplier.dart';

class SupplierDetailsView extends GetView<SupplierController> {
  final Supplier supplier = Get.arguments;

  @override
  Widget build(BuildContext context) {
    controller.loadSupplierMedicines(supplier.id!);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar with supplier info
          SliverAppBar(
            expandedHeight: 150,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    supplier.name,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (supplier.phone != null &&
                                      supplier.phone!.isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.phone,
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            size: 16,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            supplier.phone!,
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.white),
                onPressed: () => _showEditSupplierDialog(),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  switch (value) {
                    case 'payment':
                      _showPaymentDialog();
                      break;
                    case 'statement':
                      _generateStatement();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'payment',
                    child: Row(
                      children: [
                        Icon(Icons.payment, size: 20),
                        SizedBox(width: 8),
                        Text('إضافة دفعة'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'statement',
                    child: Row(
                      children: [
                        Icon(Icons.receipt_long, size: 20),
                        SizedBox(width: 8),
                        Text('كشف حساب'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.05),
                    Colors.grey[50]!,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Supplier Contact Info
                  _buildContactInfoCard(),

                  // Financial Summary
                  _buildFinancialSummary(),

                  // Medicines List
                  _buildMedicinesSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard() {
    if ((supplier.address?.isEmpty ?? true) &&
        (supplier.notes?.isEmpty ?? true)) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  'معلومات التواصل',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            Divider(height: 20),
            if (supplier.address != null && supplier.address!.isNotEmpty)
              _buildInfoRow(Icons.location_on, 'العنوان', supplier.address!),
            if (supplier.notes != null && supplier.notes!.isNotEmpty)
              _buildInfoRow(Icons.note, 'ملاحظات', supplier.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: FutureBuilder<Map<String, dynamic>>(
          future: controller.getSupplierSummary(supplier.id!),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final data = snapshot.data!;
            final totalAmount = data['total_amount'] ?? 0.0;
            final totalPaid = data['total_paid'] ?? 0.0;
            final remainingAmount = data['remaining_amount'] ?? 0.0;
            final medicineCount = data['medicine_count'] ?? 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet,
                        color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'الملخص المالي',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                Divider(height: 20),

                // Financial Cards Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildFinancialCard(
                        'إجمالي المشتريات',
                        '${totalAmount.toStringAsFixed(0)} جنيه',
                        Colors.blue,
                        Icons.shopping_cart,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildFinancialCard(
                        'إجمالي المدفوع',
                        '${totalPaid.toStringAsFixed(0)} جنيه',
                        Colors.green,
                        Icons.payment,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildFinancialCard(
                        'المبلغ المتبقي',
                        '${remainingAmount.toStringAsFixed(0)} جنيه',
                        remainingAmount > 0 ? Colors.red : Colors.green,
                        Icons.account_balance,
                        isHighlighted: true,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildFinancialCard(
                        'عدد الأدوية',
                        '$medicineCount صنف',
                        Colors.purple,
                        Icons.medical_services,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFinancialCard(
    String title,
    String value,
    Color color,
    IconData icon, {
    bool isHighlighted = false,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted ? Border.all(color: color, width: 1.5) : null,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMedicinesSection() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.medication, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text(
                  'قائمة الأدوية',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          _buildMedicinesList(),
        ],
      ),
    );
  }

  Widget _buildMedicinesList() {
    return Obx(() {
      if (controller.supplierMedicines.isEmpty) {
        return Container(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.medical_services_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'لا توجد أدوية لهذا المندوب',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'ابدأ بإضافة أدوية جديدة',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: controller.supplierMedicines.length,
        separatorBuilder: (context, index) => Divider(height: 1),
        itemBuilder: (context, index) {
          final medicine = controller.supplierMedicines[index];
          return _buildMedicineCard(medicine);
        },
      );
    });
  }

  Widget _buildMedicineCard(medicine) {
    final totalCost = medicine.totalQuantity * medicine.purchasePrice;
    final paymentPercentage =
        totalCost > 0 ? (medicine.amountPaid / totalCost) : 0.0;

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  medicine.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: medicine.remainingAmount > 0
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  medicine.remainingAmount > 0 ? 'مستحق' : 'مسدد',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: medicine.remainingAmount > 0
                        ? Colors.red[700]
                        : Colors.green[700],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Medicine Details
          Row(
            children: [
              Expanded(
                child: _buildMedicineDetailItem(
                  'الكمية',
                  '${medicine.totalQuantity}',
                  Icons.inventory,
                ),
              ),
              Expanded(
                child: _buildMedicineDetailItem(
                  'سعر الشراء',
                  '${medicine.purchasePrice.toStringAsFixed(2)}',
                  Icons.money,
                ),
              ),
            ],
          ),

          SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _buildMedicineDetailItem(
                  'إجمالي التكلفة',
                  '${totalCost.toStringAsFixed(2)} جنيه',
                  Icons.calculate,
                ),
              ),
              Expanded(
                child: _buildMedicineDetailItem(
                  'المبلغ المتبقي',
                  '${medicine.remainingAmount.toStringAsFixed(2)} جنيه',
                  Icons.account_balance_wallet,
                  valueColor:
                      medicine.remainingAmount > 0 ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Payment Progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تقدم السداد',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(paymentPercentage * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: paymentPercentage >= 1.0
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              LinearProgressIndicator(
                value: paymentPercentage,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  paymentPercentage >= 1.0 ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),

          if (medicine.remainingAmount > 0)
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: ElevatedButton.icon(
                onPressed: () => _showMedicinePaymentDialog(medicine),
                icon: Icon(Icons.payment, size: 16),
                label: Text('إضافة دفعة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicineDetailItem(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditSupplierDialog() {
    final nameController = TextEditingController(text: supplier.name);
    final phoneController = TextEditingController(text: supplier.phone ?? '');
    final addressController =
        TextEditingController(text: supplier.address ?? '');
    final notesController = TextEditingController(text: supplier.notes ?? '');

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تعديل بيانات المندوب',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'الاسم',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'الهاتف',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'العنوان',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'ملاحظات',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text('إلغاء'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final updatedSupplier = Supplier(
                          id: supplier.id,
                          name: nameController.text,
                          phone: phoneController.text,
                          address: addressController.text,
                          notes: notesController.text,
                        );
                        controller.updateSupplier(updatedSupplier);
                        Get.back();
                      },
                      child: Text('حفظ'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentDialog() {
    // Implementation for general payment dialog
  }

  void _showMedicinePaymentDialog(medicine) {
    final amountController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'إضافة دفعة - ${medicine.name}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'المبلغ المتبقي: ${medicine.remainingAmount.toStringAsFixed(2)} جنيه',
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'مبلغ الدفعة',
                  border: OutlineInputBorder(),
                  suffixText: 'جنيه',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text('إلغاء'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final amount = double.tryParse(amountController.text);
                        if (amount != null && amount > 0) {
                          controller.addPaymentForMedicine(
                              medicine.id!, amount);
                          Get.back();
                        }
                      },
                      child: Text('إضافة'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generateStatement() {
    // Implementation for generating supplier statement
    Get.snackbar(
      'قريباً',
      'ستتوفر هذه الميزة قريباً',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

  // // lib/app/modules/supplier/views/supplier_details_view.dart
  // import 'package:flutter/material.dart';
  // import 'package:get/get.dart';
  // import '../controllers/supplier_controller.dart';
  // import '../../../data/models/supplier.dart';

  // class SupplierDetailsView extends GetView<SupplierController> {
  //   final Supplier supplier = Get.arguments;

  //   @override
  //   Widget build(BuildContext context) {
  //     controller.loadSupplierMedicines(supplier.id!);

  //     return Scaffold(
  //       appBar: AppBar(
  //         title: Text(supplier.name),
  //         centerTitle: true,
  //       ),
  //       body: Column(
  //         children: [
  //           // Supplier Summary Card - نستخدم Container مع حجم محدد
  //           Container(
  //             constraints: BoxConstraints(maxHeight: 300), // تحديد ارتفاع أقصى
  //             child: Card(
  //               margin: EdgeInsets.all(16),
  //               child: Padding(
  //                 padding: EdgeInsets.all(16),
  //                 child: FutureBuilder<Map<String, dynamic>>(
  //                   future: controller.getSupplierSummary(supplier.id!),
  //                   builder: (context, snapshot) {
  //                     if (!snapshot.hasData) {
  //                       return Center(child: CircularProgressIndicator());
  //                     }

  //                     final data = snapshot.data!;
  //                     return Column(
  //                       mainAxisSize: MainAxisSize.min, // مهم!
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text('ملخص الحساب',
  //                             style: Theme.of(context).textTheme.titleLarge),
  //                         Divider(),
  //                         _buildSummaryRow('إجمالي المشتريات',
  //                             '${(data['total_amount'] ?? 0.0).toStringAsFixed(2)} جنيه'),
  //                         _buildSummaryRow('إجمالي المدفوع',
  //                             '${(data['total_paid'] ?? 0.0).toStringAsFixed(2)} جنيه'),
  //                         _buildSummaryRow(
  //                             'المبلغ المتبقي',
  //                             '${(data['remaining_amount'] ?? 0.0).toStringAsFixed(2)} جنيه',
  //                             isHighlighted: true),
  //                         _buildSummaryRow(
  //                             'عدد الأدوية', '${data['medicine_count'] ?? 0}'),
  //                       ],
  //                     );
  //                   },
  //                 ),
  //               ),
  //             ),
  //           ),

  //           // Medicines List - باقي المساحة
  //           Expanded(
  //             child: Obx(() {
  //               if (controller.supplierMedicines.isEmpty) {
  //                 return Center(child: Text('لا توجد أدوية لهذا المندوب'));
  //               }
                
  //               return ListView.builder(
  //                 itemCount: controller.supplierMedicines.length,
  //                 itemBuilder: (context, index) {
  //                   final medicine = controller.supplierMedicines[index];
  //                   return Card(
  //                     margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //                     child: ListTile(
  //                       title: Text(medicine.name),
  //                       subtitle: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         mainAxisSize: MainAxisSize.min, // مهم!
  //                         children: [
  //                           Text('الكمية: ${medicine.totalQuantity}'),
  //                           Text(
  //                             'المدفوع: ${medicine.amountPaid.toStringAsFixed(2)} من ${(medicine.totalQuantity * medicine.purchasePrice).toStringAsFixed(2)}',
  //                             softWrap: true, // للنص الطويل
  //                           ),
  //                         ],
  //                       ),
  //                       trailing: Container(
  //                         width: 120, // تحديد عرض ثابت
  //                         child: Text(
  //                           'متبقي: ${medicine.remainingAmount.toStringAsFixed(2)}',
  //                           style: TextStyle(
  //                             color: medicine.remainingAmount > 0 ? Colors.red : Colors.green,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                           softWrap: true,
  //                         ),
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               );
  //             }),
  //           ),
  //         ],
  //       ),
  //     );
  //   }

  //   Widget _buildSummaryRow(String label, String value, {bool isHighlighted = false}) {
  //     return Padding(
  //       padding: EdgeInsets.symmetric(vertical: 4),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Expanded(
  //             child: Text(label),
  //           ),
  //           Expanded(
  //             child: Text(
  //               value,
  //               textAlign: TextAlign.end,
  //               style: TextStyle(
  //                 fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
  //                 color: isHighlighted ? Colors.red : null,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }