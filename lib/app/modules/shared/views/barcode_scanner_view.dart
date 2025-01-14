// lib/app/modules/shared/views/barcode_scanner_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/barcode_scanner_controller.dart';

class BarcodeScannerView extends GetView<BarcodeScannerController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('مسح الباركود')),
      body: MobileScanner(
        onDetect: controller.onDetect,
      ),
    );
  }
}