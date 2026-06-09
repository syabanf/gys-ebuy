import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/format.dart';
import '../../core/mock_api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/notif_bell.dart';
import '../../core/widgets/app_switcher.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _api = MockApi();
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _api.listOrders().then((data) {
      if (!mounted) return;
      setState(() {
        _orders = data;
        _loading = false;
      });
    });
  }

  int get _activeOrders => _orders.where((o) => !['completed', 'delivered', 'cancelled'].contains(o['status'])).length;
  num get _totalSpent => _orders.where((o) => o['status'] != 'cancelled').fold<num>(0, (s, o) => s + (o['total'] as num));
  int get _awaitingPayment => _orders.where((o) => o['status'] == 'pending_payment').length;

  // Synthesized 6-month spending series anchored on total spend.
  List<double> get _spending {
    final base = (_totalSpent == 0 ? 20000000 : _totalSpent).toDouble();
    const factors = [0.35, 0.5, 0.45, 0.7, 0.82, 1.0];
    return factors.map((f) => base * f).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        actions: const [AppSwitcherButton(), NotifBell()],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: GysColors.brand500))
          : RefreshIndicator(
              color: GysColors.brand500,
              onRefresh: () async {
                final data = await _api.listOrders();
                if (mounted) setState(() => _orders = data);
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _greeting(),
                  const SizedBox(height: 16),
                  _summaryCards(),
                  const SizedBox(height: 20),
                  _spendingChart(),
                  const SizedBox(height: 20),
                  _quickActions(),
                  const SizedBox(height: 20),
                  _pointsCard(),
                  const SizedBox(height: 20),
                  _recentOrders(),
                ],
              ),
            ),
    );
  }

  Widget _greeting() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [GysColors.brand500, GysColors.brand700], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Selamat datang,', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 2),
          const Text('PT Karya Konstruksi Nusantara', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text('Total belanja: ${formatIDR(_totalSpent)}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCards() {
    return Row(
      children: [
        _statCard('Pesanan Aktif', '$_activeOrders', Icons.local_shipping_outlined, GysColors.info),
        const SizedBox(width: 10),
        _statCard('Menunggu Bayar', '$_awaitingPayment', Icons.payment_outlined, GysColors.warning),
        const SizedBox(width: 10),
        _statCard('Total Pesanan', '${_orders.length}', Icons.receipt_long_outlined, GysColors.brand500),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: GysColors.neutral200)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: GysColors.neutral900)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: GysColors.neutral500), maxLines: 2),
          ],
        ),
      ),
    );
  }

  Widget _spendingChart() {
    final data = _spending;
    final maxY = (data.reduce((a, b) => a > b ? a : b)) * 1.2;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: GysColors.neutral200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Belanja 6 Bulan Terakhir', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: GysColors.neutral900)),
          const SizedBox(height: 4),
          Text('Total ${formatIDR(_totalSpent)}', style: const TextStyle(fontSize: 12, color: GysColors.neutral500)),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barTouchData: BarTouchData(enabled: false),
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxY / 2, getDrawingHorizontalLine: (_) => const FlLine(color: GysColors.neutral200, strokeWidth: 1, dashArray: [4, 4])),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= months.length) return const SizedBox.shrink();
                        return Padding(padding: const EdgeInsets.only(top: 6), child: Text(months[i], style: const TextStyle(fontSize: 11, color: GysColors.neutral500)));
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(data.length, (i) {
                  final isLast = i == data.length - 1;
                  return BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                      toY: data[i],
                      color: isLast ? GysColors.brand500 : GysColors.brand200,
                      width: 18,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                    ),
                  ]);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pointsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F6837), Color(0xFF052E18)], begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.workspace_premium_outlined, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('GYS Points', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: const [
                    Text('1.250', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                    SizedBox(width: 4),
                    Text('poin', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            child: const Text('Tukar'),
          ),
        ],
      ),
    );
  }

  Widget _quickActions() {
    final actions = [
      (Icons.storefront_outlined, 'Belanja', '/catalog'),
      (Icons.receipt_long_outlined, 'Pesanan', '/orders'),
      (Icons.location_on_outlined, 'Alamat', '/addresses'),
      (Icons.headset_mic_outlined, 'Bantuan', null),
    ];
    return Row(
      children: actions.map((a) {
        return Expanded(
          child: GestureDetector(
            onTap: () { if (a.$3 != null) context.push(a.$3!); },
            child: Column(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(color: GysColors.brand50, borderRadius: BorderRadius.circular(14)),
                  child: Icon(a.$1, color: GysColors.brand700, size: 24),
                ),
                const SizedBox(height: 6),
                Text(a.$2, style: const TextStyle(fontSize: 12, color: GysColors.neutral700, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _recentOrders() {
    final recent = _orders.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Pesanan Terbaru', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: GysColors.neutral900)),
            TextButton(onPressed: () => context.go('/orders'), child: const Text('Lihat semua')),
          ],
        ),
        const SizedBox(height: 4),
        ...recent.map((o) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: GysColors.neutral200)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o['orderNumber'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('${o['items']} item · ${OrderStatusInfo.label(o['status'] as String)}', style: const TextStyle(fontSize: 12, color: GysColors.neutral500)),
                      ],
                    ),
                  ),
                  Text(formatIDR(o['total'] as num), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: GysColors.brand700)),
                ],
              ),
            )),
      ],
    );
  }
}
