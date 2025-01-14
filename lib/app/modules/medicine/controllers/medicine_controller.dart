// lib/app/modules/medicine/controllers/medicine_controller.dart
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/medicine.dart';
import '../../../data/models/supplier.dart';
import '../../../data/services/database_service.dart';

class MedicineController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final ImagePicker _picker = ImagePicker();

  // حقول الدواء الأساسية
  final name = ''.obs;
  final barcode = ''.obs;
  final imagePath = RxnString();
  final expiryDate = Rxn<DateTime>();

  // حقول التسعير
  final marketPrice = 0.0.obs;
  final sellingPrice = 0.0.obs;
  final purchasePrice = 0.0.obs;
  final boxQuantity = 0.obs;
  final boxPrice = 0.0.obs;
  final totalQuantity = 0.obs;
  final amountPaid = 0.0.obs;
  final quantity = 0.obs; // للتوافق مع الواجهة القديمة
  final price = 0.0.obs; // للتوافق مع الواجهة القديمة

  // معلومات المندوب
  final suppliers = <Supplier>[].obs;
  final selectedSupplierId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    // Load suppliers immediately when controller initializes
    loadSuppliers();
    // Listen to any changes in the database
    ever(_databaseService.medicinesUpdate, (_) => loadSuppliers());
  }

   // تهيئة البيانات للتعديل
  void initializeForEdit(Medicine medicine) {
    name.value = medicine.name;
    barcode.value = medicine.barcode;
    quantity.value = medicine.quantity;
    price.value = medicine.sellingPrice; // نستخدم سعر البيع كسعر افتراضي
    marketPrice.value = medicine.marketPrice;
    sellingPrice.value = medicine.sellingPrice;
    purchasePrice.value = medicine.purchasePrice;
    boxQuantity.value = medicine.boxQuantity;
    boxPrice.value = medicine.boxPrice;
    totalQuantity.value = medicine.totalQuantity;
    amountPaid.value = medicine.amountPaid;
    selectedSupplierId.value = medicine.supplierId;
    imagePath.value = medicine.image;
    expiryDate.value = medicine.expiryDate;
  }


   // إضافة دالة تحديث الدواء
  Future<void> updateMedicine(int id) async {
    if (!_validateInputs()) return;

    final medicine = Medicine(
      id: id,
      name: name.value,
      barcode: barcode.value,
      quantity: quantity.value,
      marketPrice: marketPrice.value,
      sellingPrice: sellingPrice.value,
      purchasePrice: purchasePrice.value,
      boxQuantity: boxQuantity.value,
      boxPrice: boxPrice.value,
      totalQuantity: totalQuantity.value,
      amountPaid: amountPaid.value,
      supplierId: selectedSupplierId.value!,
      image: imagePath.value!,
      expiryDate: expiryDate.value!,
    );

    try {
      await _databaseService.updateMedicine(medicine);
      Get.back(result: true);
      Get.snackbar(
        'نجاح',
        'تم تحديث الدواء بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحديث الدواء',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }


  // تحميل قائمة المناديب
  Future<void> loadSuppliers() async {
    try {
      final loadedSuppliers = await _databaseService.getAllSuppliers();
      suppliers.value = loadedSuppliers;
      
      // If we have suppliers but none selected, select the first one
      if (suppliers.isNotEmpty && selectedSupplierId.value == null) {
        selectedSupplierId.value = suppliers.first.id;
      }
    } catch (e) {
      print('Error loading suppliers: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ في تحميل بيانات المناديب',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> addNewSupplier(String name, String? phone, String? address) async {
    try {
      final supplier = Supplier(
        name: name,
        phone: phone,
        address: address,
      );
      
      final id = await _databaseService.insertSupplier(supplier);
      await loadSuppliers();
      selectedSupplierId.value = id;
      
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


  // دوال تعيين القيم
  void setName(String value) => name.value = value;
  void setBarcode(String value) => barcode.value = value;
  void setMarketPrice(double value) => marketPrice.value = value;
  void setSellingPrice(double value) => sellingPrice.value = value;
  void setPurchasePrice(double value) => purchasePrice.value = value;
  void setBoxQuantity(int value) => boxQuantity.value = value;
  void setBoxPrice(double value) => boxPrice.value = value;
  void setTotalQuantity(int value) => totalQuantity.value = value;
  void setAmountPaid(double value) => amountPaid.value = value;
  void setExpiryDate(DateTime value) => expiryDate.value = value;

  // دوال الصورة
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      imagePath.value = image.path;
    }
  }

  void clearImage() => imagePath.value = null;

  // حساب المكسب
  double calculateProfit() {
    return sellingPrice.value - purchasePrice.value;
  }

  // حساب المبلغ المتبقي
  double calculateRemainingAmount() {
    final totalCost = totalQuantity.value * purchasePrice.value;
    return totalCost - amountPaid.value;
  }

  // حساب القيمة الإجمالية
  double calculateTotalValue() {
    return totalQuantity.value * purchasePrice.value;
  }

  // حفظ الدواء
  Future<void> saveMedicine() async {
    if (!_validateInputs()) return;

    final medicine = Medicine(
      name: name.value,
      barcode: barcode.value,
      quantity: totalQuantity.value,
      marketPrice: marketPrice.value,
      sellingPrice: sellingPrice.value,
      purchasePrice: purchasePrice.value,
      boxQuantity: boxQuantity.value,
      boxPrice: boxPrice.value,
      totalQuantity: totalQuantity.value,
      amountPaid: amountPaid.value,
      supplierId: selectedSupplierId.value!,
      image: imagePath.value!,
      expiryDate: expiryDate.value!,
    );

    try {
      await _databaseService.insertMedicine(medicine);
      Get.back(result: true);
      Get.snackbar(
        'نجاح',
        'تم حفظ الدواء بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء حفظ الدواء',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // التحقق من صحة المدخلات
  bool _validateInputs() {
    if (name.value.isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال اسم الدواء');
      return false;
    }
    if (selectedSupplierId.value == null) {
      Get.snackbar('خطأ', 'يرجى اختيار المندوب');
      return false;
    }
    if (purchasePrice.value <= 0) {
      Get.snackbar('خطأ', 'يرجى إدخال سعر شراء صحيح');
      return false;
    }
    if (sellingPrice.value <= 0) {
      Get.snackbar('خطأ', 'يرجى إدخال سعر بيع صحيح');
      return false;
    }
    if (totalQuantity.value <= 0) {
      Get.snackbar('خطأ', 'يرجى إدخال كمية صحيحة');
      return false;
    }
    if (boxQuantity.value <= 0) {
      Get.snackbar('خطأ', 'يرجى إدخال كمية العلبة');
      return false;
    }
    if (boxPrice.value <= 0) {
      Get.snackbar('خطأ', 'يرجى إدخال سعر العلبة');
      return false;
    }
    if (imagePath.value == null) {
      Get.snackbar('خطأ', 'يرجى التقاط صورة للدواء');
      return false;
    }
    if (expiryDate.value == null) {
      Get.snackbar('خطأ', 'يرجى تحديد تاريخ انتهاء الصلاحية');
      return false;
    }
    return true;
  }

  // إعادة تعيين جميع الحقول
  void reset() {
    name.value = '';
    barcode.value = '';
    marketPrice.value = 0.0;
    sellingPrice.value = 0.0;
    purchasePrice.value = 0.0;
    boxQuantity.value = 0;
    boxPrice.value = 0.0;
    totalQuantity.value = 0;
    amountPaid.value = 0.0;
    quantity.value = 0;
    price.value = 0.0;
    imagePath.value = null;
    expiryDate.value = null;
    selectedSupplierId.value = null;
  }

  @override
  void onClose() {
    name.close();
    barcode.close();
    marketPrice.close();
    sellingPrice.close();
    purchasePrice.close();
    boxQuantity.close();
    boxPrice.close();
    totalQuantity.close();
    amountPaid.close();
    imagePath.close();
    expiryDate.close();
    selectedSupplierId.close();
    suppliers.close();
    quantity.close();
    price.close();
    super.onClose();
  }
}
