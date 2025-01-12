import 'dart:async';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:vet_pharmacy/screens/EditMedicineScreen.dart';
import 'package:vet_pharmacy/screens/add_medicine_screen.dart';
import '../services/database_helper.dart';
import '../models/medicine.dart';

class InventoryScreen extends StatefulWidget {
 @override
 _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
 String _searchQuery = '';
 Timer? _debounce;

 @override
 void dispose() {
   _debounce?.cancel();
   super.dispose();
 }

 void _onSearchChanged(String query) {
   if (_debounce?.isActive ?? false) _debounce!.cancel();
   _debounce = Timer(const Duration(milliseconds: 500), () {
     setState(() {
       _searchQuery = query;
     });
   });
 }

 Future<void> _deleteMedicine(Medicine medicine) async {
   final confirmed = await showDialog<bool>(
     context: context,
     builder: (context) => AlertDialog(
       title: Text('تأكيد الحذف'),
       content: Text('هل أنت متأكد من حذف ${medicine.name}؟'),
       actions: [
         TextButton(
           child: Text('إلغاء'),
           onPressed: () => Navigator.pop(context, false),
         ),
         TextButton(
           style: TextButton.styleFrom(foregroundColor: Colors.red),
           child: Text('حذف'),
           onPressed: () => Navigator.pop(context, true),
         ),
       ],
     ),
   );

   if (confirmed == true) {
     await DatabaseHelper.instance.deleteMedicine(medicine.id!);
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('تم حذف ${medicine.name}')),
     );
     setState(() {});
   }
 }

 void _editMedicine(Medicine medicine) async {
   final result = await Navigator.push(
     context,
     MaterialPageRoute(
       builder: (_) => EditMedicineScreen(medicine: medicine),
     ),
   );

   if (result == true) {
     setState(() {});
   }
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text('المخزون'),
       actions: [
         IconButton(
           icon: Icon(Icons.picture_as_pdf),
           onPressed: () => _generateInventoryReport(),
         ),
       ],
     ),
     body: Column(
       children: [
         Padding(
           padding: EdgeInsets.all(8),
           child: TextField(
             decoration: InputDecoration(
               hintText: 'بحث عن دواء...',
               prefixIcon: Icon(Icons.search),
               border: OutlineInputBorder(),
             ),
             onChanged: _onSearchChanged,
           ),
         ),
         Expanded(
           child: FutureBuilder<List<Medicine>>(
             future: DatabaseHelper.instance.searchMedicines(_searchQuery),
             builder: (context, snapshot) {
               if (snapshot.connectionState == ConnectionState.waiting) {
                 return Center(child: CircularProgressIndicator());
               }
   
               if (!snapshot.hasData || snapshot.data!.isEmpty) {
                 return Center(child: Text('لا يوجد أدوية في المخزون'));
               }
   
               return ListView.builder(
                 itemCount: snapshot.data!.length,
                 itemBuilder: (context, index) {
                   final medicine = snapshot.data![index];
                   final daysUntilExpiry = medicine.expiryDate != null
                       ? medicine.expiryDate!.difference(DateTime.now()).inDays
                       : null;
   
                   return Card(
                     margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                     child: ListTile(
                       leading: medicine.image != null
                           ? CircleAvatar(
                               backgroundImage: FileImage(File(medicine.image!)),
                             )
                           : CircleAvatar(child: Icon(Icons.medication)),
                       title: Text(medicine.name),
                       subtitle: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text('الكمية: ${medicine.quantity}'),
                           Text('السعر: ${medicine.price} جنيه'),
                           if (daysUntilExpiry != null)
                             Text(
                               'تاريخ الانتهاء: ${DateFormat('dd/MM/yyyy').format(medicine.expiryDate!)}',
                               style: TextStyle(
                                 color: daysUntilExpiry <= 30 ? Colors.red : null,
                               ),
                             ),
                         ],
                       ),
                       trailing: Row(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           IconButton(
                             icon: Icon(Icons.edit),
                             onPressed: () => _editMedicine(medicine),
                           ),
                           IconButton(
                             icon: Icon(Icons.delete),
                             color: Colors.red,
                             onPressed: () => _deleteMedicine(medicine),
                           ),
                         ],
                       ),
                     ),
                   );
                 },
               );
             },
           ),
         ),
       ],
     ),
     floatingActionButton: FloatingActionButton(
       child: Icon(Icons.add),
       onPressed: () async {
         final result = await Navigator.push(
           context,
           MaterialPageRoute(builder: (_) => AddMedicineScreen()),
         );
         if (result == true) {
           setState(() {});
         }
       },
     ),
   );
 }

 Future<void> _generateInventoryReport() async {
   try {
     final font = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
     final ttf = pw.Font.ttf(font);
     final medicines = await DatabaseHelper.instance.getAllMedicines();

     final pdf = pw.Document();
     
     pdf.addPage(pw.Page(
       pageFormat: PdfPageFormat.a4,
       build: (context) => pw.Directionality(
         textDirection: pw.TextDirection.rtl,
         child: pw.Column(
           children: [
             pw.Text('تقرير المخزون', style: pw.TextStyle(font: ttf, fontSize: 24)),
             pw.SizedBox(height: 20),
             pw.Table(
               border: pw.TableBorder.all(),
               children: [
                 pw.TableRow(
                   children: [
                     pw.Text('الدواء', style: pw.TextStyle(font: ttf)),
                     pw.Text('الكمية', style: pw.TextStyle(font: ttf)),
                     pw.Text('السعر', style: pw.TextStyle(font: ttf)),
                     pw.Text('تاريخ الانتهاء', style: pw.TextStyle(font: ttf)),
                   ],
                 ),
                 for (var medicine in medicines)
                   pw.TableRow(
                     children: [
                       pw.Text(medicine.name, style: pw.TextStyle(font: ttf)),
                       pw.Text('${medicine.quantity}', style: pw.TextStyle(font: ttf)),
                       pw.Text('${medicine.price}', style: pw.TextStyle(font: ttf)),
                       pw.Text(
                         medicine.expiryDate != null 
                           ? DateFormat('dd/MM/yyyy').format(medicine.expiryDate!)
                           : '-',
                         style: pw.TextStyle(font: ttf),
                       ),
                     ],
                   ),
               ],
             ),
           ],
         ),
       ),
     ));

     await Printing.sharePdf(bytes: await pdf.save());
   } catch (e) {
     print('Error generating report: $e');
   }
 }
}