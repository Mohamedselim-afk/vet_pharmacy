// lib/app/modules/inventory/bindings/inventory_binding.dart
import 'package:get/get.dart';
import '../controllers/inventory_controller.dart';

class InventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InventoryController>(
      () => InventoryController(),
    );
  }
}