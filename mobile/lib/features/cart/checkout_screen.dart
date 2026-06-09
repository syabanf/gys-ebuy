import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/address_state.dart';
import '../../core/cart_state.dart';
import '../../core/format.dart';
import '../../core/theme/app_colors.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _fulfillment = 'via_distributor';
  String _distributor = 'dist-001';
  final _addresses = AddressState();
  Address? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _selectedAddress = _addresses.defaultAddress;
  }

  void _pickAddress() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(padding: EdgeInsets.all(16), child: Text('Pilih Alamat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
            ..._addresses.items.map((a) => ListTile(
                  leading: Icon(a.id == _selectedAddress?.id ? Icons.radio_button_checked : Icons.radio_button_off, color: a.id == _selectedAddress?.id ? GysColors.brand500 : GysColors.neutral400),
                  title: Text(a.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(a.full, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                  onTap: () { setState(() => _selectedAddress = a); Navigator.pop(context); },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static const _distributors = [
    ('dist-001', 'PT Mitra Baja Sentosa', 'Jakarta · lead time 2-3 hari'),
    ('dist-002', 'CV Surya Logam Indonesia', 'Surabaya · lead time 3-4 hari'),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = CartState();
    final subtotal = cart.subtotal;
    const shippingFee = 250000;
    final total = subtotal + shippingFee;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: 'Alamat Pengiriman'),
            const SizedBox(height: 10),
            InkWell(
              onTap: _pickAddress,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: GysColors.neutral200)),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: GysColors.brand700, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _selectedAddress == null
                          ? const Text('Pilih alamat pengiriman', style: TextStyle(fontSize: 14, color: GysColors.neutral500))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text(_selectedAddress!.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 6),
                                  if (_selectedAddress!.isDefault)
                                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), decoration: BoxDecoration(color: GysColors.brand50, borderRadius: BorderRadius.circular(10)), child: const Text('Utama', style: TextStyle(fontSize: 10, color: GysColors.brand700, fontWeight: FontWeight.w700))),
                                ]),
                                const SizedBox(height: 2),
                                Text(_selectedAddress!.full, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: GysColors.neutral500)),
                              ],
                            ),
                    ),
                    const Text('Ubah', style: TextStyle(color: GysColors.brand700, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'Pilih Fulfillment'),
            const SizedBox(height: 10),
            _FulfillmentChoice(
              selected: _fulfillment == 'gys_direct',
              title: 'GYS Langsung',
              subtitle: 'Pengiriman dari pabrik GYS Cilegon · lead time 5-7 hari',
              onTap: () => setState(() => _fulfillment = 'gys_direct'),
            ),
            const SizedBox(height: 8),
            _FulfillmentChoice(
              selected: _fulfillment == 'via_distributor',
              title: 'Via Distributor',
              subtitle: 'Pengiriman dari distributor terdekat · lebih cepat',
              onTap: () => setState(() => _fulfillment = 'via_distributor'),
            ),
            if (_fulfillment == 'via_distributor') ...[
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  children: _distributors.map((d) {
                    final selected = _distributor == d.$1;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => setState(() => _distributor = d.$1),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selected ? GysColors.brand50 : Colors.white,
                            border: Border.all(color: selected ? GysColors.brand500 : GysColors.neutral200, width: selected ? 2 : 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? GysColors.brand500 : GysColors.neutral400, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(d.$2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                    Text(d.$3, style: const TextStyle(fontSize: 12, color: GysColors.neutral500)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 24),
            _SectionHeader(title: 'Ringkasan'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: GysColors.neutral200)),
              child: Column(
                children: [
                  ...cart.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(child: Text('${item.qty}× ${item.name}', style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        Text(formatIDR(item.subtotal), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )),
                  const Divider(height: 18),
                  _SummaryRow(label: 'Subtotal', value: formatIDR(subtotal)),
                  _SummaryRow(label: 'Biaya Kirim', value: formatIDR(shippingFee)),
                  const Divider(height: 18),
                  _SummaryRow(label: 'Total', value: formatIDR(total), bold: true),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: GysColors.neutral200))),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/payment'),
              child: Text('Bayar ${formatIDR(total)}'),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: GysColors.neutral900));
  }
}

class _FulfillmentChoice extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _FulfillmentChoice({required this.selected, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? GysColors.brand500 : GysColors.neutral400, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: GysColors.neutral500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _SummaryRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: bold ? 15 : 13, color: bold ? GysColors.neutral900 : GysColors.neutral500, fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          Text(value, style: TextStyle(fontSize: bold ? 17 : 13, color: bold ? GysColors.brand700 : GysColors.neutral900, fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }
}
