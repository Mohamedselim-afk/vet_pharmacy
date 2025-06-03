import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/reports_controller.dart';

class ReportsView extends GetView<ReportsController> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: TabBarView(
          children: [
            _buildSalesReport(),
            _buildInventoryReport(),
            _buildFinancialAnalytics(),
            _buildPerformanceAnalytics(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'التقارير والتحليلات',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Get.theme.primaryColor,
      foregroundColor: Colors.white,
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'export_all':
                controller.exportAllReports();
                break;
              case 'settings':
                _showReportSettings();
                break;
              case 'refresh':
                controller.refreshAllReports();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'export_all',
              child: Row(
                children: [
                  Icon(Icons.download_outlined, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('تصدير جميع التقارير'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh_outlined, color: Colors.green),
                  SizedBox(width: 8),
                  Text('تحديث البيانات'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('إعدادات التقارير'),
                ],
              ),
            ),
          ],
        ),
      ],
      bottom: TabBar(
        isScrollable: true,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: [
          Tab(
            icon: Icon(Icons.point_of_sale_outlined),
            text: 'المبيعات',
          ),
          Tab(
            icon: Icon(Icons.inventory_2_outlined),
            text: 'المخزون',
          ),
          Tab(
            icon: Icon(Icons.analytics_outlined),
            text: 'التحليل المالي',
          ),
          Tab(
            icon: Icon(Icons.trending_up_outlined),
            text: 'الأداء',
          ),
        ],
      ),
    );
  }

  Widget _buildSalesReport() {
    return Obx(() {
      if (controller.isLoadingSales.value) {
        return _buildLoadingState();
      }

      return RefreshIndicator(
        onRefresh: controller.loadDailySalesReport,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Range Selector
              _buildDateRangeSelector(),
              SizedBox(height: 20),

              // Sales Overview Cards
              _buildSalesOverviewCards(),
              SizedBox(height: 20),

              // Sales Trend Chart
              _buildSalesTrendCard(),
              SizedBox(height: 20),

              // Top Selling Products
              _buildTopSellingProductsCard(),
              SizedBox(height: 20),

              // Daily Sales Details
              _buildDailySalesDetails(),
              SizedBox(height: 20),

              // Export Actions
              _buildExportActions(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInventoryReport() {
    return Obx(() {
      if (controller.isLoadingInventory.value) {
        return _buildLoadingState();
      }

      return RefreshIndicator(
        onRefresh: controller.loadInventoryReports,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Inventory Overview
              _buildInventoryOverviewCards(),
              SizedBox(height: 20),

              // Stock Alerts
              _buildStockAlertsCard(),
              SizedBox(height: 20),

              // Expiring Medicines
              _buildExpiringMedicinesCard(),
              SizedBox(height: 20),

              // Inventory Value Analysis
              _buildInventoryValueCard(),
              SizedBox(height: 20),

              // Low Stock Items
              _buildLowStockItemsCard(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFinancialAnalytics() {
    return Obx(() {
      if (controller.isLoadingSales.value) {
        return _buildLoadingState();
      }

      return RefreshIndicator(
        onRefresh: controller.loadFinancialAnalytics,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Financial Summary
              _buildFinancialSummaryCards(),
              SizedBox(height: 20),

              // Profit Analysis
              _buildProfitAnalysisCard(),
              SizedBox(height: 20),

              // Revenue Breakdown
              _buildRevenueBreakdownCard(),
              SizedBox(height: 20),

              // Expense Analysis
              _buildExpenseAnalysisCard(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPerformanceAnalytics() {
    return Obx(() {
      if (controller.isLoadingSales.value) {
        return _buildLoadingState();
      }

      return RefreshIndicator(
        onRefresh: controller.loadPerformanceAnalytics,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Performance KPIs
              _buildPerformanceKPIs(),
              SizedBox(height: 20),

              // Customer Analytics
              _buildCustomerAnalyticsCard(),
              SizedBox(height: 20),

              // Product Performance
              _buildProductPerformanceCard(),
              SizedBox(height: 20),

              // Seasonal Analysis
              _buildSeasonalAnalysisCard(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Get.theme.primaryColor),
                ),
                SizedBox(height: 16),
                Text(
                  'جاري تحميل التقارير...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.date_range_outlined, color: Colors.blue[700]),
              SizedBox(width: 12),
              Text(
                'الفترة الزمنية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Obx(() => _buildDateButton(
                      'من تاريخ',
                      DateFormat('dd/MM/yyyy')
                          .format(controller.selectedStartDate.value),
                      () => _selectStartDate(),
                    )),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Obx(() => _buildDateButton(
                      'إلى تاريخ',
                      DateFormat('dd/MM/yyyy')
                          .format(controller.selectedEndDate.value),
                      () => _selectEndDate(),
                    )),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildQuickDateButton('اليوم', () => controller.setToday()),
              SizedBox(width: 8),
              _buildQuickDateButton('أسبوع', () => controller.setThisWeek()),
              SizedBox(width: 8),
              _buildQuickDateButton('شهر', () => controller.setThisMonth()),
              SizedBox(width: 8),
              _buildQuickDateButton(
                  '3 شهور', () => controller.setLast3Months()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(String label, String date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Text(
              date,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue[600],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSalesOverviewCards() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'إجمالي المبيعات',
            '${controller.totalSales.value.toStringAsFixed(2)} جنيه',
            Icons.attach_money_outlined,
            Colors.green,
            '+12%',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'عدد الفواتير',
            '${controller.totalTransactions.value}',
            Icons.receipt_outlined,
            Colors.blue,
            '+8%',
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryOverviewCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'إجمالي الأصناف',
                '${controller.totalProducts.value}',
                Icons.inventory_2_outlined,
                Colors.purple,
                '',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'قيمة المخزون',
                '${controller.inventoryValue.value.toStringAsFixed(2)} جنيه',
                Icons.account_balance_wallet_outlined,
                Colors.orange,
                '',
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'مخزون منخفض',
                '${controller.lowStockCount.value}',
                Icons.warning_outlined,
                Colors.red,
                '',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'قريب الانتهاء',
                '${controller.expiringCount.value}',
                Icons.schedule_outlined,
                Colors.amber,
                '',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color, String change) {
    return Container(
      padding: EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (change.isNotEmpty) ...[
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTrendCard() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(Icons.trending_up_outlined, color: Get.theme.primaryColor),
              SizedBox(width: 12),
              Text(
                'اتجاه المبيعات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.fullscreen_outlined),
                onPressed: () => _showFullScreenChart(),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'رسم بياني لاتجاه المبيعات',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'سيتم إضافة مكتبة الرسوم البيانية قريباً',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSellingProductsCard() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(Icons.star_outlined, color: Colors.amber),
              SizedBox(width: 12),
              Text(
                'الأدوية الأكثر مبيعاً',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              TextButton(
                child: Text('عرض الكل'),
                onPressed: () => _showAllTopSelling(),
              ),
            ],
          ),
          SizedBox(height: 16),
          Obx(() {
            if (controller.topSellingMedicines.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'لا توجد بيانات متاحة',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: controller.topSellingMedicines.take(5).map((medicine) {
                final index = controller.topSellingMedicines.indexOf(medicine);
                return _buildTopSellingItem(medicine, index + 1);
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTopSellingItem(Map<String, dynamic> medicine, int rank) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine['name'] ?? 'غير محدد',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'مباع: ${medicine['total_quantity']} قطعة',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[400]!;
      default:
        return Colors.blue;
    }
  }

  Widget _buildStockAlertsCard() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(Icons.notification_important_outlined, color: Colors.orange),
              SizedBox(width: 12),
              Text(
                'تنبيهات المخزون',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Obx(() {
            final alertCount =
                controller.lowStockCount.value + controller.expiringCount.value;
            if (alertCount == 0) {
              return Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outlined, color: Colors.green),
                    SizedBox(width: 12),
                    Text(
                      'لا توجد تنبيهات حالياً',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                if (controller.lowStockCount.value > 0)
                  _buildAlertItem(
                    'مخزون منخفض',
                    '${controller.lowStockCount.value} صنف',
                    Colors.orange,
                    Icons.warning_outlined,
                    () => _showLowStockDetails(),
                  ),
                if (controller.expiringCount.value > 0)
                  _buildAlertItem(
                    'قريب الانتهاء',
                    '${controller.expiringCount.value} صنف',
                    Colors.red,
                    Icons.schedule_outlined,
                    () => _showExpiringDetails(),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String title, String count, Color color, IconData icon,
      VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  Text(
                    count,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiringMedicinesCard() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(Icons.schedule_outlined, color: Colors.red),
              SizedBox(width: 12),
              Text(
                'الأدوية قريبة الانتهاء',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              TextButton(
                child: Text('عرض الكل'),
                onPressed: () => _showExpiringDetails(),
              ),
            ],
          ),
          SizedBox(height: 16),
          Obx(() {
            if (controller.expiringMedicines.isEmpty) {
              return Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outlined,
                      size: 48,
                      color: Colors.green[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'لا توجد أدوية قريبة الانتهاء',
                      style: TextStyle(
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: controller.expiringMedicines.take(3).map((medicine) {
                final daysUntilExpiry =
                    medicine.expiryDate.difference(DateTime.now()).inDays;
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            Icon(Icons.event_busy, color: Colors.red, size: 20),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medicine.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'ينتهي خلال $daysUntilExpiry يوم',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM').format(medicine.expiryDate),
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInventoryValueCard() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: Colors.purple),
              SizedBox(width: 12),
              Text(
                'تحليل قيمة المخزون',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildValueItem(
                    'قيمة الشراء',
                    '${controller.purchaseValue.value.toStringAsFixed(2)} جنيه',
                    Colors.blue),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildValueItem(
                    'قيمة البيع',
                    '${controller.sellingValue.value.toStringAsFixed(2)} جنيه',
                    Colors.green),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[50]!, Colors.green[100]!],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الربح المتوقع',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[700],
                        ),
                      ),
                      Text(
                        '${(controller.sellingValue.value - controller.purchaseValue.value).toStringAsFixed(2)} جنيه',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueItem(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockItemsCard() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(Icons.warning_outlined, color: Colors.orange),
              SizedBox(width: 12),
              Text(
                'أدوية بمخزون منخفض',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              TextButton(
                child: Text('عرض الكل'),
                onPressed: () => _showLowStockDetails(),
              ),
            ],
          ),
          SizedBox(height: 16),
          Obx(() {
            if (controller.lowStockMedicines.isEmpty) {
              return Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outlined,
                      size: 48,
                      color: Colors.green[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'جميع الأدوية بمخزون جيد',
                      style: TextStyle(
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: controller.lowStockMedicines.take(3).map((medicine) {
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            Icon(Icons.warning, color: Colors.orange, size: 20),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medicine.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'الكمية المتبقية: ${medicine.quantity}',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${medicine.quantity}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFinancialSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'إجمالي الإيرادات',
                '${controller.totalRevenue.value.toStringAsFixed(2)} جنيه',
                Icons.monetization_on_outlined,
                Colors.green,
                '+15%',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'صافي الربح',
                '${controller.netProfit.value.toStringAsFixed(2)} جنيه',
                Icons.trending_up_outlined,
                Colors.blue,
                '+23%',
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'نسبة الربح',
                '${controller.profitMargin.value.toStringAsFixed(1)}%',
                Icons.percent_outlined,
                Colors.purple,
                '+2.1%',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'متوسط الفاتورة',
                '${controller.averageInvoice.value.toStringAsFixed(2)} جنيه',
                Icons.receipt_long_outlined,
                Colors.orange,
                '+8%',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfitAnalysisCard() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: Colors.green),
              SizedBox(width: 12),
              Text(
                'تحليل الربحية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pie_chart_outline,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'رسم بياني للربحية',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'سيتم إضافة تحليل الربحية قريباً',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueBreakdownCard() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(Icons.donut_small_outlined, color: Colors.blue),
              SizedBox(width: 12),
              Text(
                'تفصيل الإيرادات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildRevenueItem('مبيعات الأدوية', 85, Colors.blue),
          SizedBox(height: 12),
          _buildRevenueItem('خدمات إضافية', 10, Colors.green),
          SizedBox(height: 12),
          _buildRevenueItem('أخرى', 5, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildRevenueItem(String title, int percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildExpenseAnalysisCard() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(Icons.money_off_outlined, color: Colors.red),
              SizedBox(width: 12),
              Text(
                'تحليل المصروفات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'سيتم إضافة تحليل المصروفات في التحديث القادم',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceKPIs() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(Icons.dashboard_outlined, color: Get.theme.primaryColor),
              SizedBox(width: 12),
              Text(
                'مؤشرات الأداء الرئيسية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildKPIItem(
                    'معدل دوران المخزون', '4.2', 'مرة/شهر', Colors.blue),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildKPIItem(
                    'متوسط وقت البيع', '12', 'دقيقة', Colors.green),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child:
                    _buildKPIItem('رضا العملاء', '4.8', 'من 5', Colors.orange),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildKPIItem('نمو المبيعات', '+18', '%', Colors.purple),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKPIItem(String title, String value, String unit, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerAnalyticsCard() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(Icons.people_outlined, color: Colors.blue),
              SizedBox(width: 12),
              Text(
                'تحليل العملاء',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'سيتم إضافة تحليل العملاء قريباً',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductPerformanceCard() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(Icons.trending_up_outlined, color: Colors.green),
              SizedBox(width: 12),
              Text(
                'أداء المنتجات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'سيتم إضافة تحليل أداء المنتجات قريباً',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonalAnalysisCard() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(Icons.calendar_view_week_outlined, color: Colors.purple),
              SizedBox(width: 12),
              Text(
                'التحليل الموسمي',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'سيتم إضافة التحليل الموسمي قريباً',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySalesDetails() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(Icons.list_alt_outlined, color: Get.theme.primaryColor),
              SizedBox(width: 12),
              Text(
                'تفاصيل المبيعات اليومية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Obx(() {
            if (controller.dailySales.isEmpty) {
              return Center(
                child: Text(
                  'لا توجد مبيعات اليوم',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              );
            }
            return Column(
              children: [
                _buildSalesDetailRow('عدد المبيعات',
                    '${controller.dailySales[0]['total_sales'] ?? 0}'),
                _buildSalesDetailRow('إجمالي المبيعات',
                    '${controller.dailySales[0]['total_amount'] ?? 0} جنيه'),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSalesDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Get.theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportActions() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(Icons.download_outlined, color: Get.theme.primaryColor),
              SizedBox(width: 12),
              Text(
                'تصدير التقارير',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildExportButton(
                  'PDF',
                  Icons.picture_as_pdf_outlined,
                  Colors.red,
                  () => controller.exportSalesReport(),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildExportButton(
                  'Excel',
                  Icons.table_chart_outlined,
                  Colors.green,
                  () => controller.exportToExcel(),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildExportButton(
                  'إرسال',
                  Icons.email_outlined,
                  Colors.blue,
                  () => controller.shareReport(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for interactions
  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: Get.context!,
      initialDate: controller.selectedStartDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      controller.selectedStartDate.value = date;
      controller.loadCustomDateRangeReport();
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: Get.context!,
      initialDate: controller.selectedEndDate.value,
      firstDate: controller.selectedStartDate.value,
      lastDate: DateTime.now(),
    );
    if (date != null) {
      controller.selectedEndDate.value = date;
      controller.loadCustomDateRangeReport();
    }
  }

  void _showFullScreenChart() {
    Get.snackbar('معلومة', 'سيتم إضافة عرض الرسوم البيانية بملء الشاشة قريباً');
  }

  void _showAllTopSelling() {
    Get.snackbar('معلومة', 'سيتم إضافة عرض جميع الأدوية الأكثر مبيعاً قريباً');
  }

  void _showLowStockDetails() {
    Get.snackbar('معلومة', 'سيتم إضافة تفاصيل المخزون المنخفض قريباً');
  }

  void _showExpiringDetails() {
    Get.snackbar('معلومة', 'سيتم إضافة تفاصيل الأدوية قريبة الانتهاء قريباً');
  }

  void _showReportSettings() {
    Get.snackbar('معلومة', 'سيتم إضافة إعدادات التقارير قريباً');
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:path/path.dart';
// import '../controllers/reports_controller.dart';

// class ReportsView extends GetView<ReportsController> {
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('التقارير'),
//           bottom: TabBar(
//             tabs: [
//               Tab(text: 'المبيعات'),
//               Tab(text: 'المخزون'),
//               Tab(text: 'تحليلات'),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             _buildSalesReport(),
//             _buildInventoryReport(),
//             _buildAnalytics(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSalesReport() {
//     return Obx(() {
//       if (controller.isLoadingSales.value) {
//         return Center(child: CircularProgressIndicator());
//       }

//       return SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Card(
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'ملخص المبيعات اليومية',
//                       style: Get.textTheme.titleLarge,
//                     ),
//                     SizedBox(height: 16),
//                     Text(
//                       'عدد المبيعات: ${controller.dailySales.isEmpty ? 0 : controller.dailySales[0]['total_sales']}',
//                       style: Get.textTheme.titleMedium,
//                     ),
//                     Text(
//                       'إجمالي المبيعات: ${controller.dailySales.isEmpty ? 0 : controller.dailySales[0]['total_amount']} جنيه',
//                       style: Get.textTheme.titleMedium,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton.icon(
//               icon: Icon(Icons.date_range),
//               label: Text('تحديد نطاق زمني'),
//               onPressed: () => _showDateRangePicker(context as BuildContext),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton.icon(
//               icon: Icon(Icons.picture_as_pdf),
//               label: Text('تصدير التقرير'),
//               onPressed: () => controller.exportSalesReport(),
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildInventoryReport() {
//     return Obx(() {
//       if (controller.isLoadingInventory.value) {
//         return Center(child: CircularProgressIndicator());
//       }

//       return SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Card(
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'الأدوية الأكثر مبيعاً',
//                       style: Get.textTheme.titleLarge,
//                     ),
//                     SizedBox(height: 16),
//                     for (var medicine in controller.topSellingMedicines)
//                       Padding(
//                         padding: EdgeInsets.symmetric(vertical: 4),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(medicine['name']),
//                             Text('${medicine['total_quantity']} قطعة'),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//             Card(
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'تنبيهات المخزون',
//                       style: Get.textTheme.titleLarge,
//                     ),
//                     SizedBox(height: 16),
//                     if (controller.lowStockMedicines.isNotEmpty) ...[
//                       Text('أدوية منخفضة المخزون:'),
//                       for (var medicine in controller.lowStockMedicines)
//                         ListTile(
//                           title: Text(medicine.name),
//                           subtitle: Text('الكمية المتبقية: ${medicine.quantity}'),
//                           leading: Icon(Icons.warning, color: Colors.orange),
//                         ),
//                     ],
//                     if (controller.expiringMedicines.isNotEmpty) ...[
//                       Divider(),
//                       Text('أدوية قريبة من انتهاء الصلاحية:'),
//                       for (var medicine in controller.expiringMedicines)
//                         ListTile(
//                           title: Text(medicine.name),
//                           subtitle: Text(
//                             'تاريخ الانتهاء: ${DateFormat('dd/MM/yyyy').format(medicine.expiryDate)}',
//                           ),
//                           leading: Icon(Icons.event_busy, color: Colors.red),
//                         ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildAnalytics() {
//     return Obx(() {
//       if (controller.isLoadingSales.value) {
//         return Center(child: CircularProgressIndicator());
//       }

//       return SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Card(
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'تحليل المبيعات',
//                       style: Get.textTheme.titleLarge,
//                     ),
//                     SizedBox(height: 16),
//                     // TODO: Add charts and analytics
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   Future<void> _showDateRangePicker(BuildContext context) async {
//     final DateTimeRange? result = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       currentDate: DateTime.now(),
//       saveText: 'اختيار',
//       cancelText: 'إلغاء',
//       confirmText: 'تأكيد',
//       locale: const Locale('ar', 'EG'),
//     );

//     if (result != null) {
//       controller.setDateRange(result.start, result.end);
//     }
//   }
// }
