// lib/app/modules/sales/controllers/sales_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../data/models/medicine.dart';
import '../../../data/models/sale.dart';
import '../../../data/models/customer.dart';
import '../../../data/services/database_service.dart';

class SalesController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  // Cart and selection observables
  final cartItems = <SaleItem>[].obs;
  final selectedMedicines = <Medicine>[].obs;
  final selectedCustomer = Rxn<Customer>();

  // Financial observables
  final total = 0.0.obs;
  final subtotal = 0.0.obs;
  final tax = 0.0.obs;
  final discount = 0.0.obs;
  final totalProfit = 0.0.obs;

  // UI state observables
  final isLoading = false.obs;
  final isProcessingSale = false.obs;
  final searchResults = <Medicine>[].obs;
  final customerSearchResults = <Customer>[].obs;
  final showSearchResults = false.obs;

  // Settings observables
  final autoSelectFirstResult = true.obs;
  final showProfitMargin = false.obs;
  final autoPrintInvoice = true.obs;
  final enableLowStockWarning = true.obs;
  final taxRate = 0.0.obs; // 14% for Egypt, configurable

  // Quick access lists
  final recentCustomers = <Customer>[].obs;
  final frequentMedicines = <Medicine>[].obs;
  final salesHistory = <Sale>[].obs;

  @override
  void onInit() {
    super.onInit();
    _setupCalculationListeners();
    _loadInitialData();
  }

  void _setupCalculationListeners() {
    ever(cartItems, (_) => _calculateTotals());
    ever(discount, (_) => _calculateTotals());
    ever(taxRate, (_) => _calculateTotals());
  }

  Future<void> _loadInitialData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        _loadRecentCustomers(),
        _loadFrequentMedicines(),
        _loadSettings(),
      ]);
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadRecentCustomers() async {
    // Load recent customers from database
    final customers = await _databaseService.getAllCustomers();
    recentCustomers.value = customers.take(5).toList();
  }

  Future<void> _loadFrequentMedicines() async {
    // Load frequently sold medicines
    final medicines = await _databaseService.getAllMedicines();
    frequentMedicines.value = medicines.take(10).toList();
  }

  Future<void> _loadSettings() async {
    // Load user preferences (would be stored in shared preferences)
    // For now, using default values
  }

  void _calculateTotals() {
    subtotal.value =
        cartItems.fold(0.0, (sum, item) => sum + (item.quantity * item.price));
    tax.value = subtotal.value * (taxRate.value / 100);
    total.value = subtotal.value + tax.value - discount.value;

    // Calculate total profit
    totalProfit.value = cartItems.fold(0.0, (sum, item) {
      final medicine =
          selectedMedicines.firstWhere((m) => m.id == item.medicineId);
      final profit = (item.price - medicine.purchasePrice) * item.quantity;
      return sum + profit;
    });
  }

  // Enhanced search with smart UI
  Future<void> searchMedicines(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      showSearchResults.value = false;
      return;
    }

    try {
      isLoading.value = true;
      final medicines = await _databaseService.searchMedicines(query);
      searchResults.value = medicines;
      showSearchResults.value = medicines.isNotEmpty;

      if (medicines.isNotEmpty) {
        if (autoSelectFirstResult.value && medicines.length == 1) {
          // Auto-select if only one result
          addMedicineToCart(medicines.first);
          _clearSearch();
        } else {
          _showMedicineSearchResults(medicines);
        }
      } else {
        Get.snackbar(
          'البحث',
          'لم يتم العثور على أي دواء بهذا الاسم',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء البحث: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showMedicineSearchResults(List<Medicine> medicines) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: Get.width * 0.9,
          height: Get.height * 0.7,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.search, color: Get.theme.primaryColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'نتائج البحث (${medicines.length})',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(),

              // Results list
              Expanded(
                child: ListView.builder(
                  itemCount: medicines.length,
                  itemBuilder: (context, index) {
                    final medicine = medicines[index];
                    return _buildMedicineSearchItem(medicine);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineSearchItem(Medicine medicine) {
    final isLowStock = medicine.quantity <= 10;
    final profitMargin = medicine.sellingPrice > 0
        ? ((medicine.sellingPrice - medicine.purchasePrice) /
            medicine.sellingPrice *
            100)
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Get.back();
          addMedicineToCart(medicine);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      medicine.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isLowStock)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'مخزون منخفض',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPriceInfo(
                      'سعر البيع', medicine.sellingPrice, Colors.green),
                  const SizedBox(width: 16),
                  _buildPriceInfo(
                      'سعر الشراء', medicine.purchasePrice, Colors.blue),
                  const SizedBox(width: 16),
                  _buildPriceInfo(
                      'سعر السوق', medicine.marketPrice, Colors.orange),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'متوفر: ${medicine.quantity}',
                    style: TextStyle(
                      color: isLowStock ? Colors.red : Colors.grey[600],
                      fontWeight:
                          isLowStock ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  if (showProfitMargin.value) ...[
                    const Icon(Icons.trending_up,
                        size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'ربح: ${profitMargin.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceInfo(String label, double price, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
        Text(
          '${price.toStringAsFixed(2)} جنيه',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void addMedicineToCart(Medicine medicine) {
    if (medicine.quantity <= 0) {
      Get.snackbar(
        'تنبيه',
        'هذا الدواء غير متوفر في المخزون',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    final existingIndex =
        selectedMedicines.indexWhere((m) => m.id == medicine.id);

    if (existingIndex != -1) {
      final currentQuantity = cartItems[existingIndex].quantity;
      if (currentQuantity < medicine.quantity) {
        updateItemQuantity(existingIndex, currentQuantity + 1);
        _showAddToCartFeedback(medicine.name, currentQuantity + 1);
      } else {
        Get.snackbar(
          'تنبيه',
          'لا يمكن إضافة المزيد من ${medicine.name}. الكمية المتاحة: ${medicine.quantity}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } else {
      selectedMedicines.add(medicine);
      cartItems.add(SaleItem(
        medicineId: medicine.id!,
        quantity: 1,
        price: medicine.sellingPrice,
      ));

      _showAddToCartFeedback(medicine.name, 1);

      // Check for low stock warning
      if (enableLowStockWarning.value && medicine.quantity <= 10) {
        _showLowStockWarning(medicine);
      }
    }

    _clearSearch();
  }

  void _showAddToCartFeedback(String medicineName, int quantity) {
    Get.snackbar(
      'تمت الإضافة',
      'تم إضافة $quantity من $medicineName للسلة',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
      margin: const EdgeInsets.all(16),
    );
  }

  void _showLowStockWarning(Medicine medicine) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_outlined, color: Colors.orange),
            SizedBox(width: 8),
            Text('تنبيه مخزون'),
          ],
        ),
        content: Text(
          'دواء "${medicine.name}" بمخزون منخفض (${medicine.quantity} قطعة متبقية). يُنصح بإعادة التموين قريباً.',
        ),
        actions: [
          TextButton(
            child: const Text('حسناً'),
            onPressed: () => Get.back(),
          ),
          ElevatedButton(
            child: const Text('إضافة للطلبات'),
            onPressed: () {
              Get.back();
              // Add to reorder list logic
            },
          ),
        ],
      ),
    );
  }

  void _clearSearch() {
    searchResults.clear();
    showSearchResults.value = false;
  }

  void removeMedicineFromCart(int index) {
    final medicine = selectedMedicines[index];

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('إزالة من السلة'),
        content: Text('هل تريد إزالة "${medicine.name}" من السلة؟'),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Get.back(),
          ),
          ElevatedButton(
            child: const Text('إزالة'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              selectedMedicines.removeAt(index);
              cartItems.removeAt(index);

              Get.snackbar(
                'تم الحذف',
                'تم إزالة ${medicine.name} من السلة',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.withOpacity(0.8),
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
          ),
        ],
      ),
    );
  }

  void updateItemQuantity(int index, int newQuantity) {
    final medicine = selectedMedicines[index];

    if (newQuantity <= 0) {
      removeMedicineFromCart(index);
      return;
    }

    if (newQuantity > medicine.quantity) {
      Get.snackbar(
        'تنبيه',
        'الكمية المطلوبة (${newQuantity}) غير متوفرة في المخزون. المتاح: ${medicine.quantity}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    cartItems[index] = SaleItem(
      medicineId: cartItems[index].medicineId,
      quantity: newQuantity,
      price: cartItems[index].price,
    );

    cartItems.refresh();
  }

  // Enhanced customer search
  Future<void> searchCustomers(String query) async {
    if (query.isEmpty) {
      customerSearchResults.clear();
      return;
    }

    try {
      final customers = await _databaseService.searchCustomers(query);
      customerSearchResults.value = customers;

      if (customers.isNotEmpty) {
        _showCustomerSearchResults(customers, query);
      } else {
        _showAddNewCustomerOption(query);
      }
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء البحث عن العملاء: $e');
    }
  }

  void _showCustomerSearchResults(List<Customer> customers, String query) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: Get.width * 0.9,
          height: Get.height * 0.6,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.people_outlined, color: Get.theme.primaryColor),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'اختيار العميل',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(),

              // Add new customer option
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person_add_outlined),
                  label: const Text('إضافة عميل جديد'),
                  onPressed: () {
                    Get.back();
                    addNewCustomer(query);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: Get.theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // Customers list
              Expanded(
                child: ListView.builder(
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return _buildCustomerItem(customer);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerItem(Customer customer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
          child: Icon(Icons.person_outlined, color: Get.theme.primaryColor),
        ),
        title: Text(
          customer.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (customer.phone?.isNotEmpty == true)
              Text('📞 ${customer.phone}'),
            if (customer.address?.isNotEmpty == true)
              Text('📍 ${customer.address}'),
          ],
        ),
        onTap: () {
          selectedCustomer.value = customer;
          Get.back();

          Get.snackbar(
            'تم اختيار العميل',
            'تم اختيار ${customer.name}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        },
      ),
    );
  }

  void _showAddNewCustomerOption(String query) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.person_add_outlined, color: Get.theme.primaryColor),
            const SizedBox(width: 8),
            const Text('عميل جديد'),
          ],
        ),
        content: const Text(
            'لم يتم العثور على عميل بهذا الاسم. هل تريد إضافة عميل جديد؟'),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Get.back(),
          ),
          ElevatedButton(
            child: const Text('إضافة'),
            onPressed: () {
              Get.back();
              addNewCustomer(query);
            },
          ),
        ],
      ),
    );
  }

  Future<void> addNewCustomer(String name) async {
    final nameController = TextEditingController(text: name);
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final notesController = TextEditingController();

    final formKey = GlobalKey<FormState>();
    final isLoading = false.obs;
    final nameError = RxnString();
    final phoneError = RxnString();

    // Real-time validation
    void validateName(String value) {
      if (value.trim().isEmpty) {
        nameError.value = 'اسم العميل مطلوب';
      } else if (value.trim().length < 2) {
        nameError.value = 'اسم العميل يجب أن يكون حرفين على الأقل';
      } else {
        nameError.value = null;
      }
    }

    void validatePhone(String value) {
      if (value.isNotEmpty) {
        final phoneRegex = RegExp(r'^(010|011|012|015)[0-9]{8}$');
        if (!phoneRegex.hasMatch(value)) {
          phoneError.value = 'رقم الهاتف غير صحيح (مثال: 01012345678)';
        } else {
          phoneError.value = null;
        }
      } else {
        phoneError.value = null;
      }
    }

    final result = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 16,
        child: Container(
          width: Get.width * 0.9,
          constraints: BoxConstraints(maxHeight: Get.height * 0.8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey[50]!],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Enhanced Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Get.theme.primaryColor,
                            Get.theme.primaryColor.withOpacity(0.8)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Get.theme.primaryColor.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person_add_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'إضافة عميل جديد',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'أضف بيانات العميل الجديد',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Customer Name Field (Required)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person_outlined,
                              color: Get.theme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'اسم العميل',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              ' *',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Obx(() => _buildEnhancedTextField(
                              controller: nameController,
                              hintText: 'أدخل اسم العميل',
                              prefixIcon: Icons.person_outlined,
                              errorText: nameError.value,
                              onChanged: validateName,
                              validator: (value) {
                                validateName(value ?? '');
                                return nameError.value;
                              },
                            )),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Phone Number Field (Optional)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              color: Get.theme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'رقم الهاتف',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'اختياري',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Obx(() => _buildEnhancedTextField(
                              controller: phoneController,
                              hintText: '01012345678',
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              errorText: phoneError.value,
                              onChanged: validatePhone,
                              validator: (value) {
                                validatePhone(value ?? '');
                                return phoneError.value;
                              },
                            )),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Address Field (Optional)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Get.theme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'العنوان',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'اختياري',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildEnhancedTextField(
                          controller: addressController,
                          hintText: 'أدخل عنوان العميل',
                          prefixIcon: Icons.location_on_outlined,
                          maxLines: 2,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Notes Field (Optional)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.note_outlined,
                              color: Get.theme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'ملاحظات',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'اختياري',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildEnhancedTextField(
                          controller: notesController,
                          hintText: 'أي ملاحظات إضافية عن العميل',
                          prefixIcon: Icons.note_outlined,
                          maxLines: 3,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.close_outlined),
                            label: const Text(
                              'إلغاء',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () => Get.back(result: false),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: BorderSide(
                                color: Colors.grey[400]!,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Obx(() => Container(
                                height: 60,
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
                                      color: Get.theme.primaryColor
                                          .withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  icon: isLoading.value
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.save_outlined,
                                          color: Colors.white,
                                        ),
                                  label: Text(
                                    isLoading.value
                                        ? 'جاري الحفظ...'
                                        : 'حفظ العميل',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: isLoading.value
                                      ? null
                                      : () async {
                                          if (formKey.currentState!
                                              .validate()) {
                                            isLoading.value = true;
                                            await Future.delayed(const Duration(
                                                milliseconds: 500));
                                            Get.back(result: true);
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              )),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Quick Add Templates
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.flash_on_outlined,
                                color: Colors.blue[700],
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'إضافة سريعة',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildQuickTemplate(
                                'عميل نقدي',
                                () {
                                  nameController.text = 'عميل نقدي';
                                  validateName('عميل نقدي');
                                },
                              ),
                              _buildQuickTemplate(
                                'عميل جديد',
                                () {
                                  nameController.text = 'عميل جديد';
                                  validateName('عميل جديد');
                                },
                              ),
                              _buildQuickTemplate(
                                'مسح الكل',
                                () {
                                  nameController.clear();
                                  phoneController.clear();
                                  addressController.clear();
                                  notesController.clear();
                                  nameError.value = null;
                                  phoneError.value = null;
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    if (result == true && nameController.text.isNotEmpty) {
      try {
        // Show loading indicator
        Get.dialog(
          const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('جاري حفظ بيانات العميل...'),
                  ],
                ),
              ),
            ),
          ),
          barrierDismissible: false,
        );

        final customer = Customer(
          name: nameController.text.trim(),
          phone: phoneController.text.trim().isEmpty
              ? null
              : phoneController.text.trim(),
          address: addressController.text.trim().isEmpty
              ? null
              : addressController.text.trim(),
        );

        final id = await _databaseService.insertCustomer(customer);
        selectedCustomer.value = Customer(
          id: id,
          name: customer.name,
          phone: customer.phone,
          address: customer.address,
        );

        // Close loading dialog
        Get.back();

        // Show success dialog
        Get.dialog(
          Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'تم إضافة العميل بنجاح',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'تم إضافة "${customer.name}" وتحديده تلقائياً',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      child: const Text('ممتاز'),
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        await _loadRecentCustomers();
      } catch (e) {
        // Close loading dialog if open
        if (Get.isDialogOpen ?? false) Get.back();

        // Show error dialog
        Get.dialog(
          Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'خطأ في إضافة العميل',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'حدث خطأ أثناء إضافة العميل: $e',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          child: const Text('إعادة المحاولة'),
                          onPressed: () {
                            Get.back();
                            addNewCustomer(name);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          child: const Text('إغلاق'),
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
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
    }
  }

// Enhanced TextField Builder
  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? errorText,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Get.theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              prefixIcon,
              color: Get.theme.primaryColor,
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          errorText: errorText,
          errorStyle: const TextStyle(
            fontSize: 12,
            height: 1.2,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Get.theme.primaryColor,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

// Quick Template Builder
  Widget _buildQuickTemplate(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.blue[700],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  // Enhanced invoice generation
  Future<void> printInvoice({bool showPreview = false}) async {
    if (showPreview) {
      await _showInvoicePreview();
      return;
    }

    try {
      isProcessingSale.value = true;

      final font = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
      final ttf = pw.Font.ttf(font);

      final pdf = pw.Document();

      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Professional header
              _buildInvoiceHeader(ttf),
              pw.SizedBox(height: 30),

              // Customer and invoice info
              _buildInvoiceInfo(ttf),
              pw.SizedBox(height: 20),

              // Items table
              _buildInvoiceTable(ttf),
              pw.SizedBox(height: 20),

              // Totals section
              _buildInvoiceTotals(ttf),
              pw.SizedBox(height: 30),

              // Footer
              _buildInvoiceFooter(ttf),
            ],
          ),
        ),
      ));

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename:
            'فاتورة_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.pdf',
      );

      Get.snackbar(
        'نجاح',
        'تم إنشاء الفاتورة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إنشاء الفاتورة: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isProcessingSale.value = false;
    }
  }

  pw.Widget _buildInvoiceHeader(pw.Font ttf) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
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
                'فاتورة بيع',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 16,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'رقم الفاتورة: ${DateTime.now().millisecondsSinceEpoch}',
                style: pw.TextStyle(
                    font: ttf, fontSize: 12, color: PdfColors.white),
              ),
              pw.Text(
                'التاريخ: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                style: pw.TextStyle(
                    font: ttf, fontSize: 12, color: PdfColors.white),
              ),
              pw.Text(
                'الوقت: ${DateFormat('HH:mm').format(DateTime.now())}',
                style: pw.TextStyle(
                    font: ttf, fontSize: 12, color: PdfColors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInvoiceInfo(pw.Font ttf) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'بيانات العميل',
                  style: pw.TextStyle(
                      font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'الاسم: ${selectedCustomer.value?.name ?? "عميل نقدي"}',
                  style: pw.TextStyle(font: ttf, fontSize: 12),
                ),
                if (selectedCustomer.value?.phone?.isNotEmpty == true)
                  pw.Text(
                    'الهاتف: ${selectedCustomer.value!.phone}',
                    style: pw.TextStyle(font: ttf, fontSize: 12),
                  ),
                if (selectedCustomer.value?.address?.isNotEmpty == true)
                  pw.Text(
                    'العنوان: ${selectedCustomer.value!.address}',
                    style: pw.TextStyle(font: ttf, fontSize: 12),
                  ),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 20),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'ملخص الفاتورة',
                  style: pw.TextStyle(
                      font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'عدد الأصناف: ${cartItems.length}',
                  style: pw.TextStyle(font: ttf, fontSize: 12),
                ),
                pw.Text(
                  'إجمالي القطع: ${cartItems.fold(0, (sum, item) => sum + item.quantity)}',
                  style: pw.TextStyle(font: ttf, fontSize: 12),
                ),
                if (showProfitMargin.value)
                  pw.Text(
                    'إجمالي الربح: ${totalProfit.value.toStringAsFixed(2)} جنيه',
                    style: pw.TextStyle(
                        font: ttf, fontSize: 12, color: PdfColors.green),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildInvoiceTable(pw.Font ttf) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell(ttf, 'اسم الدواء', isHeader: true),
            _buildTableCell(ttf, 'الكمية', isHeader: true),
            _buildTableCell(ttf, 'سعر الوحدة', isHeader: true),
            _buildTableCell(ttf, 'الإجمالي', isHeader: true),
          ],
        ),
        // Data rows
        for (int i = 0; i < selectedMedicines.length; i++)
          pw.TableRow(
            children: [
              _buildTableCell(ttf, selectedMedicines[i].name),
              _buildTableCell(ttf, cartItems[i].quantity.toString()),
              _buildTableCell(
                  ttf, '${cartItems[i].price.toStringAsFixed(2)} جنيه'),
              _buildTableCell(ttf,
                  '${(cartItems[i].quantity * cartItems[i].price).toStringAsFixed(2)} جنيه'),
            ],
          ),
      ],
    );
  }

  pw.Widget _buildTableCell(pw.Font ttf, String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
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

  pw.Widget _buildInvoiceTotals(pw.Font ttf) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          _buildTotalRow(ttf, 'المجموع الفرعي', subtotal.value),
          if (discount.value > 0)
            _buildTotalRow(ttf, 'الخصم', -discount.value, color: PdfColors.red),
          if (tax.value > 0)
            _buildTotalRow(ttf, 'الضريبة (${taxRate.value}%)', tax.value),
          pw.Divider(color: PdfColors.grey),
          _buildTotalRow(ttf, 'الإجمالي النهائي', total.value, isTotal: true),
        ],
      ),
    );
  }

  pw.Widget _buildTotalRow(pw.Font ttf, String label, double amount,
      {bool isTotal = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: ttf,
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            '${amount.toStringAsFixed(2)} جنيه',
            style: pw.TextStyle(
              font: ttf,
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color ?? (isTotal ? PdfColors.blue : PdfColors.black),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInvoiceFooter(pw.Font ttf) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'شكراً لثقتكم بنا',
            style: pw.TextStyle(
                font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'للاستفسارات: 01234567890 | info@vetpharmacy.com',
            style: pw.TextStyle(font: ttf, fontSize: 10),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            'العنوان: شارع المستشفى البيطري، القاهرة، مصر',
            style: pw.TextStyle(font: ttf, fontSize: 10),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _showInvoicePreview() async {
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.9,
          height: Get.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'معاينة الفاتورة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildInvoicePreviewContent(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('تعديل'),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.print_outlined),
                      label: const Text('طباعة'),
                      onPressed: () {
                        Get.back();
                        printInvoice();
                      },
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

  Widget _buildInvoicePreviewContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Get.theme.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الصيدلية البيطرية',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'فاتورة بيع',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'التاريخ: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      'الوقت: ${DateFormat('HH:mm').format(DateTime.now())}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Customer info
          Text('العميل: ${selectedCustomer.value?.name ?? "عميل نقدي"}'),
          if (selectedCustomer.value?.phone?.isNotEmpty == true)
            Text('الهاتف: ${selectedCustomer.value!.phone}'),

          const SizedBox(height: 20),

          // Items table
          Table(
            border: TableBorder.all(color: Colors.grey[300]!),
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[200]),
                children: [
                  _buildPreviewTableCell('الصنف', isHeader: true),
                  _buildPreviewTableCell('الكمية', isHeader: true),
                  _buildPreviewTableCell('السعر', isHeader: true),
                  _buildPreviewTableCell('الإجمالي', isHeader: true),
                ],
              ),
              for (int i = 0; i < selectedMedicines.length; i++)
                TableRow(
                  children: [
                    _buildPreviewTableCell(selectedMedicines[i].name),
                    _buildPreviewTableCell('${cartItems[i].quantity}'),
                    _buildPreviewTableCell(
                        '${cartItems[i].price.toStringAsFixed(2)}'),
                    _buildPreviewTableCell(
                        '${(cartItems[i].quantity * cartItems[i].price).toStringAsFixed(2)}'),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Totals
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                if (discount.value > 0)
                  _buildPreviewTotalRow('الخصم', discount.value),
                if (tax.value > 0) _buildPreviewTotalRow('الضريبة', tax.value),
                const Divider(),
                _buildPreviewTotalRow('الإجمالي النهائي', total.value,
                    isTotal: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewTableCell(String text, {bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPreviewTotalRow(String label, double amount,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} جنيه',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Get.theme.primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced sale completion
  Future<void> completeSale() async {
    if (cartItems.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'لا توجد أصناف في سلة البيع',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    if (selectedCustomer.value == null) {
      Get.snackbar(
        'تنبيه',
        'يرجى اختيار العميل أو إضافة "عميل نقدي"',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    try {
      isProcessingSale.value = true;

      final sale = Sale(
        customerId: selectedCustomer.value?.id,
        date: DateTime.now(),
        items: cartItems,
        total: total.value,
      );

      await _databaseService.insertSale(sale);

      // Update inventory
      for (var i = 0; i < cartItems.length; i++) {
        final medicine = selectedMedicines[i];
        await _databaseService.updateMedicineQuantity(
          medicine.id!,
          medicine.quantity - cartItems[i].quantity,
        );
      }

      // Auto print if enabled
      if (autoPrintInvoice.value) {
        await printInvoice();
      }

      // Clear cart
      _clearCart();

      Get.snackbar(
        'نجاح',
        'تم إتمام عملية البيع بنجاح\nإجمالي المبلغ: ${total.value.toStringAsFixed(2)} جنيه',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Show success dialog with options
      _showSaleCompletedDialog();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إتمام عملية البيع: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isProcessingSale.value = false;
    }
  }

  void _showSaleCompletedDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('تم إتمام البيع'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('تم إتمام عملية البيع بنجاح'),
            const SizedBox(height: 8),
            Text(
              'إجمالي المبلغ: ${total.value.toStringAsFixed(2)} جنيه',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('بيع جديد'),
            onPressed: () {
              Get.back();
              _startNewSale();
            },
          ),
          if (!autoPrintInvoice.value)
            ElevatedButton(
              child: const Text('طباعة الفاتورة'),
              onPressed: () {
                Get.back();
                printInvoice();
              },
            ),
        ],
      ),
    );
  }

  void _startNewSale() {
    selectedCustomer.value = null;
    // Keep the view open for next sale
  }

  void _clearCart() {
    cartItems.clear();
    selectedMedicines.clear();
    discount.value = 0.0;
  }

  // Quick access methods
  void addFrequentMedicine(Medicine medicine) {
    addMedicineToCart(medicine);
  }

  void selectRecentCustomer(Customer customer) {
    selectedCustomer.value = customer;
  }

  // Settings methods
  void updateSettings({
    bool? autoSelectFirst,
    bool? showProfit,
    bool? autoPrint,
    bool? lowStockWarning,
    double? taxRateValue,
  }) {
    if (autoSelectFirst != null) autoSelectFirstResult.value = autoSelectFirst;
    if (showProfit != null) showProfitMargin.value = showProfit;
    if (autoPrint != null) autoPrintInvoice.value = autoPrint;
    if (lowStockWarning != null) enableLowStockWarning.value = lowStockWarning;
    if (taxRateValue != null) taxRate.value = taxRateValue;
  }

  void applyDiscount(double discountAmount) {
    discount.value = discountAmount;
  }

  void applyPercentageDiscount(double percentage) {
    discount.value = subtotal.value * (percentage / 100);
  }

  @override
  void onClose() {
    // Clean up resources
    super.onClose();
  }
}

// // lib/app/modules/sales/controllers/sales_controller.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:pdf/pdf.dart';
// import 'package:printing/printing.dart';
// import '../../../data/models/medicine.dart';
// import '../../../data/models/sale.dart';
// import '../../../data/models/customer.dart';
// import '../../../data/services/database_service.dart';

// class SalesController extends GetxController {
//   final DatabaseService _databaseService = Get.find<DatabaseService>();

//   final cartItems = <SaleItem>[].obs;
//   final selectedMedicines = <Medicine>[].obs;
//   final selectedCustomer = Rxn<Customer>();

//   final total = 0.0.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     ever(cartItems, (_) => _calculateTotal());
//   }

//   void _calculateTotal() {
//     // تحديث السعر الإجمالي
//     double sum = 0.0;
//     for (int i = 0; i < cartItems.length; i++) {
//       sum += cartItems[i].quantity * cartItems[i].price;
//     }
//     total.value = sum;
//   }

//   Future<void> searchMedicines(String query) async {
//     if (query.isEmpty) return;

//     final medicines = await _databaseService.searchMedicines(query);
//     if (medicines.isNotEmpty) {
//       Get.dialog(
//         AlertDialog(
//           title: Text('نتائج البحث'),
//           content: SizedBox(
//             width: double.maxFinite,
//             child: ListView.builder(
//               shrinkWrap: true,
//               itemCount: medicines.length,
//               itemBuilder: (context, index) {
//                 final medicine = medicines[index];
//                 return ListTile(
//                   title: Text(medicine.name),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('سعر البيع: ${medicine.sellingPrice} جنيه'),
//                       Text('سعر الشراء: ${medicine.purchasePrice} جنيه'),
//                       Text('سعر السوق: ${medicine.marketPrice} جنيه'),
//                     ],
//                   ),
//                   onTap: () {
//                     Get.back();
//                     addMedicineToCart(medicine);
//                   },
//                 );
//               },
//             ),
//           ),
//         ),
//       );
//     }
//   }

//   void addMedicineToCart(Medicine medicine) {
//     // التحقق من عدم تكرار الدواء في السلة
//     final existingIndex =
//         selectedMedicines.indexWhere((m) => m.id == medicine.id);

//     if (existingIndex != -1) {
//       // إذا كان الدواء موجود، نزيد الكمية
//       final currentQuantity = cartItems[existingIndex].quantity;
//       if (currentQuantity < medicine.quantity) {
//         updateItemQuantity(existingIndex, currentQuantity + 1);
//       } else {
//         Get.snackbar(
//           'تنبيه',
//           'لا يمكن إضافة المزيد من هذا الدواء. الكمية المتاحة: ${medicine.quantity}',
//           snackPosition: SnackPosition.BOTTOM,
//         );
//       }
//     } else {
//       // إضافة دواء جديد
//       selectedMedicines.add(medicine);
//       cartItems.add(SaleItem(
//         medicineId: medicine.id!,
//         quantity: 1,
//         price: medicine.sellingPrice,
//       ));

//       // تحديث الإجمالي
//       _calculateTotal();
//     }
//   }

//   void removeMedicineFromCart(int index) {
//     // إزالة الدواء من القوائم
//     selectedMedicines.removeAt(index);
//     cartItems.removeAt(index);

//     // تحديث الإجمالي
//     _calculateTotal();
//   }

//   // تحديث الكمية مع السعر
//   void updateItemQuantity(int index, int newQuantity) {
//     final medicine = selectedMedicines[index];

//     if (newQuantity <= 0) {
//       Get.snackbar(
//         'تنبيه',
//         'الكمية يجب أن تكون أكبر من صفر',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }

//     if (newQuantity > medicine.quantity) {
//       Get.snackbar(
//         'تنبيه',
//         'الكمية المطلوبة غير متوفرة في المخزون. المتاح: ${medicine.quantity}',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }

//     // تحديث الكمية
//     var newItems = [...cartItems];
//     newItems[index] = SaleItem(
//       medicineId: cartItems[index].medicineId,
//       quantity: newQuantity,
//       price: cartItems[index].price,
//     );

//     cartItems.assignAll(newItems);

//     // تحديث الإجمالي تلقائياً
//     _calculateTotal();
//   }

//   Future<void> printInvoice() async {
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
//               // ترويسة الفاتورة
//               pw.Text(
//                 'فاتورة بيع',
//                 style: pw.TextStyle(font: ttf, fontSize: 24),
//               ),
//               pw.SizedBox(height: 20),

//               // معلومات العميل
//               pw.Text(
//                 'العميل: ${selectedCustomer.value?.name ?? "غير محدد"}',
//                 style: pw.TextStyle(font: ttf),
//               ),
//               pw.Text(
//                 'التاريخ: ${DateTime.now().toString().split('.')[0]}',
//                 style: pw.TextStyle(font: ttf),
//               ),
//               pw.SizedBox(height: 20),

//               // جدول الأصناف
//               pw.Table(
//                 border: pw.TableBorder.all(),
//                 children: [
//                   // رأس الجدول
//                   pw.TableRow(
//                     children: [
//                       pw.Padding(
//                         padding: pw.EdgeInsets.all(5),
//                         child: pw.Text('الصنف', style: pw.TextStyle(font: ttf)),
//                       ),
//                       pw.Padding(
//                         padding: pw.EdgeInsets.all(5),
//                         child:
//                             pw.Text('الكمية', style: pw.TextStyle(font: ttf)),
//                       ),
//                       pw.Padding(
//                         padding: pw.EdgeInsets.all(5),
//                         child: pw.Text('السعر', style: pw.TextStyle(font: ttf)),
//                       ),
//                       pw.Padding(
//                         padding: pw.EdgeInsets.all(5),
//                         child:
//                             pw.Text('الإجمالي', style: pw.TextStyle(font: ttf)),
//                       ),
//                     ],
//                   ),
//                   // بيانات الأصناف
//                   ...List.generate(selectedMedicines.length, (index) {
//                     final medicine = selectedMedicines[index];
//                     final item = cartItems[index];
//                     return pw.TableRow(
//                       children: [
//                         pw.Padding(
//                           padding: pw.EdgeInsets.all(5),
//                           child: pw.Text(medicine.name,
//                               style: pw.TextStyle(font: ttf)),
//                         ),
//                         pw.Padding(
//                           padding: pw.EdgeInsets.all(5),
//                           child: pw.Text(item.quantity.toString(),
//                               style: pw.TextStyle(font: ttf)),
//                         ),
//                         pw.Padding(
//                           padding: pw.EdgeInsets.all(5),
//                           child: pw.Text(item.price.toString(),
//                               style: pw.TextStyle(font: ttf)),
//                         ),
//                         pw.Padding(
//                           padding: pw.EdgeInsets.all(5),
//                           child: pw.Text(
//                               (item.price * item.quantity).toString(),
//                               style: pw.TextStyle(font: ttf)),
//                         ),
//                       ],
//                     );
//                   }),
//                 ],
//               ),

//               pw.SizedBox(height: 20),

//               // الإجمالي
//               pw.Text(
//                 'الإجمالي: ${total.value} جنيه',
//                 style: pw.TextStyle(font: ttf, fontSize: 18),
//               ),
//             ],
//           ),
//         ),
//       ));

//       await Printing.sharePdf(bytes: await pdf.save());
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'حدث خطأ أثناء طباعة الفاتورة: $e',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }

//   Future<void> searchCustomers(String query) async {
//     if (query.isEmpty) return;

//     final customers = await _databaseService.searchCustomers(query);
//     Get.dialog(
//       AlertDialog(
//         title: Text('نتائج البحث'),
//         content: SizedBox(
//           width: double.maxFinite,
//           height: 300,
//           child: Column(
//             children: [
//               ElevatedButton.icon(
//                 icon: Icon(Icons.add),
//                 label: Text('إضافة عميل جديد'),
//                 onPressed: () {
//                   Get.back();
//                   addNewCustomer(query);
//                 },
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: customers.length,
//                   itemBuilder: (context, index) {
//                     final customer = customers[index];
//                     return ListTile(
//                       title: Text(customer.name),
//                       subtitle:
//                           customer.phone != null ? Text(customer.phone!) : null,
//                       onTap: () {
//                         selectedCustomer.value = customer;
//                         Get.back();
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> addNewCustomer(String name) async {
//     final nameController = TextEditingController(text: name);
//     final phoneController = TextEditingController();
//     final addressController = TextEditingController();

//     final result = await Get.dialog<bool>(
//       AlertDialog(
//         title: Text('إضافة عميل جديد'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: InputDecoration(labelText: 'اسم العميل'),
//             ),
//             TextField(
//               controller: phoneController,
//               decoration: InputDecoration(labelText: 'رقم الهاتف'),
//               keyboardType: TextInputType.phone,
//             ),
//             TextField(
//               controller: addressController,
//               decoration: InputDecoration(labelText: 'العنوان'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             child: Text('إلغاء'),
//             onPressed: () => Get.back(result: false),
//           ),
//           ElevatedButton(
//             child: Text('حفظ'),
//             onPressed: () => Get.back(result: true),
//           ),
//         ],
//       ),
//     );

//     if (result == true) {
//       final customer = Customer(
//         name: nameController.text,
//         phone: phoneController.text,
//         address: addressController.text,
//       );

//       final id = await _databaseService.insertCustomer(customer);
//       selectedCustomer.value = Customer(
//         id: id,
//         name: customer.name,
//         phone: customer.phone,
//         address: customer.address,
//       );
//     }
//   }

//   // تحديث دالة إتمام البيع لتشمل طباعة الفاتورة
//   Future<void> completeSale() async {
//     if (cartItems.isEmpty) {
//       Get.snackbar(
//         'تنبيه',
//         'لا توجد أصناف في سلة البيع',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }

//     if (selectedCustomer.value == null) {
//       Get.snackbar(
//         'تنبيه',
//         'يرجى اختيار العميل',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }

//     try {
//       final sale = Sale(
//         customerId: selectedCustomer.value?.id,
//         date: DateTime.now(),
//         items: cartItems,
//         total: total.value,
//       );

//       await _databaseService.insertSale(sale);

//       // تحديث المخزون
//       for (var i = 0; i < cartItems.length; i++) {
//         final medicine = selectedMedicines[i];
//         await _databaseService.updateMedicineQuantity(
//           medicine.id!,
//           medicine.quantity - cartItems[i].quantity,
//         );
//       }

//       // طباعة الفاتورة
//       await printInvoice();

//       Get.back();
//       Get.snackbar(
//         'نجاح',
//         'تم إتمام عملية البيع بنجاح',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'حدث خطأ أثناء إتمام عملية البيع: $e',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }
// }
