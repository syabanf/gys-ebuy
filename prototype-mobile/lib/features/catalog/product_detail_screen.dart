import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/cart_state.dart';
import '../../core/format.dart';
import '../../core/mock_api.dart';
import '../../core/theme/app_colors.dart';

class ProductDetailScreen extends StatefulWidget {
  final String id;
  const ProductDetailScreen({super.key, required this.id});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _api = MockApi();
  Map<String, dynamic>? _product;
  bool _loading = true;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _api.getProduct(widget.id).then((p) {
      if (!mounted) return;
      setState(() {
        _product = p;
        _loading = false;
      });
    });
  }

  void _addToCart() {
    CartState().add(_product!, qty: _qty);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_qty × ${_product!['name']} ditambahkan ke keranjang'),
        backgroundColor: GysColors.brand700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: GysColors.brand500)));
    }
    final p = _product!;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              color: GysColors.brand50,
              child: const Center(
                child: Icon(Icons.layers_outlined, color: GysColors.brand700, size: 96),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SKU ${p['sku']}', style: const TextStyle(fontSize: 12, color: GysColors.neutral500, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                  const SizedBox(height: 6),
                  Text(p['name'] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: GysColors.neutral900)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(formatIDR(p['centralPrice'] as num), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: GysColors.brand700)),
                      const SizedBox(width: 6),
                      Text('/ ${p['uom']}', style: const TextStyle(fontSize: 14, color: GysColors.neutral500)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: GysColors.neutral100, borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      children: [
                        Icon(Icons.local_shipping_outlined, color: GysColors.brand700, size: 20),
                        SizedBox(width: 8),
                        Expanded(child: Text('Tersedia di 2 distributor · lead time 2-4 hari', style: TextStyle(fontSize: 13, color: GysColors.neutral700))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Spesifikasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: GysColors.neutral900)),
                  const SizedBox(height: 12),
                  _SpecRow(label: 'Satuan', value: p['uom'] as String),
                  _SpecRow(label: 'Kategori', value: 'Steel Construction'),
                  _SpecRow(label: 'Grade', value: 'SNI / BjTS'),
                  _SpecRow(label: 'Minimum Order', value: '1 ${p['uom']}'),
                  const SizedBox(height: 28),
                  const Text('Jumlah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: GysColors.neutral900)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _QtyBtn(icon: Icons.remove, onTap: () => setState(() => _qty = (_qty - 1).clamp(1, 9999))),
                      Container(
                        width: 70,
                        alignment: Alignment.center,
                        child: Text('$_qty', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                      ),
                      _QtyBtn(icon: Icons.add, onTap: () => setState(() => _qty++)),
                      const SizedBox(width: 12),
                      Text(p['uom'] as String, style: const TextStyle(fontSize: 14, color: GysColors.neutral500)),
                      const Spacer(),
                      Text('Subtotal:', style: TextStyle(fontSize: 12, color: GysColors.neutral500)),
                      const SizedBox(width: 6),
                      Text(formatIDR((p['centralPrice'] as num) * _qty), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: GysColors.brand700)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: GysColors.neutral200)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _addToCart,
                  child: const Text('+ Keranjang'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () { _addToCart(); context.push('/cart'); },
                  child: const Text('Beli Sekarang'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;
  const _SpecRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 13, color: GysColors.neutral500))),
          Expanded(flex: 3, child: Text(value, style: const TextStyle(fontSize: 13, color: GysColors.neutral900, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          border: Border.all(color: GysColors.neutral200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: GysColors.brand700, size: 20),
      ),
    );
  }
}
