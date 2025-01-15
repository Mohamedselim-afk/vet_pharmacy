// lib/app/modules/supplier/controllers/supplier_controller.dart
import 'package:get/get.dart';
import '../../../data/models/supplier.dart';
import '../../../data/models/medicine.dart';
import '../../../data/services/database_service.dart';

class SupplierController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final suppliers = <Supplier>[].obs;
  final selectedSupplierId = RxnInt();

  // إضافة متغير للتحميل
  final isLoading = false.obs;

  // قائمة الأدوية للمندوب المحدد
  final supplierMedicines = <Medicine>[].obs;

  @override
  void onInit() {
    super.onInit();
    print('SupplierController initialized');
    loadSuppliers();
    _setupListeners();
  }

  void _setupListeners() {
    ever(_databaseService.suppliersUpdate, (_) {
      print('Suppliers update detected');
      loadSuppliers();
    });
  }

  // تحميل قائمة المناديب
  Future<void> loadSuppliers() async {
    try {
      isLoading.value = true;
      print('Starting to load suppliers');

      final loadedSuppliers = await _databaseService.getAllSuppliers();
      print('Loaded ${loadedSuppliers.length} suppliers');

      suppliers.value = loadedSuppliers;

      if (suppliers.isNotEmpty && selectedSupplierId.value == null) {
        selectedSupplierId.value = suppliers.first.id;
        print('Selected first supplier with id: ${selectedSupplierId.value}');
      }
    } catch (e, stackTrace) {
      print('Error loading suppliers: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'خطأ',
        'حدث خطأ في تحميل بيانات المناديب: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // إضافة مندوب جديد
  Future<void> addSupplier(Supplier supplier) async {
    try {
      print('Adding supplier: ${supplier.name}');
      await _databaseService.insertSupplier(supplier);
      await loadSuppliers();

      Get.snackbar(
        'نجاح',
        'تم إضافة المندوب بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error adding supplier: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ في إضافة المندوب',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // تحميل أدوية مندوب معين
  Future<void> loadSupplierMedicines(int supplierId) async {
    try {
      final List<Medicine> medicines =
          await _databaseService.getMedicinesBySupplier(supplierId);
      supplierMedicines.value = medicines;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل قائمة الأدوية',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // الحصول على ملخص حساب المندوب
  Future<Map<String, dynamic>> getSupplierSummary(int supplierId) async {
    try {
      final data = await _databaseService.getSupplierSummary(supplierId);
      // تأكد من أن القيم ليست null
      return {
        'remaining_amount': data['remaining_amount'] ?? 0.0,
        'medicine_count': data['medicine_count'] ?? 0,
      };
    } catch (e) {
      print('Error getting supplier summary: $e');
      // إرجاع قيم افتراضية في حالة حدوث خطأ
      return {
        'remaining_amount': 0.0,
        'medicine_count': 0,
      };
    }
  }

  // تحديث بيانات المندوب
  Future<void> updateSupplier(Supplier supplier) async {
    try {
      // يجب إضافة دالة updateSupplier في DatabaseService
      await _databaseService.updateSupplier(supplier);
      await loadSuppliers();
      Get.snackbar(
        'نجاح',
        'تم تحديث بيانات المندوب بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحديث بيانات المندوب',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // تسجيل دفعة جديدة لدواء معين
  Future<void> addPaymentForMedicine(int medicineId, double amount) async {
    try {
      final medicine = await _databaseService.getMedicineById(medicineId);
      if (medicine != null) {
        final newAmountPaid = medicine.amountPaid + amount;
        // تحديث المبلغ المدفوع في الدواء
        await _databaseService.updateMedicinePaidAmount(
            medicineId, newAmountPaid);
        // إعادة تحميل قائمة الأدوية
        await loadSupplierMedicines(medicine.supplierId);
        Get.snackbar(
          'نجاح',
          'تم تسجيل الدفعة بنجاح',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تسجيل الدفعة',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    suppliers.close();
    supplierMedicines.close();
    super.onClose();
  }
}
