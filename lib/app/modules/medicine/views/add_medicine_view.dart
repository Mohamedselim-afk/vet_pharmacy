// lib/app/modules/medicine/views/add_medicine_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../routes/app_pages.dart';
import '../controllers/medicine_controller.dart';
import '../../../data/models/supplier.dart';

class AddMedicineView extends GetView<MedicineController> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'إضافة دواء جديد',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Get.theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Indicator
              _buildProgressIndicator(),
              SizedBox(height: 24),

              // Supplier Selection Section
              _buildSectionCard(
                title: 'اختيار المندوب',
                icon: Icons.person_outline,
                child: _buildSupplierField(),
              ),
              SizedBox(height: 16),

              // Basic Information Section
              _buildSectionCard(
                title: 'المعلومات الأساسية',
                icon: Icons.medication_outlined,
                child: _buildBasicInfoSection(),
              ),
              SizedBox(height: 16),

              // Pricing Section
              _buildSectionCard(
                title: 'معلومات التسعير',
                icon: Icons.attach_money_outlined,
                child: _buildPricingSection(),
              ),
              SizedBox(height: 16),

              // Quantity and Payment Section
              _buildSectionCard(
                title: 'الكمية والدفع',
                icon: Icons.inventory_2_outlined,
                child: _buildQuantityAndPaymentSection(),
              ),
              SizedBox(height: 16),

              // Expiry and Image Section
              _buildSectionCard(
                title: 'الصلاحية والصورة',
                icon: Icons.calendar_today_outlined,
                child: _buildExpiryAndImageSection(),
              ),
              SizedBox(height: 24),

              // Save Button
              _buildSaveButton(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Get.theme.primaryColor),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'يرجى ملء جميع الحقول المطلوبة لإضافة الدواء',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Get.theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Get.theme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Get.theme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierField() {
    return Obx(() {
      if (controller.suppliers.isEmpty) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_outlined, color: Colors.red),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'لا يوجد مناديب',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'اضغط لإضافة مندوب جديد',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.red, size: 16),
            ],
          ),
        );
      }

      return Column(
        children: [
          DropdownButtonFormField<int>(
            value: controller.selectedSupplierId.value,
            decoration: InputDecoration(
              labelText: 'اختيار المندوب',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.person_outline),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            items: controller.suppliers.map((supplier) {
              return DropdownMenuItem<int>(
                value: supplier.id,
                child: Text(supplier.name),
              );
            }).toList(),
            onChanged: (value) {
              controller.selectedSupplierId.value = value;
            },
            validator: (value) {
              if (value == null) {
                return 'يرجى اختيار المندوب';
              }
              return null;
            },
          ),
          SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _showAddSupplierDialog(),
            icon: Icon(Icons.add),
            label: Text('إضافة مندوب جديد'),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        _buildCustomTextField(
          labelText: 'اسم الدواء',
          prefixIcon: Icons.medication_outlined,
          onChanged: controller.setName,
          validator: (value) =>
              value?.isEmpty ?? true ? 'يرجى إدخال اسم الدواء' : null,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildCustomTextField(
                labelText: 'الباركود',
                prefixIcon: Icons.qr_code_outlined,
                onChanged: controller.setBarcode,
              ),
            ),
            SizedBox(width: 12),
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: Get.theme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.qr_code_scanner, color: Colors.white),
                onPressed: () async {
                  // Implement barcode scanning
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCustomTextField(
                labelText: 'سعر الشراء',
                prefixIcon: Icons.shopping_cart_outlined,
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    controller.setPurchasePrice(double.tryParse(value) ?? 0),
                validator: (value) => _validatePrice(value),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildCustomTextField(
                labelText: 'سعر البيع',
                prefixIcon: Icons.sell_outlined,
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    controller.setSellingPrice(double.tryParse(value) ?? 0),
                validator: (value) => _validatePrice(value),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildCustomTextField(
                labelText: 'سعر السوق',
                prefixIcon: Icons.storefront_outlined,
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    controller.setMarketPrice(double.tryParse(value) ?? 0),
                validator: (value) => _validatePrice(value),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Obx(() {
                final profit = controller.calculateProfit();
                return Container(
                  height: 56,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: profit > 0
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: profit > 0
                          ? Colors.green.withOpacity(0.3)
                          : Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'المكسب للقطعة',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '${profit.toStringAsFixed(2)} جنيه',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: profit > 0 ? Colors.green : Colors.red,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityAndPaymentSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCustomTextField(
                labelText: 'كمية العلبة',
                prefixIcon: Icons.inventory_2_outlined,
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    controller.setBoxQuantity(int.tryParse(value) ?? 0),
                validator: (value) => _validateQuantity(value),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildCustomTextField(
                labelText: 'سعر العلبة',
                prefixIcon: Icons.price_change_outlined,
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    controller.setBoxPrice(double.tryParse(value) ?? 0),
                validator: (value) => _validatePrice(value),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildCustomTextField(
                labelText: 'الكمية الكلية',
                prefixIcon: Icons.production_quantity_limits_outlined,
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    controller.setTotalQuantity(int.tryParse(value) ?? 0),
                validator: (value) => _validateQuantity(value),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildCustomTextField(
                labelText: 'المبلغ المدفوع',
                prefixIcon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    controller.setAmountPaid(double.tryParse(value) ?? 0),
                validator: (value) => _validatePrice(value),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Obx(() {
          final remaining = controller.calculateRemainingAmount();
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: remaining > 0
                  ? Colors.orange.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: remaining > 0
                    ? Colors.orange.withOpacity(0.3)
                    : Colors.green.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  remaining > 0
                      ? Icons.warning_outlined
                      : Icons.check_circle_outlined,
                  color: remaining > 0 ? Colors.orange : Colors.green,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المبلغ المتبقي',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '${remaining.toStringAsFixed(2)} جنيه',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: remaining > 0 ? Colors.orange : Colors.green,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildExpiryAndImageSection() {
    return Column(
      children: [
        Obx(() => InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: Get.context!,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 3650)),
                );
                if (date != null) {
                  controller.setExpiryDate(date);
                }
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        color: Get.theme.primaryColor),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تاريخ انتهاء الصلاحية',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 4),
                          Text(
                            controller.expiryDate.value == null
                                ? 'اضغط لتحديد التاريخ'
                                : DateFormat('dd/MM/yyyy')
                                    .format(controller.expiryDate.value!),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: controller.expiryDate.value == null
                                  ? Colors.grey[500]
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey[400]),
                  ],
                ),
              ),
            )),
        SizedBox(height: 16),
        Obx(() {
          if (controller.imagePath.value != null) {
            return Column(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(controller.imagePath.value!),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon:
                                Icon(Icons.delete_outline, color: Colors.white),
                            onPressed: controller.clearImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
              ],
            );
          }
          return Container();
        }),
        ElevatedButton.icon(
          icon: Icon(Icons.camera_alt_outlined),
          label: Text('التقاط صورة الدواء'),
          onPressed: controller.pickImage,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 56),
            backgroundColor: Get.theme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomTextField({
    required String labelText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Get.theme.primaryColor,
            Get.theme.primaryColor.withOpacity(0.8)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Get.theme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          if (_formKey.currentState!.validate() && _validateForm()) {
            controller.saveMedicine();
          }
        },
        icon: Icon(Icons.save_outlined, color: Colors.white),
        label: Text(
          'حفظ الدواء',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    if (double.tryParse(value) == null || double.parse(value) <= 0) {
      return 'يرجى إدخال سعر صحيح';
    }
    return null;
  }

  String? _validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    if (int.tryParse(value) == null || int.parse(value) <= 0) {
      return 'يرجى إدخال كمية صحيحة';
    }
    return null;
  }

  bool _validateForm() {
    if (controller.expiryDate.value == null) {
      Get.snackbar(
        'خطأ',
        'يرجى تحديد تاريخ انتهاء الصلاحية',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return false;
    }
    if (controller.imagePath.value == null) {
      Get.snackbar(
        'خطأ',
        'يرجى التقاط صورة للدواء',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  void _showAddSupplierDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Get.theme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.person_add, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'إضافة مندوب جديد',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              _buildCustomTextField(
                labelText: 'اسم المندوب',
                prefixIcon: Icons.person_outline,
                onChanged: (value) => nameController.text = value,
              ),
              SizedBox(height: 16),
              _buildCustomTextField(
                labelText: 'رقم الهاتف',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                onChanged: (value) => phoneController.text = value,
              ),
              SizedBox(height: 16),
              _buildCustomTextField(
                labelText: 'العنوان',
                prefixIcon: Icons.location_on_outlined,
                onChanged: (value) => addressController.text = value,
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      child: Text('إلغاء'),
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      child: Text('إضافة'),
                      onPressed: () async {
                        if (nameController.text.isNotEmpty) {
                          final id = await controller.addNewSupplier(
                            nameController.text,
                            phoneController.text,
                            addressController.text,
                          );

                          if (id != null) {
                            Get.back();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(0, 48),
                        backgroundColor: Get.theme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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
}
// // lib/app/modules/medicine/views/add_medicine_view.dart
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import '../../../routes/app_pages.dart';
// import '../controllers/medicine_controller.dart';
// import '../../../data/models/supplier.dart';

// class AddMedicineView extends GetView<MedicineController> {
//   final _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('إضافة دواء جديد'),
//         centerTitle: true,
//       ),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: EdgeInsets.all(16),
//           children: [
//             // اختيار المندوب
//             _buildSupplierField(), 
//             // _buildSupplierDropdown(),
//             SizedBox(height: 16),

//             // معلومات الدواء الأساسية
//             _buildBasicInfoSection(),
//             SizedBox(height: 16),

//             // معلومات التسعير
//             _buildPricingSection(),
//             SizedBox(height: 16),

//             // معلومات الكمية والدفع
//             _buildQuantityAndPaymentSection(),
//             SizedBox(height: 16),

//             // تاريخ الصلاحية والصورة
//             _buildExpiryAndImageSection(),
//             SizedBox(height: 16),

//             // زر الحفظ
//             _buildSaveButton(),
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget _buildSupplierDropdown() {
//   //   return Obx(() => DropdownButtonFormField<int>(
//   //         value: controller.selectedSupplierId.value,
//   //         decoration: InputDecoration(
//   //           labelText: 'المندوب',
//   //           border: OutlineInputBorder(),
//   //           prefixIcon: Icon(Icons.person),
//   //         ),
//   //         items: controller.suppliers
//   //             .map((supplier) => DropdownMenuItem(
//   //                   value: supplier.id,
//   //                   child: Text(supplier.name),
//   //                 ))
//   //             .toList(),
//   //         onChanged: (value) => controller.selectedSupplierId.value = value!,
//   //         validator: (value) =>
//   //             value == null ? 'يرجى اختيار المندوب' : null,
//   //       ));
//   // }

//   Widget _buildBasicInfoSection() {
//     return Column(
//       children: [
//         TextFormField(
//           decoration: InputDecoration(
//             labelText: 'اسم الدواء',
//             border: OutlineInputBorder(),
//             prefixIcon: Icon(Icons.medication),
//           ),
//           onChanged: controller.setName,
//           validator: (value) =>
//               value?.isEmpty ?? true ? 'يرجى إدخال اسم الدواء' : null,
//         ),
//         SizedBox(height: 16),
//         Row(
//           children: [
//             Expanded(
//               child: TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'الباركود',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.qr_code),
//                 ),
//                 onChanged: controller.setBarcode,
//               ),
//             ),
//             IconButton(
//               icon: Icon(Icons.qr_code_scanner),
//               onPressed: () async {
//                 // Implement barcode scanning
//               },
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildPricingSection() {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'سعر الشراء',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.money),
//                 ),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) => controller.setPurchasePrice(double.tryParse(value) ?? 0),
//                 validator: (value) => _validatePrice(value),
//               ),
//             ),
//             SizedBox(width: 16),
//             Expanded(
//               child: TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'سعر البيع',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.sell),
//                 ),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) => controller.setSellingPrice(double.tryParse(value) ?? 0),
//                 validator: (value) => _validatePrice(value),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 16),
//         Row(
//           children: [
//             Expanded(
//               child: TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'سعر السوق',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.storefront),
//                 ),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) => controller.setMarketPrice(double.tryParse(value) ?? 0),
//                 validator: (value) => _validatePrice(value),
//               ),
//             ),
//             SizedBox(width: 16),
//             Expanded(
//               child: Obx(() {
//                 final profit = controller.calculateProfit();
//                 return Container(
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('المكسب للقطعة:'),
//                       Text(
//                         '${profit.toStringAsFixed(2)} جنيه',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: profit > 0 ? Colors.green : Colors.red,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildQuantityAndPaymentSection() {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'كمية العلبة',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.inventory_2),
//                 ),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) => controller.setBoxQuantity(int.tryParse(value) ?? 0),
//                 validator: (value) => _validateQuantity(value),
//               ),
//             ),
//             SizedBox(width: 16),
//             Expanded(
//               child: TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'سعر العلبة',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.inventory),
//                 ),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) => controller.setBoxPrice(double.tryParse(value) ?? 0),
//                 validator: (value) => _validatePrice(value),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 16),
//         Row(
//           children: [
//             Expanded(
//               child: TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'الكمية الكلية',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.production_quantity_limits),
//                 ),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) => controller.setTotalQuantity(int.tryParse(value) ?? 0),
//                 validator: (value) => _validateQuantity(value),
//               ),
//             ),
//             SizedBox(width: 16),
//             Expanded(
//               child: TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'المبلغ المدفوع',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.payments),
//                 ),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) => controller.setAmountPaid(double.tryParse(value) ?? 0),
//                 validator: (value) => _validatePrice(value),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 16),
//         Obx(() {
//           final remaining = controller.calculateRemainingAmount();
//           return Container(
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(4),
//               color: remaining > 0 ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('المبلغ المتبقي:'),
//                 Text(
//                   '${remaining.toStringAsFixed(2)} جنيه',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: remaining > 0 ? Colors.red : Colors.green,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }),
//       ],
//     );
//   }

//   Widget _buildExpiryAndImageSection() {
//     return Column(
//       children: [
//         Obx(() => ListTile(
//               title: Text(
//                 controller.expiryDate.value == null
//                     ? 'تاريخ انتهاء الصلاحية'
//                     : 'تاريخ الانتهاء: ${DateFormat('dd/MM/yyyy').format(controller.expiryDate.value!)}',
//               ),
//               trailing: Icon(Icons.calendar_today),
//               tileColor: Colors.grey[200],
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 side: BorderSide(color: Colors.grey),
//               ),
//               onTap: () async {
//                 final date = await showDatePicker(
//                   context: Get.context!,
//                   initialDate: DateTime.now(),
//                   firstDate: DateTime.now(),
//                   lastDate: DateTime.now().add(Duration(days: 3650)),
//                 );
//                 if (date != null) {
//                   controller.setExpiryDate(date);
//                 }
//               },
//             )),
//         SizedBox(height: 16),
//         Obx(() {
//           if (controller.imagePath.value != null) {
//             return Stack(
//               alignment: Alignment.topRight,
//               children: [
//                 Image.file(
//                   File(controller.imagePath.value!),
//                   height: 200,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.delete, color: Colors.red),
//                   onPressed: controller.clearImage,
//                 ),
//               ],
//             );
//           }
//           return Container();
//         }),
//         ElevatedButton.icon(
//           icon: Icon(Icons.camera_alt),
//           label: Text('التقاط صورة'),
//           onPressed: controller.pickImage,
//           style: ElevatedButton.styleFrom(
//             minimumSize: Size(double.infinity, 45),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSaveButton() {
//     return ElevatedButton(
//       onPressed: () {
//         if (_formKey.currentState!.validate() && _validateForm()) {
//           controller.saveMedicine();
//         }
//       },
//       child: Padding(
//         padding: EdgeInsets.symmetric(vertical: 12),
//         child: Text(
//           'حفظ الدواء',
//           style: TextStyle(fontSize: 18),
//         ),
//       ),
//       style: ElevatedButton.styleFrom(
//         minimumSize: Size(double.infinity, 45),
//       ),
//     );
//   }

//   String? _validatePrice(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'هذا الحقل مطلوب';
//     }
//     if (double.tryParse(value) == null || double.parse(value) <= 0) {
//       return 'يرجى إدخال سعر صحيح';
//     }
//     return null;
//   }

//   String? _validateQuantity(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'هذا الحقل مطلوب';
//     }
//     if (int.tryParse(value) == null || int.parse(value) <= 0) {
//       return 'يرجى إدخال كمية صحيحة';
//     }
//     return null;
//   }

//   bool _validateForm() {
//     if (controller.expiryDate.value == null) {
//       Get.snackbar(
//         'خطأ',
//         'يرجى تحديد تاريخ انتهاء الصلاحية',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return false;
//     }
//     if (controller.imagePath.value == null) {
//       Get.snackbar(
//         'خطأ',
//         'يرجى التقاط صورة للدواء',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return false;
//     }
//     return true;
//   }

//     Widget _buildSupplierField() {
//     return Obx(() {
//       if (controller.suppliers.isEmpty) {
//         return ListTile(
//           title: Text(
//             'لا يوجد مناديب - اضغط لإضافة مندوب',
//             style: TextStyle(color: Colors.red),
//           ),
//           leading: Icon(Icons.warning, color: Colors.red),
//           onTap: () => _showAddSupplierDialog(),
//         );
//       }

//       return DropdownButtonFormField<int>(
//         value: controller.selectedSupplierId.value,
//         decoration: InputDecoration(
//           labelText: 'المندوب',
//           border: OutlineInputBorder(),
//           prefixIcon: Icon(Icons.person),
//           suffixIcon: IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () => _showAddSupplierDialog(),
//           ),
//         ),
//         items: controller.suppliers.map((supplier) {
//           return DropdownMenuItem<int>(
//             value: supplier.id,
//             child: Text(supplier.name),
//           );
//         }).toList(),
//         onChanged: (value) {
//           controller.selectedSupplierId.value = value;
//         },
//         validator: (value) {
//           if (value == null) {
//             return 'يرجى اختيار المندوب';
//           }
//           return null;
//         },
//       );
//     });
//   }

//    void _showAddSupplierDialog() {
//     final nameController = TextEditingController();
//     final phoneController = TextEditingController();
//     final addressController = TextEditingController();

//     Get.dialog(
//       AlertDialog(
//         title: Text('إضافة مندوب جديد'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: nameController,
//                 decoration: InputDecoration(
//                   labelText: 'اسم المندوب',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               SizedBox(height: 16),
//               TextField(
//                 controller: phoneController,
//                 decoration: InputDecoration(
//                   labelText: 'رقم الهاتف',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.phone,
//               ),
//               SizedBox(height: 16),
//               TextField(
//                 controller: addressController,
//                 decoration: InputDecoration(
//                   labelText: 'العنوان',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 2,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             child: Text('إلغاء'),
//             onPressed: () => Get.back(),
//           ),
//           ElevatedButton(
//             child: Text('إضافة'),
//             onPressed: () async {
//               if (nameController.text.isNotEmpty) {
//                 final id = await controller.addNewSupplier(
//                   nameController.text,
//                   phoneController.text,
//                   addressController.text,
//                 );
                
//                 if (id != null) {
//                   Get.back();
//                 }
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }