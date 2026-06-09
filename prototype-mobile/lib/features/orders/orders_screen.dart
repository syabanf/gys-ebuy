import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/format.dart';
import '../../core/mock_api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_switcher.dart';
import '../../core/widgets/skeleton.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _api = MockApi();
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;
  String _filter = 'all';

  static const _filters = [
    ('all', 'Semua'),
    ('pending_payment', 'Menunggu Bayar'),
    ('processing', 'Diproses'),
    ('shipped', 'Dikirim'),
    ('done', 'Selesai'),
  ];

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

  bool _matches(Map<String, dynamic> o) {
    final s = o['status'] as String;
    return switch (_filter) {
      'all' => true,
      'processing' => ['paid', 'accepted_by_distributor', 'in_fulfillment'].contains(s),
      'done' => ['delivered', 'completed'].contains(s),
      _ => s == _filter,
    };
  }

  List<Map<String, dynamic>> get _filtered => _orders.where(_matches).toList();
  int get _active => _orders.where((o) => !['completed', 'delivered', 'cancelled'].contains(o['status'])).length;
  int get _done => _orders.where((o) => ['completed', 'delivered'].contains(o['status'])).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan Saya'), actions: const [AppSwitcherButton()]),
      body: _loading
          ? ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, _) => const SkeletonListCard(),
            )
          : Column(
              children: [
                // Summary cards
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      _miniStat('Aktif', '$_active', GysColors.info),
                      const SizedBox(width: 10),
                      _miniStat('Selesai', '$_done', GysColors.success),
                      const SizedBox(width: 10),
                      _miniStat('Total', '${_orders.length}', GysColors.brand500),
                    ],
                  ),
                ),
                // Filter chips
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: _filters.map((f) {
                      final selected = _filter == f.$1;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(f.$2),
                          selected: selected,
                          onSelected: (_) => setState(() => _filter = f.$1),
                          backgroundColor: Colors.white,
                          selectedColor: GysColors.brand500,
                          labelStyle: TextStyle(color: selected ? Colors.white : GysColors.neutral700, fontWeight: FontWeight.w600, fontSize: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: selected ? GysColors.brand500 : GysColors.neutral200)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: _filtered.isEmpty
                      ? const Center(child: Text('Tidak ada pesanan pada filter ini.', style: TextStyle(color: GysColors.neutral500)))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final o = _filtered[i];
                            return InkWell(
                              onTap: () => context.push('/orders/${o['id']}'),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: GysColors.neutral200)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(o['orderNumber'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                                        const Spacer(),
                                        _StatusBadge(status: o['status'] as String),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text('${o['items']} item · ${formatDateTime(DateTime.parse(o['placedAt'] as String))}', style: const TextStyle(fontSize: 12, color: GysColors.neutral500)),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Total', style: TextStyle(fontSize: 12, color: GysColors.neutral500)),
                                        Text(formatIDR(o['total'] as num), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: GysColors.brand700)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: GysColors.neutral200)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12, color: GysColors.neutral500)),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final tone = switch (status) {
      'pending_payment' => (bg: const Color(0xFFFEF3C7), fg: const Color(0xFF92400E)),
      'paid' || 'accepted_by_distributor' || 'in_fulfillment' => (bg: const Color(0xFFDBEAFE), fg: const Color(0xFF1E40AF)),
      'shipped' => (bg: GysColors.brand50, fg: GysColors.brand700),
      'delivered' || 'completed' => (bg: const Color(0xFFDCFCE7), fg: const Color(0xFF166534)),
      'cancelled' => (bg: const Color(0xFFFEE2E2), fg: const Color(0xFF991B1B)),
      _ => (bg: GysColors.neutral100, fg: GysColors.neutral700),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: tone.bg, borderRadius: BorderRadius.circular(20)),
      child: Text(OrderStatusInfo.label(status), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: tone.fg)),
    );
  }
}
