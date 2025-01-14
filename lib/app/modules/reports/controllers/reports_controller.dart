import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/medicine.dart';
import '../../../data/models/sale.dart';

class ReportsController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  
  // Observable variables for sales report
  final dailySales = <Map<String, dynamic>>[].obs;
  final weeklySales = <Map<String, dynamic>>[].obs;
  final monthlySales = <Map<String, dynamic>>[].obs;
  
  // Observable variables for inventory report
  final topSellingMedicines = <Map<String, dynamic>>[].obs;
  final lowStockMedicines = <Medicine>[].obs;
  final expiringMedicines = <Medicine>[].obs;
  
  // Selected date range
  final selectedStartDate = Rx<DateTime>(DateTime.now());
  final selectedEndDate = Rx<DateTime>(DateTime.now());
  
  // Loading states
  final isLoadingSales = false.obs;
  final isLoadingInventory = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialReports();
  }

  Future<void> loadInitialReports() async {
    isLoadingSales.value = true;
    isLoadingInventory.value = true;
    
    try {
      await Future.wait([
        loadDailySalesReport(),
        loadTopSellingMedicines(),
        loadLowStockMedicines(),
        loadExpiringMedicines(),
      ]);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل التقارير',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingSales.value = false;
      isLoadingInventory.value = false;
    }
  }

  Future<void> loadDailySalesReport() async {
    final report = await _databaseService.getDailySalesReport(DateTime.now());
    dailySales.value = report;
  }

  Future<void> loadTopSellingMedicines() async {
    final medicines = await _databaseService.getTopSellingMedicines();
    topSellingMedicines.value = medicines;
  }

  Future<void> loadLowStockMedicines() async {
    final medicines = await _databaseService.getLowStockMedicines(10); // Threshold of 10
    lowStockMedicines.value = medicines;
  }

  Future<void> loadExpiringMedicines() async {
    final medicines = await _databaseService.getExpiringMedicines(30); // 30 days threshold
    expiringMedicines.value = medicines;
  }

  void setDateRange(DateTime start, DateTime end) {
    selectedStartDate.value = start;
    selectedEndDate.value = end;
    loadCustomDateRangeReport();
  }

  Future<void> loadCustomDateRangeReport() async {
    // Implementation for custom date range report
  }

  Future<void> exportSalesReport() async {
    try {
      final font = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
      final ttf = pw.Font.ttf(font);
      
      final pdf = pw.Document();
      
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('تقرير المبيعات', style: pw.TextStyle(font: ttf, fontSize: 24)),
              pw.SizedBox(height: 20),
              
              // Daily Sales Summary
              pw.Text('ملخص المبيعات اليومية', style: pw.TextStyle(font: ttf, fontSize: 18)),
              pw.Container(
                padding: pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all()
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('عدد المبيعات: ${dailySales[0]['total_sales']}', 
                      style: pw.TextStyle(font: ttf)),
                    pw.Text('إجمالي المبيعات: ${dailySales[0]['total_amount']} جنيه',
                      style: pw.TextStyle(font: ttf)),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Top Selling Products
              pw.Text('الأدوية الأكثر مبيعاً', style: pw.TextStyle(font: ttf, fontSize: 18)),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // Header
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('اسم الدواء', style: pw.TextStyle(font: ttf)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('الكمية المباعة', style: pw.TextStyle(font: ttf)),
                      ),
                    ],
                  ),
                  // Data rows
                  ...topSellingMedicines.map((medicine) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(medicine['name'], style: pw.TextStyle(font: ttf)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          '${medicine['total_quantity']}',
                          style: pw.TextStyle(font: ttf),
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ],
          ),
        ),
      ));

      await Printing.sharePdf(bytes: await pdf.save());
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تصدير التقرير: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}