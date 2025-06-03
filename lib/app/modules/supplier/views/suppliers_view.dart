// lib/app/modules/supplier/views/suppliers_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/supplier_controller.dart';
import '../../../data/models/supplier.dart';

class SuppliersView extends GetView<SupplierController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'المناديب',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Colors.grey[50]!,
                  ],
                  stops: [0.0, 0.3],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryCards(),
                    SizedBox(height: 16),
                    _buildSuppliersList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSummaryCards() {
    return Obx(() {
      if (controller.suppliers.isEmpty) {
        return _buildEmptyStateCard();
      }

      return Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              title: 'إجمالي المناديب',
              value: '${controller.suppliers.length}',
              icon: Icons.people,
              color: Colors.blue,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: FutureBuilder<double>(
              future: _calculateTotalRemaining(),
              builder: (context, snapshot) {
                return _buildSummaryCard(
                  title: 'إجمالي المستحقات',
                  value: snapshot.hasData
                      ? '${snapshot.data!.toStringAsFixed(0)} جنيه'
                      : '...',
                  icon: Icons.account_balance_wallet,
                  color: Colors.orange,
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: color,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'لا يوجد مناديب',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'ابدأ بإضافة أول مندوب لك',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddSupplierDialog(),
            icon: Icon(Icons.add),
            label: Text('إضافة مندوب'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuppliersList() {
    return Obx(() {
      if (controller.suppliers.isEmpty) {
        return SizedBox.shrink();
      }

      return Column(
        children: controller.suppliers.map((supplier) {
          return _buildSupplierCard(supplier);
        }).toList(),
      );
    });
  }

  Widget _buildSupplierCard(Supplier supplier) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(
            '/SUPPLIER_DETAILS',
            arguments: supplier,
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withOpacity(0.8),
                        Colors.blue,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplier.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      if (supplier.phone != null && supplier.phone!.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            SizedBox(width: 4),
                            Text(
                              supplier.phone!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      if (supplier.address != null &&
                          supplier.address!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  supplier.address!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Summary Info
                FutureBuilder<Map<String, dynamic>>(
                  future: controller.getSupplierSummary(supplier.id!),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }

                    final data = snapshot.data!;
                    final remainingAmount = data['remaining_amount'] ?? 0.0;
                    final medicineCount = data['medicine_count'] ?? 0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: remainingAmount > 0
                                ? Colors.red.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${(remainingAmount as num).toStringAsFixed(0)} جنيه',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: remainingAmount > 0
                                  ? Colors.red[700]
                                  : Colors.green[700],
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.medical_services,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            SizedBox(width: 4),
                            Text(
                              '$medicineCount',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue,
            Colors.blue.withOpacity(0.8),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(Icons.add, size: 28),
        onPressed: () => _showAddSupplierDialog(),
      ),
    );
  }

  void _showAddSupplierDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final notesController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_add,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'إضافة مندوب جديد',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Form Fields
              _buildTextField(
                controller: nameController,
                label: 'اسم المندوب',
                icon: Icons.person,
                isRequired: true,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: phoneController,
                label: 'رقم الهاتف',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: addressController,
                label: 'العنوان',
                icon: Icons.location_on,
                maxLines: 2,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: notesController,
                label: 'ملاحظات',
                icon: Icons.note,
                maxLines: 2,
              ),

              SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty) {
                          controller.addSupplier(Supplier(
                            name: nameController.text,
                            phone: phoneController.text,
                            address: addressController.text,
                            notes: notesController.text,
                          ));
                          Get.back();
                        } else {
                          Get.snackbar(
                            'تنبيه',
                            'يرجى إدخال اسم المندوب',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.blue,
                      ),
                      child: Text(
                        'إضافة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          prefixIcon: Icon(
            icon,
            color: Colors.blue,
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Future<double> _calculateTotalRemaining() async {
    double total = 0.0;
    for (var supplier in controller.suppliers) {
      final summary = await controller.getSupplierSummary(supplier.id!);
      total += summary['remaining_amount'] ?? 0.0;
    }
    return total;
  }
}

// // lib/app/modules/supplier/views/suppliers_view.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/supplier_controller.dart';
// import '../../../data/models/supplier.dart';

// class SuppliersView extends GetView<SupplierController> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('المناديب'),
//         centerTitle: true,
//       ),
//       body: Obx(() => ListView.builder(
//             itemCount: controller.suppliers.length,
//             itemBuilder: (context, index) {
//               final supplier = controller.suppliers[index];
//               return Card(
//                 margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: ListTile(
//                   title: Text(supplier.name),
//                   subtitle:
//                       supplier.phone != null ? Text(supplier.phone!) : null,
//                   trailing: FutureBuilder<Map<String, dynamic>>(
//                     future: controller.getSupplierSummary(supplier.id!),
//                     builder: (context, snapshot) {
//                       if (!snapshot.hasData) {
//                         return CircularProgressIndicator();
//                       }

//                       final data = snapshot.data!;
//                       // تحقق من القيم واستخدام قيم افتراضية في حالة null
//                       final remainingAmount = data['remaining_amount'] ?? 0.0;
//                       final medicineCount = data['medicine_count'] ?? 0;

//                       return Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                               'الباقي: ${(remainingAmount as num).toStringAsFixed(2)} جنيه'),
//                           Text('عدد الأدوية: $medicineCount'),
//                         ],
//                       );
//                     },
//                   ),
//                   onTap: () => Get.toNamed(
//                     '/SUPPLIER_DETAILS',
//                     arguments: supplier,
//                   ),
//                 ),
//               );
//             },
//           )),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.add),
//         onPressed: () => _showAddSupplierDialog(context),
//       ),
//     );
//   }

//   void _showAddSupplierDialog(BuildContext context) {
//     final nameController = TextEditingController();
//     final phoneController = TextEditingController();
//     final addressController = TextEditingController();

//     Get.dialog(
//       AlertDialog(
//         title: Text('إضافة مندوب جديد'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: nameController,
//                 decoration: InputDecoration(
//                   labelText: 'اسم المندوب',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               SizedBox(height: 16),
//               TextField(
//                 controller: phoneController,
//                 decoration: InputDecoration(
//                   labelText: 'رقم الهاتف',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.phone,
//               ),
//               SizedBox(height: 16),
//               TextField(
//                 controller: addressController,
//                 decoration: InputDecoration(
//                   labelText: 'العنوان',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 2,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             child: Text('إلغاء'),
//             onPressed: () => Get.back(),
//           ),
//           ElevatedButton(
//             child: Text('إضافة'),
//             onPressed: () {
//               if (nameController.text.isNotEmpty) {
//                 controller.addSupplier(Supplier(
//                   name: nameController.text,
//                   phone: phoneController.text,
//                   address: addressController.text,
//                 ));
//                 Get.back();
//               } else {
//                 Get.snackbar(
//                   'تنبيه',
//                   'يرجى إدخال اسم المندوب',
//                   snackPosition: SnackPosition.BOTTOM,
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
