import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/format.dart';
import '../../core/mock_api.dart';
import '../../core/theme/app_colors.dart';

class OrderDetailScreen extends StatefulWidget {
  final String id;
  const OrderDetailScreen({super.key, required this.id});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _api = MockApi();
  Map<String, dynamic>? _order;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _api.listOrders().then((orders) {
      if (!mounted) return;
      setState(() {
        _order = orders.firstWhere((o) => o['id'] == widget.id, orElse: () => {});
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: GysColors.brand500)));
    final o = _order;
    if (o == null || o.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pesanan tidak ditemukan')),
        body: Center(child: ElevatedButton(onPressed: () => context.pop(), child: const Text('Kembali'))),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(o['orderNumber'] as String)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: GysColors.brand50, borderRadius: BorderRadius.circular(12), border: Border.all(color: GysColors.brand200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(OrderStatusInfo.label(o['status'] as String), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: GysColors.brand700)),
                  const SizedBox(height: 4),
                  Text('Dipesan ${formatDateTime(DateTime.parse(o['placedAt'] as String))}', style: const TextStyle(fontSize: 12, color: GysColors.neutral500)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Riwayat Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _Timeline(status: o['status'] as String),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: GysColors.neutral200)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Jumlah item', style: TextStyle(color: GysColors.neutral500)),
                      Text('${o['items']} item'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(color: GysColors.neutral500)),
                      Text(formatIDR(o['total'] as num), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GysColors.brand700)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (o['status'] == 'shipped')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan dikonfirmasi diterima.'), backgroundColor: GysColors.success));
                  },
                  child: const Text('Konfirmasi Pesanan Diterima'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final String status;
  const _Timeline({required this.status});

  static const _steps = [
    ('placed', 'Pesanan Dibuat'),
    ('paid', 'Pembayaran Diterima'),
    ('shipped', 'Dikirim'),
    ('delivered', 'Terkirim'),
    ('completed', 'Selesai'),
  ];

  int _activeIndex() {
    return switch (status) {
      'pending_payment' => 0,
      'paid' || 'accepted_by_distributor' || 'in_fulfillment' => 1,
      'shipped' => 2,
      'delivered' => 3,
      'completed' => 4,
      _ => -1,
    };
  }

  @override
  Widget build(BuildContext context) {
    final activeIdx = _activeIndex();
    return Column(
      children: List.generate(_steps.length, (i) {
        final done = i <= activeIdx;
        final isLast = i == _steps.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    height: 22,
                    width: 22,
                    decoration: BoxDecoration(color: done ? GysColors.brand500 : GysColors.neutral200, shape: BoxShape.circle),
                    child: done ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                  ),
                  if (!isLast)
                    Expanded(child: Container(width: 2, color: done ? GysColors.brand500 : GysColors.neutral200)),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 18, top: 1),
                  child: Text(_steps[i].$2, style: TextStyle(fontSize: 14, color: done ? GysColors.neutral900 : GysColors.neutral500, fontWeight: done ? FontWeight.w600 : FontWeight.w400)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
