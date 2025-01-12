// lib/screens/add_medicine_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:vet_pharmacy/models/medicine.dart';
import 'package:vet_pharmacy/screens/barcode_scanner_screen.dart';
import 'package:vet_pharmacy/services/database_helper.dart';

class AddMedicineScreen extends StatefulWidget {
  @override
  _AddMedicineScreenState createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  late final Medicine medicine;
 

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime? _expiryDate;
  String? _imagePath;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  Future<void> _saveMedicine() async {
    if (_formKey.currentState!.validate() && _imagePath != null && _expiryDate != null) {
      final medicine = Medicine(
        name: _nameController.text,
        barcode: _barcodeController.text,
        quantity: int.parse(_quantityController.text),
        price: double.parse(_priceController.text),
        image: _imagePath!,
        expiryDate: _expiryDate!,
      );

      await DatabaseHelper.instance.insertMedicine(medicine);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إضافة دواء جديد')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'اسم الدواء',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال اسم الدواء';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _barcodeController,
                    decoration: InputDecoration(
                      labelText: 'الباركود',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.qr_code_scanner),
                  onPressed: () async {
                    final barcode = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BarcodeScannerScreen(),
                      ),
                    );
                    if (barcode != null) {
                      setState(() {
                        _barcodeController.text = barcode;
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'الكمية',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال الكمية';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'السعر',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال السعر';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text(_expiryDate == null 
                ? 'تاريخ انتهاء الصلاحية' 
                : 'تاريخ الانتهاء: ${DateFormat('dd/MM/yyyy').format(_expiryDate!)}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 3650)),
                );
                if (date != null) {
                  setState(() {
                    _expiryDate = date;
                  });
                }
              },
            ),
            SizedBox(height: 16),
            if (_imagePath != null)
              Image.file(
                File(_imagePath!),
                height: 200,
                fit: BoxFit.cover,
              ),
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text('التقاط صورة'),
              onPressed: _pickImage,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('حفظ الدواء'),
              onPressed: _saveMedicine,
            ),
          ],
        ),
      ),
    );
  }
}
