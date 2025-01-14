import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import '../controllers/reports_controller.dart';

class ReportsView extends GetView<ReportsController> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('التقارير'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'المبيعات'),
              Tab(text: 'المخزون'),
              Tab(text: 'تحليلات'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSalesReport(),
            _buildInventoryReport(),
            _buildAnalytics(),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesReport() {
    return Obx(() {
      if (controller.isLoadingSales.value) {
        return Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ملخص المبيعات اليومية',
                      style: Get.textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'عدد المبيعات: ${controller.dailySales.isEmpty ? 0 : controller.dailySales[0]['total_sales']}',
                      style: Get.textTheme.titleMedium,
                    ),
                    Text(
                      'إجمالي المبيعات: ${controller.dailySales.isEmpty ? 0 : controller.dailySales[0]['total_amount']} جنيه',
                      style: Get.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.date_range),
              label: Text('تحديد نطاق زمني'),
              onPressed: () => _showDateRangePicker(context as BuildContext),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.picture_as_pdf),
              label: Text('تصدير التقرير'),
              onPressed: () => controller.exportSalesReport(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInventoryReport() {
    return Obx(() {
      if (controller.isLoadingInventory.value) {
        return Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الأدوية الأكثر مبيعاً',
                      style: Get.textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    for (var medicine in controller.topSellingMedicines)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(medicine['name']),
                            Text('${medicine['total_quantity']} قطعة'),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تنبيهات المخزون',
                      style: Get.textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    if (controller.lowStockMedicines.isNotEmpty) ...[
                      Text('أدوية منخفضة المخزون:'),
                      for (var medicine in controller.lowStockMedicines)
                        ListTile(
                          title: Text(medicine.name),
                          subtitle: Text('الكمية المتبقية: ${medicine.quantity}'),
                          leading: Icon(Icons.warning, color: Colors.orange),
                        ),
                    ],
                    if (controller.expiringMedicines.isNotEmpty) ...[
                      Divider(),
                      Text('أدوية قريبة من انتهاء الصلاحية:'),
                      for (var medicine in controller.expiringMedicines)
                        ListTile(
                          title: Text(medicine.name),
                          subtitle: Text(
                            'تاريخ الانتهاء: ${DateFormat('dd/MM/yyyy').format(medicine.expiryDate)}',
                          ),
                          leading: Icon(Icons.event_busy, color: Colors.red),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAnalytics() {
    return Obx(() {
      if (controller.isLoadingSales.value) {
        return Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تحليل المبيعات',
                      style: Get.textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    // TODO: Add charts and analytics
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      saveText: 'اختيار',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
      locale: const Locale('ar', 'EG'),
    );

    if (result != null) {
      controller.setDateRange(result.start, result.end);
    }
  }
}