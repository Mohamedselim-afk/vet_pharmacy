// lib/app/modules/shared/controllers/barcode_scanner_controller.dart
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerController extends GetxController {
  final isScanning = true.obs;
  final scanResult = RxnString();
  
  void onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && isScanning.value) {
      isScanning.value = false;
      scanResult.value = barcodes.first.rawValue;
      Get.back(result: scanResult.value);
    }
  }
}