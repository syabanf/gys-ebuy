import 'package:flutter/foundation.dart';

class CartItem {
  final String productId;
  final String name;
  final String sku;
  final String uom;
  final num unitPrice;
  int qty;

  CartItem({
    required this.productId,
    required this.name,
    required this.sku,
    required this.uom,
    required this.unitPrice,
    this.qty = 1,
  });

  num get subtotal => unitPrice * qty;
}

class CartState extends ChangeNotifier {
  static final CartState _instance = CartState._();
  factory CartState() => _instance;
  CartState._();

  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList(growable: false);
  int get count => _items.values.fold(0, (sum, i) => sum + i.qty);
  num get subtotal => _items.values.fold<num>(0, (sum, i) => sum + i.subtotal);
  bool get isEmpty => _items.isEmpty;

  void add(Map<String, dynamic> product, {int qty = 1}) {
    final id = product['id'] as String;
    if (_items.containsKey(id)) {
      _items[id]!.qty += qty;
    } else {
      _items[id] = CartItem(
        productId: id,
        name: product['name'] as String,
        sku: product['sku'] as String,
        uom: product['uom'] as String,
        unitPrice: product['centralPrice'] as num,
        qty: qty,
      );
    }
    notifyListeners();
  }

  void updateQty(String productId, int qty) {
    if (qty <= 0) {
      _items.remove(productId);
    } else if (_items.containsKey(productId)) {
      _items[productId]!.qty = qty;
    }
    notifyListeners();
  }

  void remove(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
