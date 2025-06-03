// lib/app/modules/sales/views/sell_medicine_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sales_controller.dart';

class SellMedicineView extends GetView<SalesController> {
  final TextEditingController _customerSearchController =
      TextEditingController();
  final TextEditingController _medicineSearchController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search and Customer Section
          _buildSearchSection(),

          // Cart Summary
          _buildCartSummary(),

          // Medicine List
          Expanded(
            child: _buildMedicinesList(),
          ),

          // Bottom Action Bar
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'نقطة البيع',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Get.theme.primaryColor,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: Icon(Icons.history_outlined),
          onPressed: () => _showSalesHistory(),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'clear_cart':
                _showClearCartConfirmation();
                break;
              case 'calculator':
                _showCalculator();
                break;
              case 'settings':
                _showSalesSettings();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'clear_cart',
              child: Row(
                children: [
                  Icon(Icons.clear_all_outlined, color: Colors.red),
                  SizedBox(width: 8),
                  Text('مسح السلة'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'calculator',
              child: Row(
                children: [
                  Icon(Icons.calculate_outlined, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('الآلة الحاسبة'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('إعدادات البيع'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          // Customer Search
          _buildSearchField(
            controller: _customerSearchController,
            hintText: 'البحث عن عميل أو إضافة عميل جديد...',
            prefixIcon: Icons.person_search_outlined,
            suffixIcon: Icons.person_add_outlined,
            onChanged: (query) => controller.searchCustomers(query),
            onSuffixPressed: () => controller.addNewCustomer(''),
          ),
          SizedBox(height: 12),

          // Medicine Search
          Row(
            children: [
              Expanded(
                child: _buildSearchField(
                  controller: _medicineSearchController,
                  hintText: 'البحث عن دواء بالاسم أو الباركود...',
                  prefixIcon: Icons.search_outlined,
                  onChanged: (query) => controller.searchMedicines(query),
                ),
              ),
              SizedBox(width: 12),
              Container(
                height: 56,
                width: 56,
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
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.qr_code_scanner, color: Colors.white),
                  onPressed: () => _showBarcodeScanner(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    IconData? suffixIcon,
    required Function(String) onChanged,
    VoidCallback? onSuffixPressed,
  }) {
    return Container(
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
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(prefixIcon, color: Colors.grey[400]),
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(suffixIcon, color: Get.theme.primaryColor),
                  onPressed: onSuffixPressed,
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCartSummary() {
    return Obx(() {
      if (controller.cartItems.isEmpty) return SizedBox.shrink();

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.blue[100]!],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.shopping_cart_outlined, color: Colors.white),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'السلة (${controller.cartItems.length} صنف)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'الإجمالي: ${controller.total.value.toStringAsFixed(2)} جنيه',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.expand_more, color: Colors.blue[800]),
              onPressed: () => _showCartDetails(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMedicinesList() {
    return Obx(() {
      if (controller.selectedMedicines.isEmpty) {
        return _buildEmptyCart();
      }

      return Container(
        margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: ListView.builder(
          itemCount: controller.selectedMedicines.length,
          itemBuilder: (context, index) {
            final medicine = controller.selectedMedicines[index];
            final item = controller.cartItems[index];
            return _buildMedicineCard(medicine, item, index);
          },
        ),
      );
    });
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'السلة فارغة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'ابحث عن الأدوية وأضفها للسلة لبدء عملية البيع',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuickActionButton(
                icon: Icons.qr_code_scanner,
                label: 'مسح باركود',
                color: Colors.blue,
                onPressed: () => _showBarcodeScanner(),
              ),
              SizedBox(width: 16),
              _buildQuickActionButton(
                icon: Icons.search,
                label: 'بحث عن دواء',
                color: Colors.green,
                onPressed: () => _focusOnMedicineSearch(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildMedicineCard(medicine, item, int index) {
    final isLowStock = medicine.quantity <= 10;
    final stockPercentage = (item.quantity / medicine.quantity).clamp(0.0, 1.0);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main card content
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Medicine Image
                _buildMedicineImage(medicine),
                SizedBox(width: 16),

                // Medicine Info
                Expanded(
                  child: _buildMedicineInfo(medicine, item, isLowStock),
                ),

                // Quantity Controls
                _buildQuantityControls(medicine, item, index),
              ],
            ),
          ),

          // Stock indicator and actions
          _buildCardFooter(medicine, item, index, stockPercentage, isLowStock),
        ],
      ),
    );
  }

  Widget _buildMedicineImage(medicine) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
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

  Widget _buildMedicineInfo(medicine, item, bool isLowStock) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          medicine.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8),

        // Price row
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'سعر البيع: ${medicine.sellingPrice.toStringAsFixed(2)} جنيه',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4),

        // Stock info
        Row(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 14,
              color: isLowStock ? Colors.red : Colors.grey[600],
            ),
            SizedBox(width: 4),
            Text(
              'متوفر: ${medicine.quantity}',
              style: TextStyle(
                fontSize: 12,
                color: isLowStock ? Colors.red : Colors.grey[600],
                fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isLowStock) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'مخزون منخفض',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 8),

        // Total for this item
        Text(
          'الإجمالي: ${(item.quantity * item.price).toStringAsFixed(2)} جنيه',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Get.theme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityControls(medicine, item, int index) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Decrease button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.quantity > 1
                  ? Colors.red.withOpacity(0.1)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.remove,
                color: item.quantity > 1 ? Colors.red : Colors.grey[400],
                size: 20,
              ),
              onPressed: item.quantity > 1
                  ? () =>
                      controller.updateItemQuantity(index, item.quantity - 1)
                  : null,
            ),
          ),

          SizedBox(height: 8),

          // Quantity display
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Get.theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${item.quantity}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Get.theme.primaryColor,
              ),
            ),
          ),

          SizedBox(height: 8),

          // Increase button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.quantity < medicine.quantity
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.add,
                color: item.quantity < medicine.quantity
                    ? Colors.green
                    : Colors.grey[400],
                size: 20,
              ),
              onPressed: item.quantity < medicine.quantity
                  ? () =>
                      controller.updateItemQuantity(index, item.quantity + 1)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFooter(
      medicine, item, int index, double stockPercentage, bool isLowStock) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // Stock indicator
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'استهلاك المخزون: ',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '${(stockPercentage * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            stockPercentage > 0.7 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                LinearProgressIndicator(
                  value: stockPercentage,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    stockPercentage > 0.7 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 16),

