// lib/app/modules/medicine/views/edit_medicine_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/medicine_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../data/models/medicine.dart';
import '../../shared/views/barcode_scanner_view.dart';

class EditMedicineView extends GetView<MedicineController> {
  final Medicine medicine = Get.arguments;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Initialize controller with medicine data
    controller.initializeForEdit(medicine);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'تعديل دواء',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Get.theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () => _showDeleteConfirmation(),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medicine Info Header
              _buildMedicineHeader(),
              SizedBox(height: 24),

              // Basic Information Section
              _buildSectionCard(
                title: 'المعلومات الأساسية',
                icon: Icons.medication_outlined,
                child: _buildBasicInfoSection(),
              ),
              SizedBox(height: 16),

              // Stock Information Section
              _buildSectionCard(
                title: 'معلومات المخزون',
                icon: Icons.inventory_2_outlined,
                child: _buildStockInfoSection(),
              ),
              SizedBox(height: 16),

              // Pricing Section
              _buildSectionCard(
                title: 'معلومات التسعير',
                icon: Icons.attach_money_outlined,
                child: _buildPricingSection(),
              ),
              SizedBox(height: 16),

              // Expiry Date Section
              _buildSectionCard(
                title: 'تاريخ الصلاحية',
                icon: Icons.calendar_today_outlined,
                child: _buildExpiryDateSection(),
              ),
              SizedBox(height: 16),

