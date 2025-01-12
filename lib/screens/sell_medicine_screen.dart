import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/medicine.dart';
import '../models/sale.dart';
import '../models/customer.dart';
import '../services/database_helper.dart';
import 'barcode_scanner_screen.dart';

class SellMedicineScreen extends StatefulWidget {
  @override
  _SellMedicineScreenState createState() => _SellMedicineScreenState();
}

class _SellMedicineScreenState extends State<SellMedicineScreen> {
  List<SaleItem> cartItems = [];
  List<Medicine> selectedMedicines = [];
  Customer? selectedCustomer;

  final TextEditingController _medicineSearchController =
      TextEditingController();
  final TextEditingController _customerSearchController =
      TextEditingController();
  Timer? _medicineSearchDebounce;
  Timer? _customerSearchDebounce;

  @override
  void dispose() {
    _medicineSearchDebounce?.cancel();
    _customerSearchDebounce?.cancel();
    _medicineSearchController.dispose();
    _customerSearchController.dispose();
    super.dispose();
  }

  void _onMedicineSearchChanged(String query) {
    if (_medicineSearchDebounce?.isActive ?? false)
      _medicineSearchDebounce!.cancel();
    _medicineSearchDebounce =
        Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) return;

      final medicines = await DatabaseHelper.instance.searchMedicines(query);
      if (medicines.isNotEmpty) {
        _showMedicineResults(medicines);
      }
    });
  }

  void _showMedicineResults(List<Medicine> medicines) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('نتائج البحث'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final medicine = medicines[index];
              return ListTile(
                title: Text(medicine.name),
                subtitle: Text('السعر: ${medicine.price} جنيه'),
                onTap: () {
                  Navigator.pop(context);
                  _addMedicineToCart(medicine);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _onCustomerSearchChanged(String query) {
    if (_customerSearchDebounce?.isActive ?? false)
      _customerSearchDebounce!.cancel();
    _customerSearchDebounce =
        Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) return;

      final customers = await DatabaseHelper.instance.searchCustomers(query);
      _showCustomerResults(customers);
    });
  }

  void _showCustomerResults(List<Customer> customers) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('نتائج البحث'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text('إضافة عميل جديد'),
                onPressed: () {
                  Navigator.pop(context);
                  _addNewCustomer(_customerSearchController.text);
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return ListTile(
                      title: Text(customer.name),
                      subtitle:
                          customer.phone != null ? Text(customer.phone!) : null,
                      onTap: () {
                        setState(() => selectedCustomer = customer);
                        _customerSearchController.text = customer.name;
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addMedicineToCart(Medicine medicine) {
    setState(() {
      selectedMedicines.add(medicine);
      cartItems.add(SaleItem(
        medicineId: medicine.id!,
        quantity: 1,
        price: medicine.price,
      ));
      _medicineSearchController.clear();
    });
  }

  Future<void> _scanMedicine() async {
    print('مسح الباركود بدأ');
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => BarcodeScannerScreen()),
    );

    print('تم مسح الباركود: $barcode');

    if (barcode != null && barcode.isNotEmpty) {
      final medicine =
          await DatabaseHelper.instance.getMedicineByBarcode(barcode);
      if (medicine != null) {
        print('تم العثور على الدواء: ${medicine.name}');
        _addMedicineToCart(medicine);
      } else {
        print('لم يتم العثور على الدواء');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لم يتم العثور على الدواء لهذا الباركود')),
        );
      }
    }
  }

  Future<void> _addNewCustomer(String name) async {
    final nameController = TextEditingController(text: name);
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة عميل جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'اسم العميل'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'رقم الهاتف'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'العنوان'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('إلغاء'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: Text('حفظ'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (result == true) {
      final customer = Customer(
        name: nameController.text,
        phone: phoneController.text,
        address: addressController.text,
      );

      final id = await DatabaseHelper.instance.insertCustomer(customer);
      setState(() {
        selectedCustomer = Customer(
          id: id,
          name: customer.name,
          phone: customer.phone,
          address: customer.address,
        );
        _customerSearchController.text = customer.name;
      });
    }
  }

  Future<void> _completeSale() async {
    if (cartItems.isEmpty || selectedCustomer == null) return;

    final sale = Sale(
      customerId: selectedCustomer?.id,
      date: DateTime.now(),
      items: cartItems,
      total:
          cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity)),
    );

    await DatabaseHelper.instance.insertSale(sale);

    for (var i = 0; i < cartItems.length; i++) {
      final medicine = selectedMedicines[i];
      await DatabaseHelper.instance.updateMedicineQuantity(
        medicine.id!,
        medicine.quantity - cartItems[i].quantity,
      );
    }

    await _printInvoice(sale, selectedMedicines);
    Navigator.pop(context);
  }

  Future<void> _printInvoice(Sale sale, List<Medicine> medicines) async {
    try {
      final font = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
      final ttf = pw.Font.ttf(font);

      final pdf = pw.Document();

      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Container(
          padding: pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('الصيدلية البيطرية',
                  style: pw.TextStyle(font: ttf, fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Text('فاتورة بيع',
                  style: pw.TextStyle(font: ttf, fontSize: 20)),
              pw.Text('العميل: ${selectedCustomer!.name}',
                  style: pw.TextStyle(font: ttf)),
              if (selectedCustomer?.phone != null)
                pw.Text('رقم الهاتف: ${selectedCustomer!.phone}',
                    style: pw.TextStyle(font: ttf)),
              pw.Text(
                'التاريخ: ${DateFormat('dd/MM/yyyy').format(sale.date)}',
                style: pw.TextStyle(font: ttf),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Container(
                        alignment: pw.Alignment.center,
                        padding: pw.EdgeInsets.all(5),
                        child:
                            pw.Text('الدواء', style: pw.TextStyle(font: ttf)),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.center,
                        padding: pw.EdgeInsets.all(5),
                        child:
                            pw.Text('الكمية', style: pw.TextStyle(font: ttf)),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.center,
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('السعر', style: pw.TextStyle(font: ttf)),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.center,
                        padding: pw.EdgeInsets.all(5),
                        child:
                            pw.Text('الإجمالي', style: pw.TextStyle(font: ttf)),
                      ),
                    ],
                  ),
                  for (var i = 0; i < sale.items.length; i++)
                    pw.TableRow(
                      children: [
                        pw.Container(
                          alignment: pw.Alignment.center,
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(medicines[i].name,
                              style: pw.TextStyle(font: ttf)),
                        ),
                        pw.Container(
                          alignment: pw.Alignment.center,
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('${sale.items[i].quantity}',
                              style: pw.TextStyle(font: ttf)),
                        ),
                        pw.Container(
                          alignment: pw.Alignment.center,
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('${sale.items[i].price}',
                              style: pw.TextStyle(font: ttf)),
                        ),
                        pw.Container(
                          alignment: pw.Alignment.center,
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(
                            '${sale.items[i].quantity * sale.items[i].price}',
                            style: pw.TextStyle(font: ttf),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  'الإجمالي: ${sale.total} جنيه',
                  style: pw.TextStyle(font: ttf, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ));

      await Printing.sharePdf(bytes: await pdf.save());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إنشاء الفاتورة: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('بيع دواء')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _customerSearchController,
                  decoration: InputDecoration(
                    labelText: 'بحث/إضافة عميل',
                    prefixIcon: Icon(Icons.person_search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _onCustomerSearchChanged,
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _medicineSearchController,
                  decoration: InputDecoration(
                    labelText: 'بحث عن دواء',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _onMedicineSearchChanged,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: selectedMedicines.length,
              itemBuilder: (context, index) {
                final medicine = selectedMedicines[index];
                final item = cartItems[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: Image.file(File(medicine.image)),
                    title: Text(medicine.name),
                    subtitle: Text('السعر: ${medicine.price} جنيه'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            if (item.quantity > 1) {
                              setState(() {
                                cartItems[index] = SaleItem(
                                  medicineId: item.medicineId,
                                  quantity: item.quantity - 1,
                                  price: item.price,
                                );
                              });
                            }
                          },
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            if (item.quantity < medicine.quantity) {
                              setState(() {
                                cartItems[index] = SaleItem(
                                  medicineId: item.medicineId,
                                  quantity: item.quantity + 1,
                                  price: item.price,
                                );
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              selectedMedicines.removeAt(index);
                              cartItems.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                if (selectedCustomer != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'العميل: ${selectedCustomer!.name}',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                Text(
                  'الإجمالي: ${cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity))} جنيه',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.camera_alt),
                        label: Text('مسح باركود'),
                        onPressed: _scanMedicine,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.check),
                        label: Text('إتمام البيع'),
                        onPressed: cartItems.isNotEmpty ? _completeSale : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
