// lib/app/modules/inventory/views/inventory_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/inventory_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../data/models/medicine.dart';

class InventoryView extends GetView<InventoryController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Stats Overview
          _buildStatsOverview(),

          // Search and Filter Bar
          _buildSearchAndFilterBar(),

          // Medicines List
          Expanded(
            child: Obx(() {
              if (controller.medicines.isEmpty) {
                return _buildEmptyState();
              }
              return _buildMedicinesList();
            }),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'إدارة المخزون',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Get.theme.primaryColor,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list_outlined),
          onPressed: () => _showFilterDialog(),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'export_pdf':
                controller.generateInventoryReport();
                break;
              case 'low_stock':
                _showLowStockDialog();
                break;
              case 'expiring':
                _showExpiringMedicinesDialog();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'export_pdf',
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf_outlined, color: Colors.red),
                  SizedBox(width: 8),
                  Text('تصدير PDF'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'low_stock',
              child: Row(
                children: [
                  Icon(Icons.warning_outlined, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('مخزون منخفض'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'expiring',
              child: Row(
                children: [
                  Icon(Icons.schedule_outlined, color: Colors.red),
                  SizedBox(width: 8),
                  Text('قريب الانتهاء'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsOverview() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Obx(() {
        final totalMedicines = controller.medicines.length;
        final totalQuantity = controller.medicines
            .fold<int>(0, (sum, medicine) => sum + medicine.quantity);
        final lowStockCount = controller.medicines
            .where((medicine) => medicine.quantity <= 10)
            .length;
        final expiringCount = controller.medicines
            .where((medicine) =>
                medicine.expiryDate.difference(DateTime.now()).inDays <= 30)
            .length;

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'إجمالي الأصناف',
                value: totalMedicines.toString(),
                icon: Icons.medication_outlined,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'إجمالي الكمية',
                value: totalQuantity.toString(),
                icon: Icons.inventory_2_outlined,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'مخزون منخفض',
                value: lowStockCount.toString(),
                icon: Icons.warning_outlined,
                color: Colors.orange,
                onTap: () => _showLowStockDialog(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'قريب الانتهاء',
                value: expiringCount.toString(),
                icon: Icons.schedule_outlined,
                color: Colors.red,
                onTap: () => _showExpiringMedicinesDialog(),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'البحث عن دواء...',
                prefixIcon:
                    Icon(Icons.search_outlined, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) => controller.searchMedicines(value),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Get.theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.tune_outlined, color: Get.theme.primaryColor),
              onPressed: () => _showFilterDialog(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicinesList() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.medicines.length,
        itemBuilder: (context, index) {
          final medicine = controller.medicines[index];
          return _buildMedicineCard(medicine, index);
        },
      ),
    );
  }

  Widget _buildMedicineCard(Medicine medicine, int index) {
    final daysUntilExpiry =
        medicine.expiryDate.difference(DateTime.now()).inDays;
    final isLowStock = medicine.quantity <= 10;
    final isExpiringSoon = daysUntilExpiry <= 30;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Medicine Image
                _buildMedicineImage(medicine),
                const SizedBox(width: 16),

                // Medicine Info
                Expanded(
                  child: _buildMedicineInfo(medicine, daysUntilExpiry),
                ),

                // Action Buttons
                _buildActionButtons(medicine),
              ],
            ),
          ),

          // Warning Badges
          if (isLowStock || isExpiringSoon)
            _buildWarningBadges(isLowStock, isExpiringSoon, daysUntilExpiry),
        ],
      ),
    );
  }

  Widget _buildMedicineImage(Medicine medicine) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: medicine.image.isNotEmpty
            ? Image.file(
                File(medicine.image),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholderImage(),
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[200]!, Colors.grey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.medication_outlined,
        size: 40,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildMedicineInfo(Medicine medicine, int daysUntilExpiry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          medicine.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          icon: Icons.inventory_2_outlined,
          label: 'الكمية',
          value: '${medicine.quantity}',
          valueColor: medicine.quantity <= 10 ? Colors.red : Colors.green,
        ),
        const SizedBox(height: 4),
        _buildInfoRow(
          icon: Icons.attach_money_outlined,
          label: 'السعر',
          value: '${medicine.sellingPrice.toStringAsFixed(2)} جنيه',
        ),
        const SizedBox(height: 4),
        _buildInfoRow(
          icon: Icons.calendar_today_outlined,
          label: 'الانتهاء',
          value: DateFormat('dd/MM/yyyy').format(medicine.expiryDate),
          valueColor: _getExpiryColor(daysUntilExpiry),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Medicine medicine) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Get.theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.edit_outlined, color: Get.theme.primaryColor),
            onPressed: () => Get.toNamed(
              Routes.EDIT_MEDICINE,
              arguments: medicine,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(medicine),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningBadges(
      bool isLowStock, bool isExpiringSoon, int daysUntilExpiry) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          if (isLowStock) ...[
            _buildWarningBadge(
              icon: Icons.warning_outlined,
              text: 'مخزون منخفض',
              color: Colors.orange,
            ),
          ],
          if (isLowStock && isExpiringSoon) const SizedBox(width: 8),
          if (isExpiringSoon) ...[
            _buildWarningBadge(
              icon: Icons.schedule_outlined,
              text: daysUntilExpiry <= 0
                  ? 'منتهي الصلاحية'
                  : 'ينتهي خلال $daysUntilExpiry يوم',
              color: daysUntilExpiry <= 0 ? Colors.red : Colors.orange,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWarningBadge({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا يوجد أدوية في المخزون',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على زر الإضافة لبدء إضافة الأدوية',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed(Routes.ADD_MEDICINE),
            icon: const Icon(Icons.add),
            label: const Text('إضافة دواء جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Get.theme.primaryColor,
            Get.theme.primaryColor.withOpacity(0.8)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Get.theme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.ADD_MEDICINE),
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'إضافة دواء',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getExpiryColor(int daysUntilExpiry) {
    if (daysUntilExpiry <= 0) return Colors.red;
    if (daysUntilExpiry <= 30) return Colors.orange;
    if (daysUntilExpiry <= 90) return Colors.yellow[700]!;
    return Colors.green;
  }

  void _showDeleteConfirmation(Medicine medicine) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.warning_outlined,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'تأكيد الحذف',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'هل أنت متأكد من حذف "${medicine.name}"؟',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      child: const Text('إلغاء'),
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      child: const Text('حذف'),
                      onPressed: () {
                        Get.back();
                        controller.deleteMedicine(medicine);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
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

  void _showFilterDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.filter_list_outlined,
                      color: Get.theme.primaryColor),
                  const SizedBox(width: 12),
                  const Text(
                    'تصفية النتائج',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildFilterOption(
                title: 'مخزون منخفض',
                subtitle: 'إظهار الأدوية بكمية أقل من 10',
                icon: Icons.warning_outlined,
                color: Colors.orange,
                onTap: () {
                  Get.back();
                  _showLowStockDialog();
                },
              ),
              const SizedBox(height: 12),
              _buildFilterOption(
                title: 'قريب الانتهاء',
                subtitle: 'إظهار الأدوية التي تنتهي خلال 30 يوم',
                icon: Icons.schedule_outlined,
                color: Colors.red,
                onTap: () {
                  Get.back();
                  _showExpiringMedicinesDialog();
                },
              ),
              const SizedBox(height: 12),
              _buildFilterOption(
                title: 'جميع الأدوية',
                subtitle: 'عرض جميع الأدوية في المخزون',
                icon: Icons.list_outlined,
                color: Colors.blue,
                onTap: () {
                  Get.back();
                  controller.loadMedicines();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption({
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
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

  void _showLowStockDialog() {
    final lowStockMedicines = controller.medicines
        .where((medicine) => medicine.quantity <= 10)
        .toList();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          height: Get.height * 0.6,
          child: Column(
            children: [
              const Row(
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
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: lowStockMedicines.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد أدوية بمخزون منخفض',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: lowStockMedicines.length,
                        itemBuilder: (context, index) {
                          final medicine = lowStockMedicines[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange.withOpacity(0.1),
                              child: const Icon(Icons.medication_outlined,
                                  color: Colors.orange),
                            ),
                            title: Text(medicine.name),
                            subtitle:
                                Text('الكمية المتبقية: ${medicine.quantity}'),
                            trailing: Text(
                              '${medicine.quantity}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExpiringMedicinesDialog() {
    final expiringMedicines = controller.medicines
        .where((medicine) =>
            medicine.expiryDate.difference(DateTime.now()).inDays <= 30)
        .toList();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          height: Get.height * 0.6,
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.schedule_outlined, color: Colors.red),
                  SizedBox(width: 12),
                  Text(
                    'أدوية قريبة الانتهاء',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: expiringMedicines.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد أدوية قريبة الانتهاء',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: expiringMedicines.length,
                        itemBuilder: (context, index) {
                          final medicine = expiringMedicines[index];
                          final daysUntilExpiry = medicine.expiryDate
                              .difference(DateTime.now())
                              .inDays;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red.withOpacity(0.1),
                              child: const Icon(Icons.schedule_outlined,
                                  color: Colors.red),
                            ),
                            title: Text(medicine.name),
                            subtitle: Text(
                              'تاريخ الانتهاء: ${DateFormat('dd/MM/yyyy').format(medicine.expiryDate)}',
                            ),
                            trailing: Text(
                              daysUntilExpiry <= 0
                                  ? 'منتهي'
                                  : '$daysUntilExpiry يوم',
                              style: TextStyle(
                                color: daysUntilExpiry <= 0
                                    ? Colors.red
                                    : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// // lib/app/modules/inventory/views/inventory_view.dart
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import '../controllers/inventory_controller.dart';
// import '../../../routes/app_pages.dart';

// class InventoryView extends GetView<InventoryController> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('المخزون'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.picture_as_pdf),
//             onPressed: () => controller.generateInventoryReport(),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.all(8),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'بحث عن دواء...',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (value) => controller.searchMedicines(value),
//             ),
//           ),
//           Expanded(
//             child: Obx(() {
//               if (controller.medicines.isEmpty) {
//                 return Center(child: Text('لا يوجد أدوية في المخزون'));
//               }

//               return ListView.builder(
//                 itemCount: controller.medicines.length,
//                 itemBuilder: (context, index) {
//                   final medicine = controller.medicines[index];
//                   final daysUntilExpiry = medicine.expiryDate
//                       .difference(DateTime.now()).inDays;

//                   return Card(
//                     margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     child: ListTile(
//                       leading: CircleAvatar(
//                         backgroundImage: FileImage(File(medicine.image)),
//                       ),
//                       title: Text(medicine.name),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('الكمية: ${medicine.quantity}'),
//                           Text('السعر: ${medicine.price} جنيه'),
//                           Text(
//                             'تاريخ الانتهاء: ${DateFormat('dd/MM/yyyy').format(medicine.expiryDate)}',
//                             style: TextStyle(
//                               color: daysUntilExpiry <= 30 ? Colors.red : null,
//                             ),
//                           ),
//                         ],
//                       ),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           IconButton(
//                             icon: Icon(Icons.edit),
//                             onPressed: () => Get.toNamed(
//                               Routes.EDIT_MEDICINE,
//                               arguments: medicine,
//                             ),
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.delete),
//                             color: Colors.red,
//                             onPressed: () => controller.deleteMedicine(medicine),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             }),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.add),
//         onPressed: () => Get.toNamed(Routes.ADD_MEDICINE),
//       ),
//     );
//   }
// }
