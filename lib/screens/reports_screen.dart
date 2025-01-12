// lib/screens/reports_screen.dart
import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('التقارير'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'المبيعات'),
              Tab(text: 'المخزون'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SalesReportTab(),
            _InventoryReportTab(),
          ],
        ),
      ),
    );
  }
}

class _SalesReportTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.instance.getDailySalesReport(DateTime.now()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('لا توجد مبيعات'));
        }

        final dailySales = snapshot.data!;

        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ملخص المبيعات اليومية',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'عدد المبيعات: ${dailySales[0]['total_sales']}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'إجمالي المبيعات: ${dailySales[0]['total_amount']} جنيه',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.picture_as_pdf),
              label: Text('تصدير التقرير'),
              onPressed: () {
                // TODO: تنفيذ تصدير التقرير
              },
            ),
          ],
        );
      },
    );
  }
}

class _InventoryReportTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.instance.getTopSellingMedicines(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('لا توجد بيانات'));
        }

        final topSelling = snapshot.data!;

        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الأدوية الأكثر مبيعاً',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    for (var medicine in topSelling)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(medicine['name']),
                            Text('${medicine['total_quantity']} قطعة'),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.picture_as_pdf),
              label: Text('تصدير التقرير'),
              onPressed: () {
                // TODO: تنفيذ تصدير التقرير
              },
            ),
          ],
        );
      },
    );
  }
}