          // Remove button
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showRemoveItemConfirmation(medicine, index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Customer info
          Obx(() {
            if (controller.selectedCustomer.value != null) {
              return Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person_outlined, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'العميل المحدد',
                            style: TextStyle(
                                fontSize: 12, color: Colors.green[700]),
                          ),
                          Text(
                            controller.selectedCustomer.value!.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit_outlined, color: Colors.green),
                      onPressed: () => _customerSearchController.clear(),
                    ),
                  ],
                ),
              );
            }
            return SizedBox.shrink();
          }),

          // Total and actions
          Obx(() => Row(
                children: [
                  // Total display
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
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
                          Text(
                            'الإجمالي',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                            ),
                          ),
                          Text(
                            '${controller.total.value.toStringAsFixed(2)} جنيه',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 16),

                  // Action buttons
                  Column(
                    children: [
                      // Complete sale button
                      Container(
                        width: 120,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: controller.cartItems.isNotEmpty
                                ? [Colors.green, Colors.green.withOpacity(0.8)]
                                : [Colors.grey[300]!, Colors.grey[400]!],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: controller.cartItems.isNotEmpty
                              ? [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: Offset(0, 6),
                                  ),
                                ]
                              : null,
                        ),
                        child: ElevatedButton.icon(
                          onPressed: controller.cartItems.isNotEmpty
                              ? () => _showCompleteSaleDialog()
                              : null,
                          icon: Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                          ),
                          label: Text(
                            'إتمام البيع',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )),
        ],
      ),
    );
  }

  // Helper methods
  void _showBarcodeScanner() {
    Get.snackbar(
      'معلومة',
      'ميزة مسح الباركود قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _focusOnMedicineSearch() {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
    _medicineSearchController.clear();
  }

  void _showCartDetails() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تفاصيل السلة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            // Cart items summary would go here
            Text('${controller.cartItems.length} صنف في السلة'),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('إغلاق'),
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveItemConfirmation(medicine, int index) {
    Get.dialog(
      AlertDialog(
        title: Text('إزالة من السلة'),
        content: Text('هل تريد إزالة "${medicine.name}" من السلة؟'),
        actions: [
          TextButton(
            child: Text('إلغاء'),
            onPressed: () => Get.back(),
          ),
          ElevatedButton(
            child: Text('إزالة'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              controller.removeMedicineFromCart(index);
            },
          ),
        ],
      ),
    );
  }

  void _showCompleteSaleDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 60,
                color: Colors.green,
              ),
              SizedBox(height: 16),
              Text(
                'إتمام عملية البيع',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'الإجمالي: ${controller.total.value.toStringAsFixed(2)} جنيه',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      child: Text('إلغاء'),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      child: Text('تأكيد البيع'),
                      onPressed: () {
                        Get.back();
                        controller.completeSale();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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

  void _showSalesHistory() {
    Get.snackbar('معلومة', 'سجل المبيعات قيد التطوير');
  }

  void _showClearCartConfirmation() {
    if (controller.cartItems.isEmpty) return;

    Get.dialog(
      AlertDialog(
        title: Text('مسح السلة'),
        content: Text('هل تريد مسح جميع العناصر من السلة؟'),
        actions: [
          TextButton(
            child: Text('إلغاء'),
            onPressed: () => Get.back(),
          ),
          ElevatedButton(
            child: Text('مسح'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              // Clear cart logic would go here
            },
          ),
        ],
      ),
    );
  }

  void _showCalculator() {
    Get.snackbar('معلومة', 'الآلة الحاسبة قيد التطوير');
  }

  void _showSalesSettings() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings_outlined, color: Get.theme.primaryColor),
                SizedBox(width: 12),
                Text(
                  'إعدادات البيع',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            _buildSettingsOption(
              icon: Icons.receipt_outlined,
              title: 'طباعة الفاتورة تلقائياً',
              subtitle: 'طباعة الفاتورة فور إتمام البيع',
              trailing: Switch(
                value: true, // This would be connected to a controller
                onChanged: (value) {},
              ),
            ),
            _buildSettingsOption(
              icon: Icons.notifications_outlined,
              title: 'تنبيهات المخزون',
              subtitle: 'تنبيه عند انخفاض المخزون أثناء البيع',
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
            _buildSettingsOption(
              icon: Icons.percent_outlined,
              title: 'إظهار نسبة الربح',
              subtitle: 'عرض نسبة الربح لكل دواء',
              trailing: Switch(
                value: false,
                onChanged: (value) {},
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: Text('إغلاق'),
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Get.theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
              color: Get.theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Get.theme.primaryColor, size: 20),
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
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 2),
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
          trailing,
        ],
      ),
    );
  }

  // Quick access methods for keyboard shortcuts
  void _handleKeyboardShortcuts() {
    // This could be implemented for desktop/web versions
    // F1 - Search medicine
    // F2 - Search customer
    // F3 - Barcode scanner
    // F4 - Complete sale
    // ESC - Clear current action
  }

  // Method to calculate change if cash payment
  Widget _buildPaymentDialog() {
    final TextEditingController cashController = TextEditingController();
    final RxDouble cashReceived = 0.0.obs;
    final RxDouble change = 0.0.obs;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تفاصيل الدفع',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),

            // Total amount
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'إجمالي المبلغ:',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '${controller.total.value.toStringAsFixed(2)} جنيه',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Cash received input
            TextField(
              controller: cashController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'المبلغ المستلم',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.attach_money),
              ),
              onChanged: (value) {
                cashReceived.value = double.tryParse(value) ?? 0.0;
                change.value = cashReceived.value - controller.total.value;
              },
            ),

            SizedBox(height: 16),

            // Change calculation
            Obx(() => Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: change.value >= 0
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الباقي:',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '${change.value.toStringAsFixed(2)} جنيه',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: change.value >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                )),

            SizedBox(height: 24),

            // Payment method buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.credit_card_outlined),
                    label: Text('كارت'),
                    onPressed: () {
                      Get.back();
                      controller.completeSale();
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Obx(() => ElevatedButton.icon(
                        icon: Icon(Icons.payments_outlined),
                        label: Text('نقداً'),
                        onPressed: change.value >= 0
                            ? () {
                                Get.back();
                                controller.completeSale();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Method to show detailed invoice preview before printing
  void _showInvoicePreview() {
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.8,
          height: Get.height * 0.8,
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'معاينة الفاتورة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildInvoiceContent(),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.edit_outlined),
                      label: Text('تعديل'),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.print_outlined),
                      label: Text('طباعة'),
                      onPressed: () {
                        Get.back();
                        controller.printInvoice();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.primaryColor,
                        foregroundColor: Colors.white,
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

  Widget _buildInvoiceContent() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Column(
              children: [
                Text(
                  'الصيدلية البيطرية',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'فاتورة بيع',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Customer and date info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  'العميل: ${controller.selectedCustomer.value?.name ?? "غير محدد"}'),
              Text('التاريخ: ${DateTime.now().toString().split(' ')[0]}'),
            ],
          ),

          SizedBox(height: 20),

          // Items table
          Table(
            border: TableBorder.all(color: Colors.grey[300]!),
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[200]),
                children: [
                  _buildTableCell('الصنف', isHeader: true),
                  _buildTableCell('الكمية', isHeader: true),
                  _buildTableCell('السعر', isHeader: true),
                  _buildTableCell('الإجمالي', isHeader: true),
                ],
              ),
              for (int i = 0; i < controller.selectedMedicines.length; i++)
                TableRow(
                  children: [
                    _buildTableCell(controller.selectedMedicines[i].name),
                    _buildTableCell('${controller.cartItems[i].quantity}'),
                    _buildTableCell(
                        '${controller.cartItems[i].price.toStringAsFixed(2)}'),
                    _buildTableCell(
                        '${(controller.cartItems[i].quantity * controller.cartItems[i].price).toStringAsFixed(2)}'),
                  ],
                ),
            ],
          ),

          SizedBox(height: 20),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${controller.total.value.toStringAsFixed(2)} جنيه',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Get.theme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// // lib/app/modules/sales/views/sell_medicine_view.dart
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/sales_controller.dart';

// class SellMedicineView extends GetView<SalesController> {
//   final TextEditingController _customerSearchController =
//       TextEditingController();
//   final TextEditingController _medicineSearchController =
//       TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('بيع دواء')),
//       body: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 TextField(
//                   controller: _customerSearchController,
//                   decoration: InputDecoration(
//                     labelText: 'بحث/إضافة عميل',
//                     prefixIcon: Icon(Icons.person_search),
//                     border: OutlineInputBorder(),
//                   ),
//                   onChanged: (query) => controller.searchCustomers(query),
//                 ),
//                 SizedBox(height: 8),
//                 TextField(
//                   controller: _medicineSearchController,
//                   decoration: InputDecoration(
//                     labelText: 'بحث عن دواء',
//                     prefixIcon: Icon(Icons.search),
//                     border: OutlineInputBorder(),
//                   ),
//                   onChanged: (query) => controller.searchMedicines(query),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: Obx(() => ListView.builder(
//                   itemCount: controller.selectedMedicines.length,
//                   itemBuilder: (context, index) {
//                     final medicine = controller.selectedMedicines[index];
//                     final item = controller.cartItems[index];
//                     return Card(
//                       margin: EdgeInsets.all(8),
//                       child: ListTile(
//                         leading: Image.file(File(medicine.image)),
//                         title: Text(medicine.name),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('سعر البيع: ${medicine.sellingPrice} جنيه'),
//                             Text('سعر الشراء: ${medicine.purchasePrice} جنيه'),
//                             Text('سعر السوق: ${medicine.marketPrice} جنيه'),
//                           ],
//                         ),
//                         trailing: Container(
//                           width: 120,
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: Icon(Icons.remove),
//                                 onPressed: item.quantity > 1
//                                     ? () => controller.updateItemQuantity(
//                                         index, item.quantity - 1)
//                                     : null,
//                               ),
//                               Obx(() => Text(
//                                     '${controller.cartItems[index].quantity}',
//                                     style: TextStyle(fontSize: 16),
//                                   )),
//                               IconButton(
//                                 icon: Icon(Icons.add),
//                                 onPressed: item.quantity < medicine.quantity
//                                     ? () => controller.updateItemQuantity(
//                                         index, item.quantity + 1)
//                                     : null,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 )),
//           ),
//           Container(
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black12,
//                   blurRadius: 4,
//                   offset: Offset(0, -2),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 Obx(() {
//                   if (controller.selectedCustomer.value != null) {
//                     return Padding(
//                       padding: EdgeInsets.only(bottom: 8),
//                       child: Text(
//                         'العميل: ${controller.selectedCustomer.value!.name}',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     );
//                   }
//                   return SizedBox.shrink();
//                 }),
//                 Obx(() => Text(
//                       'الإجمالي: ${controller.total.value} جنيه',
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     )),
//                 SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         icon: Icon(Icons.camera_alt),
//                         label: Text('مسح باركود'),
//                         onPressed: () {
//                           // TODO: Implement barcode scanning
//                         },
//                       ),
//                     ),
//                     SizedBox(width: 16),
//                     Expanded(
//                       child: Obx(() => ElevatedButton.icon(
//                             icon: Icon(Icons.check),
//                             label: Text('إتمام البيع'),
//                             onPressed: controller.cartItems.isNotEmpty
//                                 ? () => controller.completeSale()
//                                 : null,
//                           )),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
