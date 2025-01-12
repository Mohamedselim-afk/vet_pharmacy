import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import 'add_medicine_screen.dart';
import 'inventory_screen.dart';
import 'reports_screen.dart';
import 'sell_medicine_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _stats;

  @override
  void initState() {
    super.initState();
    _stats = _loadStats();
  }

  Future<Map<String, dynamic>> _loadStats() async {
    final db = DatabaseHelper.instance;
    final medicines = await db.getAllMedicines();
    final today = DateTime.now();
    final dailySales = await db.getDailySalesReport(today);
    final uniqueMedicines = medicines.length;
    final totalQuantity = medicines.fold(0, (sum, med) => sum + med.quantity);

    return {
      'total_medicines': uniqueMedicines,
      'total_quantity': totalQuantity,
      'daily_sales':
          dailySales.isNotEmpty ? dailySales.first['total_amount'] ?? 0.0 : 0.0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: AppBar(
            title: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'صيدلية أحمد فخر البيطرية',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Divider(
                    color: Colors.white,
                    thickness: 1,
                    indent: 80,
                    endIndent: 80,
                  ),
                ],
              ),
            ),
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 0,
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Theme.of(context).primaryColor, Colors.black12],
              stops: [0.0, 0.3],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                FutureBuilder<Map<String, dynamic>>(
                  future: _stats,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final stats = snapshot.data!;
                    return Row(
                      children: [
                        _buildStatCard(
                          context,
                          'عدد الأصناف',
                          '${stats['total_medicines']}',
                          Icons.category,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          context,
                          'إجمالي الأدوية',
                          '${stats['total_quantity']}',
                          Icons.medical_services,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          context,
                          'مبيعات اليوم',
                          '${stats['daily_sales'].toStringAsFixed(2)} جنيه',
                          Icons.payments,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _MenuCard(
                        title: 'إضافة دواء',
                        icon: Icons.add_box,
                        color: Colors.blue,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => AddMedicineScreen()),
                        ),
                      ),
                      _MenuCard(
                        title: 'بيع دواء',
                        icon: Icons.point_of_sale,
                        color: Colors.green,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => SellMedicineScreen()),
                        ),
                      ),
                      _MenuCard(
                        title: 'المخزون',
                        icon: Icons.inventory,
                        color: Colors.orange,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => InventoryScreen()),
                        ),
                      ),
                      _MenuCard(
                        title: 'التقارير',
                        icon: Icons.bar_chart,
                        color: Colors.purple,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ReportsScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.8), color],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
