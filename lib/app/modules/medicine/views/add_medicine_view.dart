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
      appBar: AppBar(
        title: Text('إضافة دواء جديد'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // اختيار المندوب
            _buildSupplierField(), // Updated
            _buildSupplierDropdown(),
            SizedBox(height: 16),

            // معلومات الدواء الأساسية
            _buildBasicInfoSection(),
            SizedBox(height: 16),

            // معلومات التسعير
            _buildPricingSection(),
            SizedBox(height: 16),

            // معلومات الكمية والدفع
            _buildQuantityAndPaymentSection(),
            SizedBox(height: 16),

            // تاريخ الصلاحية والصورة
            _buildExpiryAndImageSection(),
            SizedBox(height: 16),

            // زر الحفظ
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierDropdown() {
    return Obx(() => DropdownButtonFormField<int>(
          value: controller.selectedSupplierId.value,
          decoration: InputDecoration(
            labelText: 'المندوب',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          items: controller.suppliers
              .map((supplier) => DropdownMenuItem(
                    value: supplier.id,
                    child: Text(supplier.name),
                  ))
              .toList(),
          onChanged: (value) => controller.selectedSupplierId.value = value!,
          validator: (value) =>
              value == null ? 'يرجى اختيار المندوب' : null,
        ));
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
            labelText: 'اسم الدواء',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.medication),
          ),
          onChanged: controller.setName,
          validator: (value) =>
              value?.isEmpty ?? true ? 'يرجى إدخال اسم الدواء' : null,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'الباركود',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                ),
                onChanged: controller.setBarcode,
              ),
            ),
            IconButton(
              icon: Icon(Icons.qr_code_scanner),
              onPressed: () async {
                // Implement barcode scanning
              },
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
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'سعر الشراء',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => controller.setPurchasePrice(double.tryParse(value) ?? 0),
                validator: (value) => _validatePrice(value),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'سعر البيع',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sell),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => controller.setSellingPrice(double.tryParse(value) ?? 0),
                validator: (value) => _validatePrice(value),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'سعر السوق',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.storefront),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => controller.setMarketPrice(double.tryParse(value) ?? 0),
                validator: (value) => _validatePrice(value),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Obx(() {
                final profit = controller.calculateProfit();
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('المكسب للقطعة:'),
                      Text(
                        '${profit.toStringAsFixed(2)} جنيه',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: profit > 0 ? Colors.green : Colors.red,
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
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'كمية العلبة',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => controller.setBoxQuantity(int.tryParse(value) ?? 0),
                validator: (value) => _validateQuantity(value),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'سعر العلبة',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => controller.setBoxPrice(double.tryParse(value) ?? 0),
                validator: (value) => _validatePrice(value),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'الكمية الكلية',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.production_quantity_limits),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => controller.setTotalQuantity(int.tryParse(value) ?? 0),
                validator: (value) => _validateQuantity(value),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'المبلغ المدفوع',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payments),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => controller.setAmountPaid(double.tryParse(value) ?? 0),
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
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
              color: remaining > 0 ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('المبلغ المتبقي:'),
                Text(
                  '${remaining.toStringAsFixed(2)} جنيه',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: remaining > 0 ? Colors.red : Colors.green,
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
        Obx(() => ListTile(
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
            )),
        SizedBox(height: 16),
        Obx(() {
          if (controller.imagePath.value != null) {
            return Stack(
              alignment: Alignment.topRight,
              children: [
                Image.file(
                  File(controller.imagePath.value!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: controller.clearImage,
                ),
              ],
            );
          }
          return Container();
        }),
        ElevatedButton.icon(
          icon: Icon(Icons.camera_alt),
          label: Text('التقاط صورة'),
          onPressed: controller.pickImage,
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
        if (_formKey.currentState!.validate() && _validateForm()) {
          controller.saveMedicine();
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'حفظ الدواء',
          style: TextStyle(fontSize: 18),
        ),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 45),
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
      );
      return false;
    }
    if (controller.imagePath.value == null) {
      Get.snackbar(
        'خطأ',
        'يرجى التقاط صورة للدواء',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    return true;
  }

   Widget _buildSupplierField() {
    return Obx(() {
      if (controller.suppliers.isEmpty) {
        return ListTile(
          title: Text(
            'لا يوجد مناديب - اضغط لإضافة مندوب',
            style: TextStyle(color: Colors.red),
          ),
          leading: Icon(Icons.warning, color: Colors.red),
          onTap: () async {
            final result = await Get.toNamed(Routes.SUPPLIERS);
            if (result == true) {
              controller.loadSuppliers();
            }
          },
        );
      }

      return DropdownButtonFormField<int>(
        value: controller.selectedSupplierId.value,
        decoration: InputDecoration(
          labelText: 'المندوب',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.person),
          suffixIcon: IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Get.toNamed(Routes.SUPPLIERS);
              if (result == true) {
                controller.loadSuppliers();
              }
            },
          ),
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
      );
    });
  }
}