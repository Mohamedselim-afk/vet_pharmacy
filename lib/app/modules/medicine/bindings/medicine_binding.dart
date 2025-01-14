// lib/app/modules/medicine/bindings/medicine_binding.dart
import 'package:get/get.dart';
import '../controllers/medicine_controller.dart';

class MedicineBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MedicineController>(
      () => MedicineController(),
    );
  }
}