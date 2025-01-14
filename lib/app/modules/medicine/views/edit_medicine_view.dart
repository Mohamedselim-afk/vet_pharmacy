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
      appBar: AppBar(
        title: Text('تعديل دواء'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // اسم الدواء
            _buildNameField(),
            SizedBox(height: 16),

            // الباركود
            _buildBarcodeField(),
            SizedBox(height: 16),

            // الكمية والسعر
            _buildQuantityAndPriceRow(),
            SizedBox(height: 16),

            // تاريخ الصلاحية
            _buildExpiryDateField(),
            SizedBox(height: 16),

            // صورة الدواء
            _buildImageSection(),
            SizedBox(height: 16),

            // زر الحفظ
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Obx(() => TextFormField(
          initialValue: controller.name.value,
          decoration: InputDecoration(
            labelText: 'اسم الدواء',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.medication),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال اسم الدواء';
            }
            return null;
          },
          onChanged: (value) => controller.name.value = value,
        ));
  }

  Widget _buildBarcodeField() {
    return Obx(() => Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: controller.barcode.value,
                decoration: InputDecoration(
                  labelText: 'الباركود',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                ),
                onChanged: (value) => controller.barcode.value = value,
              ),
            ),
            IconButton(
              icon: Icon(Icons.qr_code_scanner),
              onPressed: () async {
                final result = await Get.to(() => BarcodeScannerView());
                if (result != null) {
                  controller.barcode.value = result;
                }
              },
            ),
          ],
        ));
  }

  Widget _buildQuantityAndPriceRow() {
    return Row(
      children: [
        Expanded(
          child: Obx(() => TextFormField(
                initialValue: controller.quantity.value.toString(),
                decoration: InputDecoration(
                  labelText: 'الكمية',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
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
              )),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Obx(() => TextFormField(
                initialValue: controller.price.value.toString(),
                decoration: InputDecoration(
                  labelText: 'السعر',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال السعر';
                  }
                  if (double.tryParse(value) == null || double.parse(value) < 0) {
                    return 'سعر غير صالح';
                  }
                  return null;
                },
                onChanged: (value) {
                  controller.price.value = double.tryParse(value) ?? 0.0;
                },
              )),
        ),
      ],
    );
  }

  Widget _buildExpiryDateField() {
    return Obx(() => ListTile(
          title: Text(
            controller.expiryDate.value == null
                ? 'تاريخ انتهاء الصلاحية'
                : 'تاريخ الانتهاء: ${DateFormat('dd/MM/yyyy').format(controller.expiryDate.value!)}',
          ),
          trailing: Icon(Icons.calendar_today),
          tileColor: Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey),
          ),
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
        ));
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        Obx(() {
          if (controller.imagePath.value != null) {
            return Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(controller.imagePath.value!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => controller.clearImage(),
                ),
              ],
            );
          }
          return Container();
        }),
        SizedBox(height: 8),
        ElevatedButton.icon(
          icon: Icon(Icons.camera_alt),
          label: Text('تغيير الصورة'),
          onPressed: () => controller.pickImage(),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 45),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          if (controller.expiryDate.value == null) {
            Get.snackbar(
              'خطأ',
              'يرجى تحديد تاريخ انتهاء الصلاحية',
              snackPosition: SnackPosition.BOTTOM,
            );
            return;
          }
          if (controller.imagePath.value == null) {
            Get.snackbar(
              'خطأ',
              'يرجى التقاط صورة للدواء',
              snackPosition: SnackPosition.BOTTOM,
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
            );
          });
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'حفظ التغييرات',
          style: TextStyle(fontSize: 18),
        ),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 45),
      ),
    );
  }
}