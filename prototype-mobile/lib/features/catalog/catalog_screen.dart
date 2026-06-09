import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/cart_state.dart';
import '../../core/format.dart';
import '../../core/mock_api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/notif_bell.dart';
import '../../core/widgets/app_switcher.dart';
import '../../core/widgets/skeleton.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _api = MockApi();
  final _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _sort = 'newest';
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _categories = [];
  bool _loading = true;

  static const _sortLabels = {
    'newest': 'Terbaru',
    'price_asc': 'Harga termurah',
    'price_desc': 'Harga termahal',
    'name': 'Nama A-Z',
  };

  List<Map<String, dynamic>> get _displayed {
    final list = [..._products];
    switch (_sort) {
      case 'price_asc':
        list.sort((a, b) => (a['centralPrice'] as num).compareTo(b['centralPrice'] as num));
      case 'price_desc':
        list.sort((a, b) => (b['centralPrice'] as num).compareTo(a['centralPrice'] as num));
      case 'name':
        list.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _api.listProducts(categoryId: _selectedCategory, search: _searchController.text),
      _api.listCategories(),
    ]);
    if (!mounted) return;
    setState(() {
      _products = results[0];
      _categories = results[1];
      _loading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _quickAdd(Map<String, dynamic> p) {
    CartState().add(p);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${p['name']} ditambahkan'),
        backgroundColor: GysColors.brand700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Produk'),
        actions: const [AppSwitcherButton(), NotifBell()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _load(),
              decoration: InputDecoration(
                hintText: 'Cari produk atau SKU…',
                prefixIcon: const Icon(Icons.search, color: GysColors.neutral400),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear, color: GysColors.neutral400), onPressed: () { _searchController.clear(); _load(); })
                    : null,
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _CategoryChip(label: 'Semua', selected: _selectedCategory == 'all', onTap: () { setState(() => _selectedCategory = 'all'); _load(); }),
                ..._categories.map((c) => _CategoryChip(
                      label: c['name'] as String,
                      selected: _selectedCategory == c['id'],
                      onTap: () { setState(() => _selectedCategory = c['id'] as String); _load(); },
                    )),
              ],
            ),
          ),
          if (!_loading)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                children: [
                  Expanded(child: Text('${_products.length} produk ditemukan', style: const TextStyle(fontSize: 12, color: GysColors.neutral500))),
                  PopupMenuButton<String>(
                    initialValue: _sort,
                    onSelected: (v) => setState(() => _sort = v),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.swap_vert, size: 18, color: GysColors.brand700),
                        const SizedBox(width: 2),
                        Text(_sortLabels[_sort]!, style: const TextStyle(fontSize: 12, color: GysColors.brand700, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    itemBuilder: (_) => _sortLabels.entries.map((e) => PopupMenuItem(value: e.key, child: Text(e.value))).toList(),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _loading
                ? GridView.count(
                    padding: const EdgeInsets.all(16),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.66,
                    children: List.generate(6, (_) => const SkeletonProductCard()),
                  )
                : _products.isEmpty
                    ? const Center(child: Text('Tidak ada produk yang cocok', style: TextStyle(color: GysColors.neutral500)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: GysColors.brand500,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.66,
                          ),
                          itemCount: _displayed.length,
                          itemBuilder: (_, i) => _ProductCard(product: _displayed[i], onAdd: () => _quickAdd(_displayed[i])),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: GysColors.brand500,
        labelStyle: TextStyle(color: selected ? Colors.white : GysColors.neutral700, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: selected ? GysColors.brand500 : GysColors.neutral200)),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onAdd;
  const _ProductCard({required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/product/${product['id']}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: GysColors.neutral200)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.3,
              child: Container(
                decoration: const BoxDecoration(color: GysColors.brand50, borderRadius: BorderRadius.vertical(top: Radius.circular(13))),
                child: const Center(child: Icon(Icons.layers_outlined, color: GysColors.brand700, size: 44)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GysColors.neutral900, height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('SKU ${product['sku']}', style: const TextStyle(fontSize: 11, color: GysColors.neutral400)),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatIDR(product['centralPrice'] as num), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GysColors.brand700), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('/ ${product['uom']}', style: const TextStyle(fontSize: 10, color: GysColors.neutral500)),
                      ],
                    ),
                  ),
                  Material(
                    color: GysColors.brand500,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: onAdd,
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.add, color: Colors.white, size: 20)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
