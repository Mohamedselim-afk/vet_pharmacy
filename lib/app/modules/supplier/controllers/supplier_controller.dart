// lib/app/modules/supplier/controllers/supplier_controller.dart
import 'package:get/get.dart';
import '../../../data/models/supplier.dart';
import '../../../data/models/medicine.dart';
import '../../../data/services/database_service.dart';

class SupplierController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  // قائمة المناديب
  final suppliers = <Supplier>[].obs;
  
  // قائمة الأدوية للمندوب المحدد
  final supplierMedicines = <Medicine>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSuppliers();
  }

  // تحميل قائمة المناديب
  Future<void> loadSuppliers() async {
    try {
      final List<Supplier> loadedSuppliers = await _databaseService.getAllSuppliers();
      suppliers.value = loadedSuppliers;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل قائمة المناديب',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // إضافة مندوب جديد
  Future<void> addSupplier(Supplier supplier) async {
    try {
      await _databaseService.insertSupplier(supplier);
      await loadSuppliers(); // إعادة تحميل القائمة
      Get.snackbar(
        'نجاح',
        'تم إضافة المندوب بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إضافة المندوب',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // تحميل أدوية مندوب معين
  Future<void> loadSupplierMedicines(int supplierId) async {
    try {
      final List<Medicine> medicines = await _databaseService.getMedicinesBySupplier(supplierId);
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
      return await _databaseService.getSupplierSummary(supplierId);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل ملخص الحساب',
        snackPosition: SnackPosition.BOTTOM,
      );
      return {
        'total_amount': 0.0,
        'total_paid': 0.0,
        'remaining_amount': 0.0,
        'medicine_count': 0
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
        await _databaseService.updateMedicinePaidAmount(medicineId, newAmountPaid);
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