import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/cart_state.dart';
import '../../core/format.dart';
import '../../core/theme/app_colors.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cart = CartState();

  @override
  void initState() {
    super.initState();
    _cart.addListener(_onChanged);
  }

  @override
  void dispose() {
    _cart.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final items = _cart.items;
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, color: GysColors.neutral400, size: 64),
                    const SizedBox(height: 16),
                    const Text('Keranjang masih kosong', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    const Text('Jelajahi katalog dan tambahkan produk yang Anda butuhkan.', textAlign: TextAlign.center, style: TextStyle(color: GysColors.neutral500, fontSize: 13)),
                    const SizedBox(height: 20),
                    OutlinedButton(onPressed: () => context.pop(), child: const Text('Kembali ke Katalog')),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final item = items[i];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: GysColors.neutral200)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(color: GysColors.brand50, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.layers_outlined, color: GysColors.brand700, size: 24),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text('${formatIDR(item.unitPrice)} / ${item.uom}', style: const TextStyle(color: GysColors.neutral500, fontSize: 12)),
                              ],
                            ),
                          ),
                          IconButton(onPressed: () => _cart.remove(item.productId), icon: const Icon(Icons.delete_outline, color: GysColors.neutral400)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _QtyControl(qty: item.qty, onChange: (q) => _cart.updateQty(item.productId, q)),
                          const Spacer(),
                          Text(formatIDR(item.subtotal), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: GysColors.brand700)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomSheet: items.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: GysColors.neutral200))),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal (${"belum termasuk ongkir"})', style: TextStyle(fontSize: 12, color: GysColors.neutral500)),
                        Text(formatIDR(_cart.subtotal), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: GysColors.neutral900)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(onPressed: () => context.push('/checkout'), child: const Text('Lanjut ke Checkout')),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  final int qty;
  final ValueChanged<int> onChange;
  const _QtyControl({required this.qty, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: GysColors.neutral200), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.remove, size: 18), color: GysColors.brand700, onPressed: () => onChange(qty - 1), constraints: const BoxConstraints(minWidth: 36, minHeight: 36), padding: EdgeInsets.zero),
          SizedBox(width: 36, child: Text('$qty', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700))),
          IconButton(icon: const Icon(Icons.add, size: 18), color: GysColors.brand700, onPressed: () => onChange(qty + 1), constraints: const BoxConstraints(minWidth: 36, minHeight: 36), padding: EdgeInsets.zero),
        ],
      ),
    );
  }
}
