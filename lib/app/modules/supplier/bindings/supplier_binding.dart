// lib/app/modules/supplier/bindings/supplier_binding.dart
import 'package:get/get.dart';
import '../controllers/supplier_controller.dart';

class SupplierBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupplierController>(
      () => SupplierController(),
    );
  }
}