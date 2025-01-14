// lib/app/modules/inventory/controllers/inventory_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../data/models/medicine.dart';
import '../../../data/services/database_service.dart';

class InventoryController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final searchQuery = ''.obs;
  final medicines = <Medicine>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadMedicines();
  }

  Future<void> loadMedicines() async {
    final List<Medicine> loadedMedicines = await _databaseService.getAllMedicines();
    medicines.value = loadedMedicines;
  }

  Future<void> searchMedicines(String query) async {
    if (query.isEmpty) {
      await loadMedicines();
    } else {
      final List<Medicine> searchResults = await _databaseService.searchMedicines(query);
      medicines.value = searchResults;
    }
  }

  Future<void> deleteMedicine(Medicine medicine) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف ${medicine.name}؟'),
        actions: [
          TextButton(
            child: Text('إلغاء'),
            onPressed: () => Get.back(result: false),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Get.theme.colorScheme.error),
            child: Text('حذف'),
            onPressed: () => Get.back(result: true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _databaseService.deleteMedicine(medicine.id!);
      Get.snackbar('نجاح', 'تم حذف ${medicine.name}');
      await loadMedicines();
    }
  }

  Future<void> generateInventoryReport() async {
    try {
      final font = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
      final ttf = pw.Font.ttf(font);
      
      final pdf = pw.Document();
      
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            children: [
              pw.Text('تقرير المخزون', style: pw.TextStyle(font: ttf, fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('الدواء', style: pw.TextStyle(font: ttf)),
                      pw.Text('الكمية', style: pw.TextStyle(font: ttf)),
                      pw.Text('السعر', style: pw.TextStyle(font: ttf)),
                      pw.Text('تاريخ الانتهاء', style: pw.TextStyle(font: ttf)),
                    ],
                  ),
                  for (var medicine in medicines)
                    pw.TableRow(
                      children: [
                        pw.Text(medicine.name, style: pw.TextStyle(font: ttf)),
                        pw.Text('${medicine.quantity}', style: pw.TextStyle(font: ttf)),
                        pw.Text('${medicine.price}', style: pw.TextStyle(font: ttf)),
                        pw.Text(
                          DateFormat('dd/MM/yyyy').format(medicine.expiryDate),
                          style: pw.TextStyle(font: ttf),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ));

      await Printing.sharePdf(bytes: await pdf.save());
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء إنشاء التقرير: $e');
    }
  }
}