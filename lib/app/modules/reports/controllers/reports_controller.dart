import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/medicine.dart';
import '../../../data/models/sale.dart';

class ReportsController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  
  // Observable variables for sales report
  final dailySales = <Map<String, dynamic>>[].obs;
  final weeklySales = <Map<String, dynamic>>[].obs;
  final monthlySales = <Map<String, dynamic>>[].obs;
  final customDateRangeSales = <Map<String, dynamic>>[].obs;
  
  // Observable variables for inventory report
  final topSellingMedicines = <Map<String, dynamic>>[].obs;
  final lowStockMedicines = <Medicine>[].obs;
  final expiringMedicines = <Medicine>[].obs;
  
  // Financial analytics observables
  final totalSales = 0.0.obs;
  final totalTransactions = 0.obs;
  final totalRevenue = 0.0.obs;
  final netProfit = 0.0.obs;
  final profitMargin = 0.0.obs;
  final averageInvoice = 0.0.obs;
  
  // Inventory analytics observables
  final totalProducts = 0.obs;
  final inventoryValue = 0.0.obs;
  final purchaseValue = 0.0.obs;
  final sellingValue = 0.0.obs;
  final lowStockCount = 0.obs;
  final expiringCount = 0.obs;
  
  // Performance analytics observables
  final stockTurnoverRate = 0.0.obs;
  final averageSaleTime = 0.0.obs;
  final customerSatisfaction = 0.0.obs;
  final salesGrowth = 0.0.obs;
  
  // Selected date range
  final selectedStartDate = Rx<DateTime>(DateTime.now().subtract(Duration(days: 30)));
  final selectedEndDate = Rx<DateTime>(DateTime.now());
  
  // Loading states
  final isLoadingSales = false.obs;
  final isLoadingInventory = false.obs;
  final isLoadingFinancial = false.obs;
  final isLoadingPerformance = false.obs;
  final isExporting = false.obs;

  // Settings
  final autoRefresh = true.obs;
  final refreshInterval = 300.obs; // 5 minutes in seconds

  @override
  void onInit() {
    super.onInit();
    loadInitialReports();
    _setupAutoRefresh();
  }

  void _setupAutoRefresh() {
    if (autoRefresh.value) {
      ever(autoRefresh, (bool enabled) {
        if (enabled) {
          _startAutoRefresh();
        } else {
          _stopAutoRefresh();
        }
      });
      _startAutoRefresh();
    }
  }

  void _startAutoRefresh() {
    // Setup periodic refresh every 5 minutes
    Stream.periodic(Duration(seconds: refreshInterval.value)).listen((_) {
      if (autoRefresh.value) {
        refreshAllReports();
      }
    });
  }

  void _stopAutoRefresh() {
    // Auto refresh will be stopped when autoRefresh becomes false
  }

  Future<void> loadInitialReports() async {
    try {
      await Future.wait([
        loadSalesData(),
        loadInventoryReports(),
        loadFinancialAnalytics(),
        loadPerformanceAnalytics(),
      ]);
    } catch (e) {
      _handleError('تحميل التقارير', e);
    }
  }

  Future<void> refreshAllReports() async {
    try {
      Get.snackbar(
        'تحديث',
        'جاري تحديث جميع التقارير...',
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
        backgroundColor: Colors.blue.withOpacity(0.8),
        colorText: Colors.white,
      );
      
      await loadInitialReports();
      
      Get.snackbar(
        'تم التحديث',
        'تم تحديث جميع التقارير بنجاح',
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      _handleError('تحديث التقارير', e);
    }
  }

  // Sales Data Loading Methods
  Future<void> loadSalesData() async {
    isLoadingSales.value = true;
    try {
      await Future.wait([
        loadDailySalesReport(),
        loadWeeklySalesReport(),
        loadMonthlySalesReport(),
        loadTopSellingMedicines(),
        calculateSalesMetrics(),
      ]);
    } catch (e) {
      _handleError('تحميل بيانات المبيعات', e);
    } finally {
      isLoadingSales.value = false;
    }
  }

  Future<void> loadDailySalesReport() async {
    try {
      final report = await _databaseService.getDailySalesReport(DateTime.now());
      dailySales.value = report;
      
      if (report.isNotEmpty) {
        totalSales.value = report[0]['total_amount']?.toDouble() ?? 0.0;
        totalTransactions.value = report[0]['total_sales']?.toInt() ?? 0;
      }
    } catch (e) {
      print('Error loading daily sales report: $e');
    }
  }

  Future<void> loadWeeklySalesReport() async {
    try {
      final startOfWeek = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
      final endOfWeek = startOfWeek.add(Duration(days: 6));
      
      final report = await _databaseService.getCustomDateRangeSalesReport(startOfWeek, endOfWeek);
      weeklySales.value = report;
    } catch (e) {
      print('Error loading weekly sales report: $e');
    }
  }

  Future<void> loadMonthlySalesReport() async {
    try {
      final startOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
      final endOfMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
      
      final report = await _databaseService.getCustomDateRangeSalesReport(startOfMonth, endOfMonth);
      monthlySales.value = report;
    } catch (e) {
      print('Error loading monthly sales report: $e');
    }
  }

  Future<void> loadTopSellingMedicines() async {
    try {
      final medicines = await _databaseService.getTopSellingMedicines(limit: 10);
      topSellingMedicines.value = medicines;
    } catch (e) {
      print('Error loading top selling medicines: $e');
    }
  }

  Future<void> calculateSalesMetrics() async {
    try {
      // Calculate average invoice
      if (totalTransactions.value > 0) {
        averageInvoice.value = totalSales.value / totalTransactions.value;
      }
      
      // Calculate sales growth (compare with previous period)
      final previousPeriodSales = await _getPreviousPeriodSales();
      if (previousPeriodSales > 0) {
        salesGrowth.value = ((totalSales.value - previousPeriodSales) / previousPeriodSales) * 100;
      }
    } catch (e) {
      print('Error calculating sales metrics: $e');
    }
  }

  Future<double> _getPreviousPeriodSales() async {
    try {
      final previousStart = selectedStartDate.value.subtract(
        Duration(days: selectedEndDate.value.difference(selectedStartDate.value).inDays)
      );
      final previousEnd = selectedStartDate.value;
      
      final report = await _databaseService.getCustomDateRangeSalesReport(previousStart, previousEnd);
      return report.isNotEmpty ? report[0]['total_amount']?.toDouble() ?? 0.0 : 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // Inventory Data Loading Methods
  Future<void> loadInventoryReports() async {
    isLoadingInventory.value = true;
    try {
      await Future.wait([
        loadLowStockMedicines(),
        loadExpiringMedicines(),
        calculateInventoryMetrics(),
      ]);
    } catch (e) {
      _handleError('تحميل بيانات المخزون', e);
    } finally {
      isLoadingInventory.value = false;
    }
  }

  Future<void> loadLowStockMedicines() async {
    try {
      final medicines = await _databaseService.getLowStockMedicines(10);
      lowStockMedicines.value = medicines;
      lowStockCount.value = medicines.length;
    } catch (e) {
      print('Error loading low stock medicines: $e');
    }
  }

  Future<void> loadExpiringMedicines() async {
    try {
      final medicines = await _databaseService.getExpiringMedicines(30);
      expiringMedicines.value = medicines;
      expiringCount.value = medicines.length;
    } catch (e) {
      print('Error loading expiring medicines: $e');
    }
  }

  Future<void> calculateInventoryMetrics() async {
    try {
      final allMedicines = await _databaseService.getAllMedicines();
      totalProducts.value = allMedicines.length;
      
      double totalPurchaseValue = 0.0;
      double totalSellingValue = 0.0;
      
      for (var medicine in allMedicines) {
        totalPurchaseValue += medicine.quantity * medicine.purchasePrice;
        totalSellingValue += medicine.quantity * medicine.sellingPrice;
      }
      
      purchaseValue.value = totalPurchaseValue;
      sellingValue.value = totalSellingValue;
      inventoryValue.value = totalSellingValue;
    } catch (e) {
      print('Error calculating inventory metrics: $e');
    }
  }

  // Financial Analytics Methods
  Future<void> loadFinancialAnalytics() async {
    isLoadingFinancial.value = true;
    try {
      await Future.wait([
        calculateRevenue(),
        calculateProfit(),
        calculateProfitMargin(),
      ]);
    } catch (e) {
      _handleError('تحميل التحليل المالي', e);
    } finally {
      isLoadingFinancial.value = false;
    }
  }

  Future<void> calculateRevenue() async {
    try {
      totalRevenue.value = totalSales.value;
    } catch (e) {
      print('Error calculating revenue: $e');
    }
  }

  Future<void> calculateProfit() async {
    try {
      // Calculate net profit based on sales and cost of goods sold
      final costOfGoodsSold = await _calculateCostOfGoodsSold();
      netProfit.value = totalRevenue.value - costOfGoodsSold;
    } catch (e) {
      print('Error calculating profit: $e');
    }
  }

  Future<double> _calculateCostOfGoodsSold() async {
    try {
      // This would require tracking cost of goods for each sale
      // For now, we'll estimate based on purchase prices
      final allMedicines = await _databaseService.getAllMedicines();
      double totalCost = 0.0;
      
      for (var medicine in allMedicines) {
        // Estimate sold quantity based on total quantity vs current quantity
        // This is a simplified calculation
        totalCost += medicine.purchasePrice * (medicine.totalQuantity - medicine.quantity);
      }
      
      return totalCost;
    } catch (e) {
      return 0.0;
    }
  }

  Future<void> calculateProfitMargin() async {
    try {
      if (totalRevenue.value > 0) {
        profitMargin.value = (netProfit.value / totalRevenue.value) * 100;
      }
    } catch (e) {
      print('Error calculating profit margin: $e');
    }
  }

  // Performance Analytics Methods
  Future<void> loadPerformanceAnalytics() async {
    isLoadingPerformance.value = true;
    try {
      await Future.wait([
        calculateStockTurnoverRate(),
        calculateAverageSaleTime(),
        calculateCustomerSatisfaction(),
      ]);
    } catch (e) {
      _handleError('تحميل تحليل الأداء', e);
    } finally {
      isLoadingPerformance.value = false;
    }
  }

  Future<void> calculateStockTurnoverRate() async {
    try {
      // Stock Turnover Rate = Cost of Goods Sold / Average Inventory Value
      final costOfGoodsSold = await _calculateCostOfGoodsSold();
      if (inventoryValue.value > 0) {
        stockTurnoverRate.value = costOfGoodsSold / inventoryValue.value;
      }
    } catch (e) {
      print('Error calculating stock turnover rate: $e');
    }
  }

  Future<void> calculateAverageSaleTime() async {
    try {
      // This would require tracking sale processing times
      // For now, we'll use a mock value
      averageSaleTime.value = 12.0; // minutes
    } catch (e) {
      print('Error calculating average sale time: $e');
    }
  }

  Future<void> calculateCustomerSatisfaction() async {
    try {
      // This would require customer feedback data
      // For now, we'll use a mock value
      customerSatisfaction.value = 4.8; // out of 5
    } catch (e) {
      print('Error calculating customer satisfaction: $e');
    }
  }

  // Date Range Methods
  void setDateRange(DateTime start, DateTime end) {
    selectedStartDate.value = start;
    selectedEndDate.value = end;
    loadCustomDateRangeReport();
  }

  void setToday() {
    final today = DateTime.now();
    setDateRange(today, today);
  }

  void setThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    setDateRange(startOfWeek, endOfWeek);
  }

  void setThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    setDateRange(startOfMonth, endOfMonth);
  }

  void setLast3Months() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 3, 1);
    setDateRange(start, now);
  }

  Future<void> loadCustomDateRangeReport() async {
    try {
      isLoadingSales.value = true;
      final report = await _databaseService.getCustomDateRangeSalesReport(
        selectedStartDate.value,
        selectedEndDate.value,
      );
      customDateRangeSales.value = report;
      
      // Update metrics based on custom date range
      await calculateSalesMetrics();
    } catch (e) {
      _handleError('تحميل تقرير المدة المحددة', e);
    } finally {
      isLoadingSales.value = false;
    }
  }

  // Export Methods
  Future<void> exportAllReports() async {
    try {
      isExporting.value = true;
      
      Get.dialog(
        AlertDialog(
          title: Text('تصدير التقارير'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('جاري إنشاء جميع التقارير...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      await Future.wait([
        exportSalesReport(),
        exportInventoryReport(),
        exportFinancialReport(),
        exportPerformanceReport(),
      ]);

      Get.back(); // Close loading dialog

      Get.snackbar(
        'نجاح',
        'تم تصدير جميع التقارير بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      _handleError('تصدير التقارير', e);
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> exportSalesReport() async {
    try {
      final font = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
      final ttf = pw.Font.ttf(font);
      
      final pdf = pw.Document();
      
      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          // Header
          _buildPdfHeader(ttf, 'تقرير المبيعات'),
          pw.SizedBox(height: 30),
          
          // Date Range
          _buildDateRangeSection(ttf),
          pw.SizedBox(height: 20),
          
          // Sales Summary
          _buildSalesSummarySection(ttf),
          pw.SizedBox(height: 20),
          
          // Top Selling Products
          _buildTopSellingSection(ttf),
          pw.SizedBox(height: 20),
          
          // Daily Sales Details
          _buildDailySalesSection(ttf),
          
          pw.SizedBox(height: 30),
          _buildPdfFooter(ttf),
        ],
      ));

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'تقرير_المبيعات_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      _handleError('تصدير تقرير المبيعات', e);
    }
  }

  Future<void> exportInventoryReport() async {
    try {
      final font = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
      final ttf = pw.Font.ttf(font);
      
      final pdf = pw.Document();
      
      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          _buildPdfHeader(ttf, 'تقرير المخزون'),
          pw.SizedBox(height: 30),
          
          _buildInventorySummarySection(ttf),
          pw.SizedBox(height: 20),
          
          _buildLowStockSection(ttf),
          pw.SizedBox(height: 20),
          
          _buildExpiringMedicinesSection(ttf),
          
          pw.SizedBox(height: 30),
          _buildPdfFooter(ttf),
        ],
      ));

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'تقرير_المخزون_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      _handleError('تصدير تقرير المخزون', e);
    }
  }

  Future<void> exportFinancialReport() async {
    try {
      final font = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
      final ttf = pw.Font.ttf(font);
      
      final pdf = pw.Document();
      
      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          _buildPdfHeader(ttf, 'التقرير المالي'),
          pw.SizedBox(height: 30),
          
          _buildFinancialSummarySection(ttf),
          pw.SizedBox(height: 20),
          
          _buildProfitAnalysisSection(ttf),
          
          pw.SizedBox(height: 30),
          _buildPdfFooter(ttf),
        ],
      ));

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'التقرير_المالي_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      _handleError('تصدير التقرير المالي', e);
    }
  }

  Future<void> exportPerformanceReport() async {
    try {
      final font = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
      final ttf = pw.Font.ttf(font);
      
      final pdf = pw.Document();
      
      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          _buildPdfHeader(ttf, 'تقرير الأداء'),
          pw.SizedBox(height: 30),
          
          _buildPerformanceKPIsSection(ttf),
          
          pw.SizedBox(height: 30),
          _buildPdfFooter(ttf),
        ],
      ));

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'تقرير_الأداء_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      _handleError('تصدير تقرير الأداء', e);
    }
  }

  Future<void> exportToExcel() async {
    try {
      Get.snackbar(
        'معلومة',
        'ميزة تصدير Excel قيد التطوير',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      _handleError('تصدير Excel', e);
    }
  }

  Future<void> shareReport() async {
    try {
      Get.snackbar(
        'معلومة',
        'ميزة مشاركة التقارير قيد التطوير',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      _handleError('مشاركة التقرير', e);
    }
  }

  // PDF Building Helper Methods
  pw.Widget _buildPdfHeader(pw.Font ttf, String title) {
    return pw.Container(
      padding: pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'الصيدلية البيطرية',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                title,
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 18,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'التاريخ: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                style: pw.TextStyle(font: ttf, fontSize: 12, color: PdfColors.white),
              ),
              pw.Text(
                'الوقت: ${DateFormat('HH:mm').format(DateTime.now())}',
                style: pw.TextStyle(font: ttf, fontSize: 12, color: PdfColors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDateRangeSection(pw.Font ttf) {
    return pw.Container(
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'الفترة الزمنية',
            style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'من: ${DateFormat('dd/MM/yyyy').format(selectedStartDate.value)}',
            style: pw.TextStyle(font: ttf, fontSize: 12),
          ),
          pw.Text(
            'إلى: ${DateFormat('dd/MM/yyyy').format(selectedEndDate.value)}',
            style: pw.TextStyle(font: ttf, fontSize: 12),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSalesSummarySection(pw.Font ttf) {
    return pw.Container(
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ملخص المبيعات',
            style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('إجمالي المبيعات:', style: pw.TextStyle(font: ttf)),
              pw.Text('${totalSales.value.toStringAsFixed(2)} جنيه', 
                style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('عدد الفواتير:', style: pw.TextStyle(font: ttf)),
              pw.Text('${totalTransactions.value}', 
                style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('متوسط الفاتورة:', style: pw.TextStyle(font: ttf)),
              pw.Text('${averageInvoice.value.toStringAsFixed(2)} جنيه', 
                style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTopSellingSection(pw.Font ttf) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'الأدوية الأكثر مبيعاً',
          style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell(ttf, 'الترتيب', isHeader: true),
                _buildTableCell(ttf, 'اسم الدواء', isHeader: true),
                _buildTableCell(ttf, 'الكمية المباعة', isHeader: true),
              ],
            ),
            for (int i = 0; i < topSellingMedicines.length && i < 10; i++)
              pw.TableRow(
                children: [
                  _buildTableCell(ttf, '${i + 1}'),
                  _buildTableCell(ttf, topSellingMedicines[i]['name'] ?? ''),
                  _buildTableCell(ttf, '${topSellingMedicines[i]['total_quantity'] ?? 0}'),
                ],
              ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildDailySalesSection(pw.Font ttf) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'تفاصيل المبيعات اليومية',
          style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        if (dailySales.isNotEmpty)
          pw.Container(
            padding: pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey),
            ),
            child: pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('عدد المبيعات:', style: pw.TextStyle(font: ttf)),
                    pw.Text('${dailySales[0]['total_sales'] ?? 0}', 
                      style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('إجمالي المبيعات:', style: pw.TextStyle(font: ttf)),
                    pw.Text('${dailySales[0]['total_amount'] ?? 0} جنيه', 
                      style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          )
        else
          pw.Text(
            'لا توجد مبيعات لهذا اليوم',
            style: pw.TextStyle(font: ttf, color: PdfColors.grey),
          ),
      ],
    );
  }

  pw.Widget _buildInventorySummarySection(pw.Font ttf) {
    return pw.Container(
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ملخص المخزون',
            style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('إجمالي الأصناف:', style: pw.TextStyle(font: ttf)),
              pw.Text('${totalProducts.value}', 
                style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('قيمة المخزون:', style: pw.TextStyle(font: ttf)),
              pw.Text('${inventoryValue.value.toStringAsFixed(2)} جنيه', 
                style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('مخزون منخفض:', style: pw.TextStyle(font: ttf)),
              pw.Text('${lowStockCount.value} صنف', 
                style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('قريب الانتهاء:', style: pw.TextStyle(font: ttf)),
              pw.Text('${expiringCount.value} صنف', 
                style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, color: PdfColors.orange)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildLowStockSection(pw.Font ttf) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'أدوية بمخزون منخفض',
          style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        if (lowStockMedicines.isNotEmpty)
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell(ttf, 'اسم الدواء', isHeader: true),
                  _buildTableCell(ttf, 'الكمية المتبقية', isHeader: true),
                ],
              ),
              for (var medicine in lowStockMedicines)
                pw.TableRow(
                  children: [
                    _buildTableCell(ttf, medicine.name),
                    _buildTableCell(ttf, '${medicine.quantity}'),
                  ],
                ),
            ],
          )
        else
          pw.Text(
            'لا توجد أدوية بمخزون منخفض',
            style: pw.TextStyle(font: ttf, color: PdfColors.green),
          ),
      ],
    );
  }

  pw.Widget _buildExpiringMedicinesSection(pw.Font ttf) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'أدوية قريبة الانتهاء',
          style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        if (expiringMedicines.isNotEmpty)
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell(ttf, 'اسم الدواء', isHeader: true),
                  _buildTableCell(ttf, 'تاريخ الانتهاء', isHeader: true),
                  _buildTableCell(ttf, 'الأيام المتبقية', isHeader: true),
                ],
              ),
              for (var medicine in expiringMedicines)
                pw.TableRow(
                  children: [
                    _buildTableCell(ttf, medicine.name),
                    _buildTableCell(ttf, DateFormat('dd/MM/yyyy').format(medicine.expiryDate)),
                    _buildTableCell(ttf, '${medicine.expiryDate.difference(DateTime.now()).inDays}'),
                  ],
                ),
            ],
          )
        else
          pw.Text(
            'لا توجد أدوية قريبة الانتهاء',
            style: pw.TextStyle(font: ttf, color: PdfColors.green),
          ),
      ],
    );
  }

  pw.Widget _buildFinancialSummarySection(pw.Font ttf) {
    return pw.Container(
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'الملخص المالي',
            style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('إجمالي الإيرادات:', style: pw.TextStyle(font: ttf)),
              pw.Text('${totalRevenue.value.toStringAsFixed(2)} جنيه', 
                style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('صافي الربح:', style: pw.TextStyle(font: ttf)),
              pw.Text('${netProfit.value.toStringAsFixed(2)} جنيه', 
                style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, color: PdfColors.green)),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('نسبة الربح:', style: pw.TextStyle(font: ttf)),
              pw.Text('${profitMargin.value.toStringAsFixed(1)}%', 
                style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('متوسط الفاتورة:', style: pw.TextStyle(font: ttf)),
              pw.Text('${averageInvoice.value.toStringAsFixed(2)} جنيه', 
                style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildProfitAnalysisSection(pw.Font ttf) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'تحليل الربحية',
          style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey),
          ),
          child: pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('قيمة الشراء:', style: pw.TextStyle(font: ttf)),
                  pw.Text('${purchaseValue.value.toStringAsFixed(2)} جنيه', 
                    style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('قيمة البيع:', style: pw.TextStyle(font: ttf)),
                  pw.Text('${sellingValue.value.toStringAsFixed(2)} جنيه', 
                    style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('الربح المتوقع:', style: pw.TextStyle(font: ttf)),
                  pw.Text('${(sellingValue.value - purchaseValue.value).toStringAsFixed(2)} جنيه', 
                    style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, color: PdfColors.green)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPerformanceKPIsSection(pw.Font ttf) {
    return pw.Container(
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'مؤشرات الأداء الرئيسية',
            style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('معدل دوران المخزون:', style: pw.TextStyle(font: ttf)),
              pw.Text('${stockTurnoverRate.value.toStringAsFixed(2)} مرة/شهر', 
                style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('متوسط وقت البيع:', style: pw.TextStyle(font: ttf)),
              pw.Text('${averageSaleTime.value.toStringAsFixed(1)} دقيقة', 
                style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('رضا العملاء:', style: pw.TextStyle(font: ttf)),
              pw.Text('${customerSatisfaction.value.toStringAsFixed(1)} من 5', 
                style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('نمو المبيعات:', style: pw.TextStyle(font: ttf)),
              pw.Text('${salesGrowth.value >= 0 ? '+' : ''}${salesGrowth.value.toStringAsFixed(1)}%', 
                style: pw.TextStyle(
                  font: ttf, 
                  fontWeight: pw.FontWeight.bold,
                  color: salesGrowth.value >= 0 ? PdfColors.green : PdfColors.red,
                )),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTableCell(pw.Font ttf, String text, {bool isHeader = false}) {
    return pw.Container(
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: ttf,
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildPdfFooter(pw.Font ttf) {
    return pw.Container(
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'الصيدلية البيطرية - نظام إدارة الصيدلية',
            style: pw.TextStyle(font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold),
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
            'للاستفسارات: info@vetpharmacy.com | 01234567890',
            style: pw.TextStyle(font: ttf, fontSize: 10),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Analytics and Insights Methods
  Map<String, dynamic> getBusinessInsights() {
    List<String> insights = [];
    List<String> recommendations = [];

    // Sales insights
    if (salesGrowth.value > 10) {
      insights.add('المبيعات تنمو بشكل ممتاز (${salesGrowth.value.toStringAsFixed(1)}%)');
    } else if (salesGrowth.value < 0) {
      insights.add('المبيعات تتراجع، يحتاج لمراجعة الاستراتيجية');
      recommendations.add('مراجعة استراتيجية التسويق والتسعير');
    }

    // Inventory insights
    if (lowStockCount.value > 5) {
      insights.add('عدد كبير من الأدوية بمخزون منخفض (${lowStockCount.value})');
      recommendations.add('إعادة تموين الأدوية منخفضة المخزون فوراً');
    }

    if (expiringCount.value > 3) {
      insights.add('${expiringCount.value} صنف قريب من انتهاء الصلاحية');
      recommendations.add('عمل عروض خاصة للأدوية قريبة الانتهاء');
    }

    // Profitability insights
    if (profitMargin.value > 25) {
      insights.add('هامش الربح ممتاز (${profitMargin.value.toStringAsFixed(1)}%)');
    } else if (profitMargin.value < 15) {
      insights.add('هامش الربح منخفض، يحتاج تحسين');
      recommendations.add('مراجعة تكاليف الشراء وأسعار البيع');
    }

    // Performance insights
    if (stockTurnoverRate.value < 2) {
      insights.add('معدل دوران المخزون بطيء');
      recommendations.add('تحسين إدارة المخزون وزيادة المبيعات');
    }

    return {
      'insights': insights,
      'recommendations': recommendations,
      'overall_score': _calculateOverallScore(),
    };
  }

  double _calculateOverallScore() {
    double score = 0;
    int factors = 0;

    // Sales growth factor
    if (salesGrowth.value > 0) {
      score += salesGrowth.value.clamp(0, 20);
      factors++;
    }

    // Profit margin factor
    score += profitMargin.value.clamp(0, 30);
    factors++;

    // Stock management factor
    double stockScore = 100;
    if (lowStockCount.value > 5) stockScore -= 20;
    if (expiringCount.value > 3) stockScore -= 15;
    score += stockScore.clamp(0, 25);
    factors++;

    // Turnover rate factor
    score += (stockTurnoverRate.value * 10).clamp(0, 25);
    factors++;

    return factors > 0 ? score / factors : 0;
  }

  // Prediction Methods
  Map<String, dynamic> getSalesPrediction() {
    // Simple linear prediction based on current trend
    final currentTrend = salesGrowth.value / 100;
    final predictedNextMonth = totalSales.value * (1 + currentTrend);
    final predictedNextQuarter = totalSales.value * (1 + currentTrend * 3);

    return {
      'next_month': predictedNextMonth,
      'next_quarter': predictedNextQuarter,
      'confidence': _calculatePredictionConfidence(),
    };
  }

  double _calculatePredictionConfidence() {
    // Simple confidence calculation based on data consistency
    if (totalTransactions.value < 10) return 0.3;
    if (totalTransactions.value < 50) return 0.6;
    return 0.8;
  }

  // Settings Methods
  void updateAutoRefresh(bool enabled) {
    autoRefresh.value = enabled;
    if (enabled) {
      _startAutoRefresh();
    }
  }

  void updateRefreshInterval(int seconds) {
    refreshInterval.value = seconds;
    if (autoRefresh.value) {
      _startAutoRefresh(); // Restart with new interval
    }
  }

  // Error Handling
  void _handleError(String operation, dynamic error) {
    print('Error in $operation: $error');
    Get.snackbar(
      'خطأ',
      'حدث خطأ في $operation',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  // Data Export Helpers
  Map<String, dynamic> exportDataToJson() {
    return {
      'sales_data': {
        'total_sales': totalSales.value,
        'total_transactions': totalTransactions.value,
        'average_invoice': averageInvoice.value,
        'sales_growth': salesGrowth.value,
      },
      'inventory_data': {
        'total_products': totalProducts.value,
        'inventory_value': inventoryValue.value,
        'low_stock_count': lowStockCount.value,
        'expiring_count': expiringCount.value,
      },
      'financial_data': {
        'total_revenue': totalRevenue.value,
        'net_profit': netProfit.value,
        'profit_margin': profitMargin.value,
      },
      'performance_data': {
        'stock_turnover_rate': stockTurnoverRate.value,
        'average_sale_time': averageSaleTime.value,
        'customer_satisfaction': customerSatisfaction.value,
      },
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  // Cleanup
  @override
  void onClose() {
    // Cleanup any resources if needed
    super.onClose();
  }
}

// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:flutter/services.dart';
// import '../../../data/services/database_service.dart';
// import '../../../data/models/medicine.dart';
// import '../../../data/models/sale.dart';

// class ReportsController extends GetxController {
//   final DatabaseService _databaseService = Get.find<DatabaseService>();
  
//   // Observable variables for sales report
//   final dailySales = <Map<String, dynamic>>[].obs;
//   final weeklySales = <Map<String, dynamic>>[].obs;
//   final monthlySales = <Map<String, dynamic>>[].obs;
  
//   // Observable variables for inventory report
//   final topSellingMedicines = <Map<String, dynamic>>[].obs;
//   final lowStockMedicines = <Medicine>[].obs;
//   final expiringMedicines = <Medicine>[].obs;
  
//   // Selected date range
//   final selectedStartDate = Rx<DateTime>(DateTime.now());
//   final selectedEndDate = Rx<DateTime>(DateTime.now());
  
//   // Loading states
//   final isLoadingSales = false.obs;
//   final isLoadingInventory = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     loadInitialReports();
//   }

//   Future<void> loadInitialReports() async {
//     isLoadingSales.value = true;
//     isLoadingInventory.value = true;
    
//     try {
//       await Future.wait([
//         loadDailySalesReport(),
//         loadTopSellingMedicines(),
//         loadLowStockMedicines(),
//         loadExpiringMedicines(),
//       ]);
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'حدث خطأ أثناء تحميل التقارير',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     } finally {
//       isLoadingSales.value = false;
//       isLoadingInventory.value = false;
//     }
//   }

//   Future<void> loadDailySalesReport() async {
//     final report = await _databaseService.getDailySalesReport(DateTime.now());
//     dailySales.value = report;
//   }

//   Future<void> loadTopSellingMedicines() async {
//     final medicines = await _databaseService.getTopSellingMedicines();
//     topSellingMedicines.value = medicines;
//   }

//   Future<void> loadLowStockMedicines() async {
//     final medicines = await _databaseService.getLowStockMedicines(10); // Threshold of 10
//     lowStockMedicines.value = medicines;
//   }

//   Future<void> loadExpiringMedicines() async {
//     final medicines = await _databaseService.getExpiringMedicines(30); // 30 days threshold
//     expiringMedicines.value = medicines;
//   }

//   void setDateRange(DateTime start, DateTime end) {
//     selectedStartDate.value = start;
//     selectedEndDate.value = end;
//     loadCustomDateRangeReport();
//   }

//   Future<void> loadCustomDateRangeReport() async {
//     // Implementation for custom date range report
//   }

//   Future<void> exportSalesReport() async {
//     try {
//       final font = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
//       final ttf = pw.Font.ttf(font);
      
//       final pdf = pw.Document();
      
//       pdf.addPage(pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (context) => pw.Directionality(
//           textDirection: pw.TextDirection.rtl,
//           child: pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text('تقرير المبيعات', style: pw.TextStyle(font: ttf, fontSize: 24)),
//               pw.SizedBox(height: 20),
              
//               // Daily Sales Summary
//               pw.Text('ملخص المبيعات اليومية', style: pw.TextStyle(font: ttf, fontSize: 18)),
//               pw.Container(
//                 padding: pw.EdgeInsets.all(10),
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all()
//                 ),
//                 child: pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     pw.Text('عدد المبيعات: ${dailySales[0]['total_sales']}', 
//                       style: pw.TextStyle(font: ttf)),
//                     pw.Text('إجمالي المبيعات: ${dailySales[0]['total_amount']} جنيه',
//                       style: pw.TextStyle(font: ttf)),
//                   ],
//                 ),
//               ),
              
//               pw.SizedBox(height: 20),
              
//               // Top Selling Products
//               pw.Text('الأدوية الأكثر مبيعاً', style: pw.TextStyle(font: ttf, fontSize: 18)),
//               pw.Table(
//                 border: pw.TableBorder.all(),
//                 children: [
//                   // Header
//                   pw.TableRow(
//                     children: [
//                       pw.Padding(
//                         padding: pw.EdgeInsets.all(5),
//                         child: pw.Text('اسم الدواء', style: pw.TextStyle(font: ttf)),
//                       ),
//                       pw.Padding(
//                         padding: pw.EdgeInsets.all(5),
//                         child: pw.Text('الكمية المباعة', style: pw.TextStyle(font: ttf)),
//                       ),
//                     ],
//                   ),
//                   // Data rows
//                   ...topSellingMedicines.map((medicine) => pw.TableRow(
//                     children: [
//                       pw.Padding(
//                         padding: pw.EdgeInsets.all(5),
//                         child: pw.Text(medicine['name'], style: pw.TextStyle(font: ttf)),
//                       ),
//                       pw.Padding(
//                         padding: pw.EdgeInsets.all(5),
//                         child: pw.Text(
//                           '${medicine['total_quantity']}',
//                           style: pw.TextStyle(font: ttf),
//                         ),
//                       ),
//                     ],
//                   )),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ));

//       await Printing.sharePdf(bytes: await pdf.save());
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'حدث خطأ أثناء تصدير التقرير: $e',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }
// }