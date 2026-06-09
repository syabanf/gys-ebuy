import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/cart_state.dart';
import '../../core/format.dart';
import '../../core/theme/app_colors.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _method = 'va_bca';
  bool _processing = false;
  Timer? _timer;
  int _remaining = 3 * 3600; // 3 hours in seconds

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() { if (_remaining > 0) _remaining--; });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _countdown {
    final h = (_remaining ~/ 3600).toString().padLeft(2, '0');
    final m = ((_remaining % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  static const _methods = [
    ('va_bca', 'Virtual Account BCA', 'IDR 4.000 / transaksi'),
    ('va_mandiri', 'Virtual Account Mandiri', 'IDR 4.000 / transaksi'),
    ('qris', 'QRIS', '0.7% MDR'),
    ('credit_card', 'Kartu Kredit', '2.9% MDR'),
  ];

  Future<void> _pay() async {
    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final orderNumber = 'GYS-2026-${(125 + DateTime.now().millisecondsSinceEpoch % 100).toString().padLeft(6, '0')}';
    CartState().clear();
    context.go('/order-confirmation/$orderNumber');
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartState();
    const shipping = 250000;
    final total = cart.subtotal + shipping;

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                      const Text('Total Pembayaran', style: TextStyle(fontSize: 13, color: GysColors.brand700, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(formatIDR(total), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: GysColors.brand700)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 15, color: GysColors.warning),
                          const SizedBox(width: 5),
                          const Text('Selesaikan dalam ', style: TextStyle(fontSize: 12, color: GysColors.neutral500)),
                          Text(_countdown, style: const TextStyle(fontSize: 13, color: GysColors.warning, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Pilih Metode Pembayaran', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: GysColors.neutral900)),
                const SizedBox(height: 12),
                ..._methods.map((m) {
                  final selected = _method == m.$1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => setState(() => _method = m.$1),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selected ? GysColors.brand50 : Colors.white,
                          border: Border.all(color: selected ? GysColors.brand500 : GysColors.neutral200, width: selected ? 2 : 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(color: GysColors.neutral100, borderRadius: BorderRadius.circular(8)),
                              child: Icon(_iconFor(m.$1), color: GysColors.brand700, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(m.$2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: GysColors.neutral900)),
                                  Text(m.$3, style: const TextStyle(fontSize: 12, color: GysColors.neutral500)),
                                ],
                              ),
                            ),
                            Icon(selected ? Icons.check_circle : Icons.radio_button_off, color: selected ? GysColors.brand500 : GysColors.neutral400, size: 22),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: GysColors.neutral100, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: const [
                      Icon(Icons.shield_outlined, color: GysColors.neutral500, size: 18),
                      SizedBox(width: 8),
                      Expanded(child: Text('Pembayaran diproses oleh Midtrans · keamanan PCI-DSS', style: TextStyle(fontSize: 12, color: GysColors.neutral500))),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          if (_processing)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: GysColors.brand500),
                        SizedBox(height: 16),
                        Text('Memproses pembayaran…', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: GysColors.neutral200))),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _processing ? null : _pay,
              child: Text('Bayar Sekarang · ${formatIDR(total)}'),
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String method) {
    return switch (method) {
      'va_bca' || 'va_mandiri' => Icons.account_balance_outlined,
      'qris' => Icons.qr_code_2,
      'credit_card' => Icons.credit_card_outlined,
      _ => Icons.payment,
    };
  }
}
