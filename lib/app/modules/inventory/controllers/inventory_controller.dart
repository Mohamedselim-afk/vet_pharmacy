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
  final isGeneratingPdf = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMedicines();
  }

  Future<void> loadMedicines() async {
    final List<Medicine> loadedMedicines =
        await _databaseService.getAllMedicines();
    medicines.value = loadedMedicines;
  }

  Future<void> searchMedicines(String query) async {
    if (query.isEmpty) {
      await loadMedicines();
    } else {
      final List<Medicine> searchResults =
          await _databaseService.searchMedicines(query);
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
            style: TextButton.styleFrom(
                foregroundColor: Get.theme.colorScheme.error),
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

  // Smart PDF Generation Methods
  Future<void> generateInventoryReport() async {
    await _showPdfOptionsDialog();
  }

  Future<void> _showPdfOptionsDialog() async {
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
                  Icon(Icons.picture_as_pdf, color: Colors.red),
                  SizedBox(width: 12),
                  Text(
                    'تصدير تقرير المخزون',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              _buildPdfOption(
                title: 'تقرير شامل',
                subtitle: 'تقرير مفصل يشمل جميع المعلومات والإحصائيات',
                icon: Icons.description_outlined,
                color: Colors.blue,
                onTap: () {
                  Get.back();
                  _generateComprehensiveReport();
                },
              ),
              SizedBox(height: 12),
              _buildPdfOption(
                title: 'تقرير المخزون المنخفض',
                subtitle: 'الأدوية التي تحتاج إعادة تموين (أقل من 10 قطع)',
                icon: Icons.warning_outlined,
                color: Colors.orange,
                onTap: () {
                  Get.back();
                  _generateLowStockReport();
                },
              ),
              SizedBox(height: 12),
              _buildPdfOption(
                title: 'تقرير قريب الانتهاء',
                subtitle: 'الأدوية التي تنتهي صلاحيتها خلال 30 يوم',
                icon: Icons.schedule_outlined,
                color: Colors.red,
                onTap: () {
                  Get.back();
                  _generateExpiringReport();
                },
              ),
              SizedBox(height: 12),
              _buildPdfOption(
                title: 'تقرير القيمة المالية',
                subtitle: 'تحليل مالي للمخزون والاستثمار',
                icon: Icons.attach_money_outlined,
                color: Colors.green,
                onTap: () {
                  Get.back();
                  _generateFinancialReport();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPdfOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Future<void> _generateComprehensiveReport() async {
    isGeneratingPdf.value = true;
    try {
      final font = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
      final ttf = pw.Font.ttf(font);

      // Calculate statistics
      final stats = _calculateInventoryStats();

      final pdf = pw.Document();

      // Add pages
      _addCoverPage(pdf, ttf);
      _addSummaryPage(pdf, ttf, stats);
      _addInventoryListPage(pdf, ttf);
      _addAlertsPage(pdf, ttf, stats);

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename:
            'تقرير_المخزون_الشامل_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
      );

      Get.snackbar(
        'نجاح',
        'تم إنشاء التقرير الشامل بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء إنشاء التقرير: $e');
    } finally {
      isGeneratingPdf.value = false;
    }
  }

  Future<void> _generateLowStockReport() async {
    isGeneratingPdf.value = true;
    try {
      final font = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
      final ttf = pw.Font.ttf(font);

      final lowStockMedicines =
          medicines.where((m) => m.quantity <= 10).toList();

      if (lowStockMedicines.isEmpty) {
        Get.snackbar('تنبيه', 'لا توجد أدوية بمخزون منخفض');
        return;
      }

      final pdf = pw.Document();

      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          _buildHeader(ttf, 'تقرير المخزون المنخفض', Colors.orange),
          pw.SizedBox(height: 30),

          // Alert summary
          _buildAlertBox(
            ttf,
            'تحذير: يوجد ${lowStockMedicines.length} صنف بحاجة لإعادة تموين',
            Colors.orange,
          ),
          pw.SizedBox(height: 20),

          // Low stock table
          _buildMedicinesTable(ttf, lowStockMedicines, showQuantityAlert: true),

          pw.SizedBox(height: 30),
          _buildFooter(ttf),
        ],
      ));

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename:
            'تقرير_المخزون_المنخفض_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
      );

      Get.snackbar(
        'نجاح',
        'تم إنشاء تقرير المخزون المنخفض بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء إنشاء التقرير: $e');
    } finally {
      isGeneratingPdf.value = false;
    }
  }

  Future<void> _generateExpiringReport() async {
    isGeneratingPdf.value = true;
    try {
      final font = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
      final ttf = pw.Font.ttf(font);

      final expiringMedicines = medicines
          .where((m) => m.expiryDate.difference(DateTime.now()).inDays <= 30)
          .toList();

      if (expiringMedicines.isEmpty) {
        Get.snackbar('تنبيه', 'لا توجد أدوية قريبة الانتهاء');
        return;
      }

      final pdf = pw.Document();

      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          _buildHeader(ttf, 'تقرير الأدوية قريبة الانتهاء', Colors.red),
          pw.SizedBox(height: 30),
          _buildAlertBox(
            ttf,
            'تحذير: يوجد ${expiringMedicines.length} صنف ينتهي خلال 30 يوم',
            Colors.red,
          ),
          pw.SizedBox(height: 20),
          _buildExpiringMedicinesTable(ttf, expiringMedicines),
          pw.SizedBox(height: 30),
          _buildFooter(ttf),
        ],
      ));

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename:
            'تقرير_قريب_الانتهاء_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
      );

      Get.snackbar(
        'نجاح',
        'تم إنشاء تقرير الأدوية قريبة الانتهاء بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء إنشاء التقرير: $e');
    } finally {
      isGeneratingPdf.value = false;
    }
  }

  Future<void> _generateFinancialReport() async {
    isGeneratingPdf.value = true;
    try {
      final font = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
      final ttf = pw.Font.ttf(font);

      final stats = _calculateInventoryStats();

      final pdf = pw.Document();

      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          _buildHeader(ttf, 'التقرير المالي للمخزون', Colors.green),
          pw.SizedBox(height: 30),
          _buildFinancialSummary(ttf, stats),
          pw.SizedBox(height: 20),
          _buildTopValueMedicinesTable(ttf),
          pw.SizedBox(height: 20),
          _buildFinancialRecommendations(ttf, stats),
          pw.SizedBox(height: 30),
          _buildFooter(ttf),
        ],
      ));

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename:
            'التقرير_المالي_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
      );

      Get.snackbar(
        'نجاح',
        'تم إنشاء التقرير المالي بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء إنشاء التقرير: $e');
    } finally {
      isGeneratingPdf.value = false;
    }
  }

  // Helper methods for PDF generation
  Map<String, dynamic> _calculateInventoryStats() {
    final totalMedicines = medicines.length;
    final totalQuantity = medicines.fold<int>(0, (sum, m) => sum + m.quantity);
    final totalValue = medicines.fold<double>(
        0, (sum, m) => sum + (m.quantity * m.purchasePrice));
    final totalSellingValue = medicines.fold<double>(
        0, (sum, m) => sum + (m.quantity * m.sellingPrice));
    final lowStockCount = medicines.where((m) => m.quantity <= 10).length;
    final expiringCount = medicines
        .where((m) => m.expiryDate.difference(DateTime.now()).inDays <= 30)
        .length;
    final expiredCount =
        medicines.where((m) => m.expiryDate.isBefore(DateTime.now())).length;

    return {
      'totalMedicines': totalMedicines,
      'totalQuantity': totalQuantity,
      'totalValue': totalValue,
      'totalSellingValue': totalSellingValue,
      'potentialProfit': totalSellingValue - totalValue,
      'lowStockCount': lowStockCount,
      'expiringCount': expiringCount,
      'expiredCount': expiredCount,
    };
  }

  void _addCoverPage(pw.Document pdf, pw.Font ttf) {
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        child: pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Container(
                width: 120,
                height: 120,
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue,
                  borderRadius: pw.BorderRadius.circular(60),
                ),
                child: pw.Center(
                  child: pw.Icon(
                    pw.IconData(0xe3e6), // medical_services icon
                    size: 60,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.SizedBox(height: 40),
              pw.Text(
                'الصيدلية البيطرية',
                style: pw.TextStyle(
                    font: ttf, fontSize: 32, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'تقرير المخزون الشامل',
                style: pw.TextStyle(font: ttf, fontSize: 24),
              ),
              pw.SizedBox(height: 40),
              pw.Text(
                'تاريخ التقرير: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                style: pw.TextStyle(font: ttf, fontSize: 16),
              ),
              pw.Text(
                'وقت الإنشاء: ${DateFormat('HH:mm').format(DateTime.now())}',
                style: pw.TextStyle(font: ttf, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  void _addSummaryPage(
      pw.Document pdf, pw.Font ttf, Map<String, dynamic> stats) {
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(ttf, 'ملخص المخزون', Colors.blue),
            pw.SizedBox(height: 30),

            // Statistics grid
            pw.Row(
              children: [
                pw.Expanded(
                  child: _buildStatCard(ttf, 'إجمالي الأصناف',
                      '${stats['totalMedicines']}', PdfColors.blue),
                ),
                pw.SizedBox(width: 20),
                pw.Expanded(
                  child: _buildStatCard(ttf, 'إجمالي الكمية',
                      '${stats['totalQuantity']}', PdfColors.green),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              children: [
                pw.Expanded(
                  child: _buildStatCard(
                      ttf,
                      'قيمة المخزون',
                      '${stats['totalValue'].toStringAsFixed(2)} جنيه',
                      PdfColors.purple),
                ),
                pw.SizedBox(width: 20),
                pw.Expanded(
                  child: _buildStatCard(
                      ttf,
                      'المكسب المتوقع',
                      '${stats['potentialProfit'].toStringAsFixed(2)} جنيه',
                      PdfColors.orange),
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Alerts section
            if (stats['lowStockCount'] > 0 || stats['expiringCount'] > 0) ...[
              pw.Text(
                'التنبيهات',
                style: pw.TextStyle(
                    font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 15),
              if (stats['lowStockCount'] > 0)
                _buildAlertItem(ttf, 'مخزون منخفض',
                    '${stats['lowStockCount']} صنف', PdfColors.orange),
              if (stats['expiringCount'] > 0)
                _buildAlertItem(ttf, 'قريب الانتهاء',
                    '${stats['expiringCount']} صنف', PdfColors.red),
              if (stats['expiredCount'] > 0)
                _buildAlertItem(ttf, 'منتهي الصلاحية',
                    '${stats['expiredCount']} صنف', PdfColors.redAccent),
            ],
          ],
        ),
      ),
    ));
  }

  void _addInventoryListPage(pw.Document pdf, pw.Font ttf) {
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      build: (context) => [
        _buildHeader(ttf, 'قائمة المخزون', Colors.blue),
        pw.SizedBox(height: 20),
        _buildMedicinesTable(ttf, medicines),
      ],
    ));
  }

  void _addAlertsPage(
      pw.Document pdf, pw.Font ttf, Map<String, dynamic> stats) {
    if (stats['lowStockCount'] == 0 && stats['expiringCount'] == 0) return;

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      build: (context) => [
        _buildHeader(ttf, 'التنبيهات والتحذيرات', Colors.red),
        pw.SizedBox(height: 30),
        if (stats['lowStockCount'] > 0) ...[
          pw.Text(
            'أدوية بمخزون منخفض (أقل من 10 قطع)',
            style: pw.TextStyle(
                font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          _buildMedicinesTable(
            ttf,
            medicines.where((m) => m.quantity <= 10).toList(),
            showQuantityAlert: true,
          ),
          pw.SizedBox(height: 30),
        ],
        if (stats['expiringCount'] > 0) ...[
          pw.Text(
            'أدوية قريبة الانتهاء (خلال 30 يوم)',
            style: pw.TextStyle(
                font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          _buildExpiringMedicinesTable(
            ttf,
            medicines
                .where(
                    (m) => m.expiryDate.difference(DateTime.now()).inDays <= 30)
                .toList(),
          ),
        ],
      ],
    ));
  }

  pw.Widget _buildHeader(pw.Font ttf, String title, Color color) {
    return pw.Container(
      padding: pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(color.value),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              title,
              style: pw.TextStyle(
                font: ttf,
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.Text(
            DateFormat('dd/MM/yyyy').format(DateTime.now()),
            style: pw.TextStyle(
              font: ttf,
              fontSize: 14,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStatCard(
      pw.Font ttf, String title, String value, PdfColor color) {
    return pw.Container(
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(font: ttf, fontSize: 12),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: ttf,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildAlertBox(pw.Font ttf, String message, Color color) {
    return pw.Container(
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(color.value).shade(0.9),
        border: pw.Border.all(color: PdfColor.fromInt(color.value), width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(
        message,
        style: pw.TextStyle(
          font: ttf,
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromInt(color.value),
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildAlertItem(
      pw.Font ttf, String title, String count, PdfColor color) {
    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: 10),
      padding: pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: color.shade(0.9),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              title,
              style: pw.TextStyle(
                  font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(
            count,
            style: pw.TextStyle(font: ttf, fontSize: 14, color: color),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMedicinesTable(pw.Font ttf, List<Medicine> medicineList,
      {bool showQuantityAlert = false}) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
      columnWidths: {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(1.5),
        2: pw.FlexColumnWidth(2),
        3: pw.FlexColumnWidth(2.5),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell(ttf, 'اسم الدواء', isHeader: true),
            _buildTableCell(ttf, 'الكمية', isHeader: true),
            _buildTableCell(ttf, 'السعر', isHeader: true),
            _buildTableCell(ttf, 'تاريخ الانتهاء', isHeader: true),
          ],
        ),
        // Data rows
        for (var medicine in medicineList)
          pw.TableRow(
            decoration: pw.BoxDecoration(
              color: showQuantityAlert && medicine.quantity <= 10
                  ? PdfColors.orange50
                  : null,
            ),
            children: [
              _buildTableCell(ttf, medicine.name),
              _buildTableCell(
                ttf,
                '${medicine.quantity}',
                textColor: medicine.quantity <= 10 ? PdfColors.red : null,
              ),
              _buildTableCell(
                  ttf, '${medicine.sellingPrice.toStringAsFixed(2)}'),
              _buildTableCell(
                ttf,
                DateFormat('dd/MM/yyyy').format(medicine.expiryDate),
                textColor: _getExpiryPdfColor(medicine.expiryDate),
              ),
            ],
          ),
      ],
    );
  }

  pw.Widget _buildExpiringMedicinesTable(
      pw.Font ttf, List<Medicine> medicineList) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
      columnWidths: {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(1.5),
        2: pw.FlexColumnWidth(2.5),
        3: pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell(ttf, 'اسم الدواء', isHeader: true),
            _buildTableCell(ttf, 'الكمية', isHeader: true),
            _buildTableCell(ttf, 'تاريخ الانتهاء', isHeader: true),
            _buildTableCell(ttf, 'الأيام المتبقية', isHeader: true),
          ],
        ),
        // Data rows
        for (var medicine in medicineList)
          pw.TableRow(
            children: [
              _buildTableCell(ttf, medicine.name),
              _buildTableCell(ttf, '${medicine.quantity}'),
              _buildTableCell(
                ttf,
                DateFormat('dd/MM/yyyy').format(medicine.expiryDate),
                textColor: _getExpiryPdfColor(medicine.expiryDate),
              ),
              _buildTableCell(
                ttf,
                '${medicine.expiryDate.difference(DateTime.now()).inDays}',
                textColor: _getExpiryPdfColor(medicine.expiryDate),
              ),
            ],
          ),
      ],
    );
  }

  pw.Widget _buildFinancialSummary(pw.Font ttf, Map<String, dynamic> stats) {
    return pw.Container(
      padding: pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.green, width: 2),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'الملخص المالي',
            style: pw.TextStyle(
              font: ttf,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green,
            ),
          ),
          pw.SizedBox(height: 15),
          _buildFinancialRow(ttf, 'القيمة الإجمالية للمخزون (تكلفة)',
              '${stats['totalValue'].toStringAsFixed(2)} جنيه'),
          _buildFinancialRow(ttf, 'القيمة الإجمالية للمخزون (بيع)',
              '${stats['totalSellingValue'].toStringAsFixed(2)} جنيه'),
          _buildFinancialRow(ttf, 'إجمالي المكسب المتوقع',
              '${stats['potentialProfit'].toStringAsFixed(2)} جنيه',
              isProfit: true),
          _buildFinancialRow(ttf, 'نسبة الربح',
              '${((stats['potentialProfit'] / stats['totalValue']) * 100).toStringAsFixed(1)}%',
              isProfit: true),
          pw.SizedBox(height: 10),
          pw.Divider(color: PdfColors.grey),
          pw.SizedBox(height: 10),
          _buildFinancialRow(ttf, 'متوسط سعر الدواء الواحد',
              '${(stats['totalSellingValue'] / stats['totalMedicines']).toStringAsFixed(2)} جنيه'),
          _buildFinancialRow(ttf, 'متوسط قيمة المخزون للصنف',
              '${(stats['totalValue'] / stats['totalMedicines']).toStringAsFixed(2)} جنيه'),
        ],
      ),
    );
  }

  pw.Widget _buildFinancialRow(pw.Font ttf, String label, String value,
      {bool isProfit = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(font: ttf, fontSize: 14),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: ttf,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: isProfit ? PdfColors.green : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTopValueMedicinesTable(pw.Font ttf) {
    final sortedMedicines = [...medicines];
    sortedMedicines.sort((a, b) =>
        (b.quantity * b.sellingPrice).compareTo(a.quantity * a.sellingPrice));

    final topMedicines = sortedMedicines.take(10).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'أعلى 10 أدوية من ناحية القيمة',
          style: pw.TextStyle(
            font: ttf,
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
          columnWidths: {
            0: pw.FlexColumnWidth(3),
            1: pw.FlexColumnWidth(1.5),
            2: pw.FlexColumnWidth(2),
            3: pw.FlexColumnWidth(2.5),
          },
          children: [
            // Header
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                _buildTableCell(ttf, 'اسم الدواء', isHeader: true),
                _buildTableCell(ttf, 'الكمية', isHeader: true),
                _buildTableCell(ttf, 'سعر الوحدة', isHeader: true),
                _buildTableCell(ttf, 'القيمة الإجمالية', isHeader: true),
              ],
            ),
            // Data rows
            for (var medicine in topMedicines)
              pw.TableRow(
                children: [
                  _buildTableCell(ttf, medicine.name),
                  _buildTableCell(ttf, '${medicine.quantity}'),
                  _buildTableCell(
                      ttf, '${medicine.sellingPrice.toStringAsFixed(2)}'),
                  _buildTableCell(
                    ttf,
                    '${(medicine.quantity * medicine.sellingPrice).toStringAsFixed(2)}',
                    textColor: PdfColors.green,
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildFinancialRecommendations(
      pw.Font ttf, Map<String, dynamic> stats) {
    List<String> recommendations = [];

    if (stats['lowStockCount'] > 0) {
      recommendations
          .add('• إعادة تموين ${stats['lowStockCount']} صنف بمخزون منخفض');
    }

    if (stats['expiringCount'] > 0) {
      recommendations.add(
          '• عمل عروض خاصة للأدوية قريبة الانتهاء (${stats['expiringCount']} صنف)');
    }

    if (stats['potentialProfit'] > 0) {
      recommendations.add(
          '• المكسب المتوقع عالي (${((stats['potentialProfit'] / stats['totalValue']) * 100).toStringAsFixed(1)}%)');
    }

    final averageQuantityPerMedicine =
        stats['totalQuantity'] / stats['totalMedicines'];
    if (averageQuantityPerMedicine < 5) {
      recommendations.add('• متوسط الكمية منخفض، يُنصح بزيادة المخزون');
    }

    recommendations
        .add('• مراجعة دورية شهرية للمخزون المنخفض والمنتهي الصلاحية');
    recommendations.add('• تطبيق نظام FIFO (أول داخل أول خارج) للأدوية');

    return pw.Container(
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue, width: 1),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'التوصيات والاقتراحات',
            style: pw.TextStyle(
              font: ttf,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 10),
          for (var recommendation in recommendations)
            pw.Padding(
              padding: pw.EdgeInsets.only(bottom: 5),
              child: pw.Text(
                recommendation,
                style: pw.TextStyle(font: ttf, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildTableCell(pw.Font ttf, String text,
      {bool isHeader = false, PdfColor? textColor}) {
    return pw.Container(
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: ttf,
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: textColor ?? (isHeader ? PdfColors.black : PdfColors.black),
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildFooter(pw.Font ttf) {
    return pw.Container(
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'الصيدلية البيطرية - نظام إدارة المخزون',
            style: pw.TextStyle(
              font: ttf,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'تم إنشاء هذا التقرير تلقائياً في ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
            style: pw.TextStyle(font: ttf, fontSize: 10),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'للاستفسارات: mohamedselemdev@gmail.com | 01027316003',
            style: pw.TextStyle(font: ttf, fontSize: 10),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  PdfColor? _getExpiryPdfColor(DateTime expiryDate) {
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    if (daysUntilExpiry <= 0) return PdfColors.red;
    if (daysUntilExpiry <= 30) return PdfColors.orange;
    if (daysUntilExpiry <= 90) return PdfColors.amber;
    return null; // Default color
  }

  // Quick action methods for different report types
  Future<void> generateQuickLowStockReport() async {
    await _generateLowStockReport();
  }

  Future<void> generateQuickExpiringReport() async {
    await _generateExpiringReport();
  }

  Future<void> generateQuickFinancialReport() async {
    await _generateFinancialReport();
  }

  // Export data methods
  Future<void> exportToExcel() async {
    try {
      // This would require excel package implementation
      Get.snackbar('معلومة', 'ميزة تصدير Excel قيد التطوير');
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء التصدير: $e');
    }
  }

  Future<void> shareReportViaEmail(String reportType) async {
    try {
      // This would integrate with email services
      Get.snackbar('معلومة', 'ميزة الإرسال عبر البريد الإلكتروني قيد التطوير');
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء الإرسال: $e');
    }
  }

  // Analytics methods
  Map<String, dynamic> getInventoryAnalytics() {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(Duration(days: 30));

    return {
      'totalValue': medicines.fold<double>(
          0, (sum, m) => sum + (m.quantity * m.purchasePrice)),
      'averageExpiryDays': medicines.fold<int>(
              0, (sum, m) => sum + m.expiryDate.difference(now).inDays) /
          medicines.length,
      'stockTurnoverRate': _calculateStockTurnoverRate(),
      'categoryDistribution': _getCategoryDistribution(),
      'profitMargin': _calculateAverageProfitMargin(),
    };
  }

  double _calculateStockTurnoverRate() {
    // This would require sales data integration
    return 0.0; // Placeholder
  }

  Map<String, int> _getCategoryDistribution() {
    // This would categorize medicines if category field exists
    return {'general': medicines.length}; // Placeholder
  }

  double _calculateAverageProfitMargin() {
    if (medicines.isEmpty) return 0.0;

    final totalMargin = medicines.fold<double>(
        0,
        (sum, m) =>
            sum + ((m.sellingPrice - m.purchasePrice) / m.purchasePrice * 100));

    return totalMargin / medicines.length;
  }
}
// // lib/app/modules/inventory/controllers/inventory_controller.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import '../../../data/models/medicine.dart';
// import '../../../data/services/database_service.dart';

// class InventoryController extends GetxController {
//   final DatabaseService _databaseService = Get.find<DatabaseService>();
//   final searchQuery = ''.obs;
//   final medicines = <Medicine>[].obs;
  
//   @override
//   void onInit() {
//     super.onInit();
//     loadMedicines();
//   }

//   Future<void> loadMedicines() async {
//     final List<Medicine> loadedMedicines = await _databaseService.getAllMedicines();
//     medicines.value = loadedMedicines;
//   }

//   Future<void> searchMedicines(String query) async {
//     if (query.isEmpty) {
//       await loadMedicines();
//     } else {
//       final List<Medicine> searchResults = await _databaseService.searchMedicines(query);
//       medicines.value = searchResults;
//     }
//   }

//   Future<void> deleteMedicine(Medicine medicine) async {
//     final confirmed = await Get.dialog<bool>(
//       AlertDialog(
//         title: Text('تأكيد الحذف'),
//         content: Text('هل أنت متأكد من حذف ${medicine.name}؟'),
//         actions: [
//           TextButton(
//             child: Text('إلغاء'),
//             onPressed: () => Get.back(result: false),
//           ),
//           TextButton(
//             style: TextButton.styleFrom(foregroundColor: Get.theme.colorScheme.error),
//             child: Text('حذف'),
//             onPressed: () => Get.back(result: true),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       await _databaseService.deleteMedicine(medicine.id!);
//       Get.snackbar('نجاح', 'تم حذف ${medicine.name}');
//       await loadMedicines();
//     }
//   }

//   Future<void> generateInventoryReport() async {
//     try {
//       final font = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
//       final ttf = pw.Font.ttf(font);
      
//       final pdf = pw.Document();
      
//       pdf.addPage(pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (context) => pw.Directionality(
//           textDirection: pw.TextDirection.rtl,
//           child: pw.Column(
//             children: [
//               pw.Text('تقرير المخزون', style: pw.TextStyle(font: ttf, fontSize: 24)),
//               pw.SizedBox(height: 20),
//               pw.Table(
//                 border: pw.TableBorder.all(),
//                 children: [
//                   pw.TableRow(
//                     children: [
//                       pw.Text('الدواء', style: pw.TextStyle(font: ttf)),
//                       pw.Text('الكمية', style: pw.TextStyle(font: ttf)),
//                       pw.Text('السعر', style: pw.TextStyle(font: ttf)),
//                       pw.Text('تاريخ الانتهاء', style: pw.TextStyle(font: ttf)),
//                     ],
//                   ),
//                   for (var medicine in medicines)
//                     pw.TableRow(
//                       children: [
//                         pw.Text(medicine.name, style: pw.TextStyle(font: ttf)),
//                         pw.Text('${medicine.quantity}', style: pw.TextStyle(font: ttf)),
//                         pw.Text('${medicine.price}', style: pw.TextStyle(font: ttf)),
//                         pw.Text(
//                           DateFormat('dd/MM/yyyy').format(medicine.expiryDate),
//                           style: pw.TextStyle(font: ttf),
//                         ),
//                       ],
//                     ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ));

//       await Printing.sharePdf(bytes: await pdf.save());
//     } catch (e) {
//       Get.snackbar('خطأ', 'حدث خطأ أثناء إنشاء التقرير: $e');
//     }
//   }
// }