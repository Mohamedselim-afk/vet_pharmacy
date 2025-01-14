// lib/app/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:vet_pharmacy/app/modules/supplier/bindings/supplier_binding.dart';
import 'package:vet_pharmacy/app/modules/supplier/views/supplier_details_view.dart';
import 'package:vet_pharmacy/app/modules/supplier/views/suppliers_view.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/inventory/bindings/inventory_binding.dart';
import '../modules/inventory/views/inventory_view.dart';
import '../modules/medicine/bindings/medicine_binding.dart';
import '../modules/medicine/views/add_medicine_view.dart';
import '../modules/medicine/views/edit_medicine_view.dart';
import '../modules/reports/bindings/reports_binding.dart';
import '../modules/reports/views/reports_view.dart';
import '../modules/sales/bindings/sales_binding.dart';
import '../modules/sales/views/sell_medicine_view.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.INVENTORY,
      page: () => InventoryView(),
      binding: InventoryBinding(),
    ),
    GetPage(
      name: Routes.ADD_MEDICINE,
      page: () => AddMedicineView(),
      binding: MedicineBinding(),
    ),
    GetPage(
      name: Routes.EDIT_MEDICINE,
      page: () => EditMedicineView(),
      binding: MedicineBinding(),
    ),
    GetPage(
      name: Routes.SALES,
      page: () => SellMedicineView(),
      binding: SalesBinding(),
    ),
    GetPage(
      name: Routes.REPORTS,
      page: () => ReportsView(),
      binding: ReportsBinding(),
    ),
    GetPage(
      name: Routes.SUPPLIERS,
      page: () => SuppliersView(),
      binding: SupplierBinding(),
    ),
    GetPage(
      name: Routes.SUPPLIER_DETAILS,
      page: () => SupplierDetailsView(),
      binding: SupplierBinding(),
    ),
  ];
}