              // Image Section
              _buildSectionCard(
                title: 'صورة الدواء',
                icon: Icons.image_outlined,
                child: _buildImageSection(),
              ),
              SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Get.theme.primaryColor,
            Get.theme.primaryColor.withOpacity(0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.medication, color: Colors.white, size: 30),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'الكمية المتاحة: ${medicine.quantity}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'آخر تحديث: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
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

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        _buildCustomTextField(
          initialValue: medicine.name,
          labelText: 'اسم الدواء',
          prefixIcon: Icons.medication_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال اسم الدواء';
            }
            return null;
          },
          onChanged: (value) => controller.name.value = value,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildCustomTextField(
                initialValue: medicine.barcode,
                labelText: 'الباركود',
                prefixIcon: Icons.qr_code_outlined,
                onChanged: (value) => controller.barcode.value = value,
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
                  final result = await Get.to(() => BarcodeScannerView());
                  if (result != null) {
                    controller.barcode.value = result;
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStockInfoSection() {
    return Row(
      children: [
        Expanded(
          child: _buildCustomTextField(
            initialValue: medicine.quantity.toString(),
            labelText: 'الكمية الحالية',
            prefixIcon: Icons.inventory_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال الكمية';
              }
              if (int.tryParse(value) == null || int.parse(value) < 0) {
                return 'كمية غير صالحة';
              }
              return null;
            },
            onChanged: (value) {
              controller.quantity.value = int.tryParse(value) ?? 0;
            },
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 56,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: medicine.quantity <= 10
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: medicine.quantity <= 10
                    ? Colors.red.withOpacity(0.3)
                    : Colors.green.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'حالة المخزون',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
                Text(
                  medicine.quantity <= 10 ? 'منخفض' : 'متوفر',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: medicine.quantity <= 10 ? Colors.red : Colors.green,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            // child: Row(
            //   // crossAxisAlignment: CrossAxisAlignment.start,
            //   mainAxisAlignment: MainAxisAlignment.values.first,
            //   children: [
            //     Text(
            //       'حالة المخزون :',
            //       style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            //     ),
            //     SizedBox(width: 8),
            //     Text(
            //       medicine.quantity <= 10 ? 'منخفض' : 'متوفر',
            //       style: TextStyle(
            //         fontWeight: FontWeight.bold,
            //         color: medicine.quantity <= 10 ? Colors.red : Colors.green,
            //         fontSize: 14,
            //       ),
            //     ),
            //   ],
            // ),
          ),
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
                initialValue: medicine.sellingPrice.toString(),
                labelText: 'سعر البيع',
                prefixIcon: Icons.sell_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال السعر';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) < 0) {
                    return 'سعر غير صالح';
                  }
                  return null;
                },
                onChanged: (value) {
                  controller.price.value = double.tryParse(value) ?? 0.0;
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildCustomTextField(
                initialValue: medicine.purchasePrice.toString(),
                labelText: 'سعر الشراء',
                prefixIcon: Icons.shopping_cart_outlined,
                keyboardType: TextInputType.number,
                enabled: false,
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المكسب للقطعة الواحدة',
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                    ),
                    Text(
                      '${(medicine.sellingPrice - medicine.purchasePrice).toStringAsFixed(2)} جنيه',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpiryDateSection() {
    return Obx(() => InkWell(
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: Get.context!,
              initialDate: controller.expiryDate.value ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 3650)),
            );
            if (pickedDate != null) {
              controller.expiryDate.value = pickedDate;
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
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        controller.expiryDate.value == null
                            ? 'غير محدد'
                            : DateFormat('dd/MM/yyyy')
                                .format(controller.expiryDate.value!),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _getExpiryDateColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.edit_outlined, size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        ));
  }

  Color _getExpiryDateColor() {
    if (controller.expiryDate.value == null) return Colors.grey;

    final daysUntilExpiry =
        controller.expiryDate.value!.difference(DateTime.now()).inDays;
    if (daysUntilExpiry <= 30) return Colors.red;
    if (daysUntilExpiry <= 90) return Colors.orange;
    return Colors.green;
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        Obx(() {
          if (controller.imagePath.value != null) {
            return Container(
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
                        icon: Icon(Icons.delete_outline, color: Colors.white),
                        onPressed: () => controller.clearImage(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, size: 40, color: Colors.grey[400]),
                SizedBox(height: 8),
                Text(
                  'لا توجد صورة',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }),
        SizedBox(height: 12),
        ElevatedButton.icon(
          icon: Icon(Icons.camera_alt_outlined),
          label: Text('تغيير الصورة'),
          onPressed: () => controller.pickImage(),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 48),
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
    String? initialValue,
    required String labelText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool enabled = true,
    String? Function(String?)? validator,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      keyboardType: keyboardType,
      enabled: enabled,
      validator: validator,
      onChanged: onChanged,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: Icon(Icons.cancel_outlined),
            label: Text('إلغاء'),
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(0, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Get.theme.primaryColor,
                  Get.theme.primaryColor.withOpacity(0.8)
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Get.theme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              icon: Icon(Icons.save_outlined, color: Colors.white),
              label: Text(
                'حفظ التغييرات',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (controller.expiryDate.value == null) {
                    Get.snackbar(
                      'خطأ',
                      'يرجى تحديد تاريخ انتهاء الصلاحية',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.withOpacity(0.8),
                      colorText: Colors.white,
                    );
                    return;
                  }
                  if (controller.imagePath.value == null) {
                    Get.snackbar(
                      'خطأ',
                      'يرجى التقاط صورة للدواء',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.withOpacity(0.8),
                      colorText: Colors.white,
                    );
                    return;
                  }

                  controller.updateMedicine(medicine.id!).then((_) {
                    Get.back(result: true);
                  }).catchError((error) {
                    Get.snackbar(
                      'خطأ',
                      'حدث خطأ أثناء تحديث الدواء',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.withOpacity(0.8),
                      colorText: Colors.white,
                    );
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.warning_outlined,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'تأكيد الحذف',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'هل أنت متأكد من حذف دواء "${medicine.name}"؟',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
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
                      child: Text('حذف'),
                      onPressed: () async {
                        Get.back();
                        // Implement delete functionality here
                        Get.snackbar(
                          'نجاح',
                          'تم حذف الدواء بنجاح',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green.withOpacity(0.8),
                          colorText: Colors.white,
                        );
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(0, 48),
                        backgroundColor: Colors.red,
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

// // lib/app/modules/medicine/views/edit_medicine_view.dart
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import '../controllers/medicine_controller.dart';
// import '../../../routes/app_pages.dart';
// import '../../../data/models/medicine.dart';
// import '../../shared/views/barcode_scanner_view.dart';

// class EditMedicineView extends GetView<MedicineController> {
//   final Medicine medicine = Get.arguments;
//   final _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     // Initialize controller with medicine data
//     controller.initializeForEdit(medicine);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('تعديل دواء'),
//         centerTitle: true,
//       ),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: EdgeInsets.all(16),
//           children: [
//             // اسم الدواء
//             _buildNameField(),
//             SizedBox(height: 16),

//             // الباركود
//             _buildBarcodeField(),
//             SizedBox(height: 16),

//             // الكمية والسعر
//             _buildQuantityAndPriceRow(),
//             SizedBox(height: 16),

//             // تاريخ الصلاحية
//             _buildExpiryDateField(),
//             SizedBox(height: 16),

//             // صورة الدواء
//             _buildImageSection(),
//             SizedBox(height: 16),

//             // زر الحفظ
//             _buildSaveButton(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNameField() {
//     return Obx(() => TextFormField(
//           initialValue: controller.name.value,
//           decoration: InputDecoration(
//             labelText: 'اسم الدواء',
//             border: OutlineInputBorder(),
//             prefixIcon: Icon(Icons.medication),
//           ),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'يرجى إدخال اسم الدواء';
//             }
//             return null;
//           },
//           onChanged: (value) => controller.name.value = value,
//         ));
//   }

//   Widget _buildBarcodeField() {
//     return Obx(() => Row(
//           children: [
//             Expanded(
//               child: TextFormField(
//                 initialValue: controller.barcode.value,
//                 decoration: InputDecoration(
//                   labelText: 'الباركود',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.qr_code),
//                 ),
//                 onChanged: (value) => controller.barcode.value = value,
//               ),
//             ),
//             IconButton(
//               icon: Icon(Icons.qr_code_scanner),
//               onPressed: () async {
//                 final result = await Get.to(() => BarcodeScannerView());
//                 if (result != null) {
//                   controller.barcode.value = result;
//                 }
//               },
//             ),
//           ],
//         ));
//   }

//   Widget _buildQuantityAndPriceRow() {
//     return Row(
//       children: [
//         Expanded(
//           child: Obx(() => TextFormField(
//                 initialValue: controller.quantity.value.toString(),
//                 decoration: InputDecoration(
//                   labelText: 'الكمية',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.inventory),
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'يرجى إدخال الكمية';
//                   }
//                   if (int.tryParse(value) == null || int.parse(value) < 0) {
//                     return 'كمية غير صالحة';
//                   }
//                   return null;
//                 },
//                 onChanged: (value) {
//                   controller.quantity.value = int.tryParse(value) ?? 0;
//                 },
//               )),
//         ),
//         SizedBox(width: 16),
//         Expanded(
//           child: Obx(() => TextFormField(
//                 initialValue: controller.price.value.toString(),
//                 decoration: InputDecoration(
//                   labelText: 'السعر',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.attach_money),
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'يرجى إدخال السعر';
//                   }
//                   if (double.tryParse(value) == null || double.parse(value) < 0) {
//                     return 'سعر غير صالح';
//                   }
//                   return null;
//                 },
//                 onChanged: (value) {
//                   controller.price.value = double.tryParse(value) ?? 0.0;
//                 },
//               )),
//         ),
//       ],
//     );
//   }

//   Widget _buildExpiryDateField() {
//     return Obx(() => ListTile(
//           title: Text(
//             controller.expiryDate.value == null
//                 ? 'تاريخ انتهاء الصلاحية'
//                 : 'تاريخ الانتهاء: ${DateFormat('dd/MM/yyyy').format(controller.expiryDate.value!)}',
//           ),
//           trailing: Icon(Icons.calendar_today),
//           tileColor: Colors.grey[200],
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//             side: BorderSide(color: Colors.grey),
//           ),
//           onTap: () async {
//             final pickedDate = await showDatePicker(
//               context: Get.context!,
//               initialDate: controller.expiryDate.value ?? DateTime.now(),
//               firstDate: DateTime.now(),
//               lastDate: DateTime.now().add(Duration(days: 3650)),
//             );
//             if (pickedDate != null) {
//               controller.expiryDate.value = pickedDate;
//             }
//           },
//         ));
//   }

//   Widget _buildImageSection() {
//     return Column(
//       children: [
//         Obx(() {
//           if (controller.imagePath.value != null) {
//             return Stack(
//               alignment: Alignment.topRight,
//               children: [
//                 Container(
//                   height: 200,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.file(
//                       File(controller.imagePath.value!),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.delete, color: Colors.red),
//                   onPressed: () => controller.clearImage(),
//                 ),
//               ],
//             );
//           }
//           return Container();
//         }),
//         SizedBox(height: 8),
//         ElevatedButton.icon(
//           icon: Icon(Icons.camera_alt),
//           label: Text('تغيير الصورة'),
//           onPressed: () => controller.pickImage(),
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
//         if (_formKey.currentState!.validate()) {
//           if (controller.expiryDate.value == null) {
//             Get.snackbar(
//               'خطأ',
//               'يرجى تحديد تاريخ انتهاء الصلاحية',
//               snackPosition: SnackPosition.BOTTOM,
//             );
//             return;
//           }
//           if (controller.imagePath.value == null) {
//             Get.snackbar(
//               'خطأ',
//               'يرجى التقاط صورة للدواء',
//               snackPosition: SnackPosition.BOTTOM,
//             );
//             return;
//           }

//           controller.updateMedicine(medicine.id!).then((_) {
//             Get.back(result: true);
//           }).catchError((error) {
//             Get.snackbar(
//               'خطأ',
//               'حدث خطأ أثناء تحديث الدواء',
//               snackPosition: SnackPosition.BOTTOM,
//             );
//           });
//         }
//       },
//       child: Padding(
//         padding: EdgeInsets.symmetric(vertical: 12),
//         child: Text(
//           'حفظ التغييرات',
//           style: TextStyle(fontSize: 18),
//         ),
//       ),
//       style: ElevatedButton.styleFrom(
//         minimumSize: Size(double.infinity, 45),
//       ),
//     );
//   }
// }
