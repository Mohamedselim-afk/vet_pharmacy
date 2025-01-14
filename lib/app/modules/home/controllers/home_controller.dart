// lib/app/modules/home/controllers/home_controller.dart
import 'dart:async';

import 'package:get/get.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/medicine.dart';
import '../../../data/models/sale.dart';

class HomeController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  
  final totalMedicines = 0.obs;
  final totalQuantity = 0.obs;
  final dailySales = 0.0.obs;

  // Workers
  Worker? _medicineWorker;
  Worker? _salesWorker;
  Timer? _refreshTimer;
  
  @override
  void onInit() {
    super.onInit();
    loadStats();
    setupStreamWorkers();
    setupPeriodicRefresh();
  }

  void setupStreamWorkers() {
    // Listen to medicine changes
    _medicineWorker = ever(
      _databaseService.medicinesUpdate,
      (_) => _updateMedicineStats()
    );

    // Listen to sales changes
    _salesWorker = ever(
      _databaseService.salesUpdate,
      (_) => _updateSalesStats()
    );
  }

  void setupPeriodicRefresh() {
    // Refresh stats every minute
    _refreshTimer = Timer.periodic(Duration(minutes: 1), (_) => loadStats());
  }
  
  Future<void> loadStats() async {
    await Future.wait([
      _updateMedicineStats(),
      _updateSalesStats(),
    ]);
  }

  Future<void> _updateMedicineStats() async {
    final medicines = await _databaseService.getAllMedicines();
    totalMedicines.value = medicines.length;
    totalQuantity.value = medicines.fold(0, (sum, med) => sum + med.quantity);
  }

  Future<void> _updateSalesStats() async {
    final today = DateTime.now();
    final dailySalesReport = await _databaseService.getDailySalesReport(today);
    dailySales.value = dailySalesReport.isNotEmpty 
        ? dailySalesReport.first['total_amount'] ?? 0.0 
        : 0.0;
  }

  // Pull to refresh functionality
  Future<void> onRefresh() async {
    await loadStats();
  }

  @override
  void onClose() {
    _medicineWorker?.dispose();
    _salesWorker?.dispose();
    _refreshTimer?.cancel();
    super.onClose();
  }
}