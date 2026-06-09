import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

class MockApi {
  static MockApi? _instance;
  factory MockApi() => _instance ??= MockApi._();
  MockApi._();

  List<Map<String, dynamic>>? _products;
  List<Map<String, dynamic>>? _categories;
  List<Map<String, dynamic>>? _orders;
  final _rand = Random();

  Duration get _latency => Duration(milliseconds: 250 + _rand.nextInt(450));

  Future<List<Map<String, dynamic>>> _load(String name, List<Map<String, dynamic>>? cache, void Function(List<Map<String, dynamic>>) setCache) async {
    if (cache != null) return cache;
    final raw = await rootBundle.loadString('assets/mocks/$name.json');
    final data = List<Map<String, dynamic>>.from(json.decode(raw) as List);
    setCache(data);
    return data;
  }

  Future<List<Map<String, dynamic>>> listProducts({String? categoryId, String? search}) async {
    await Future.delayed(_latency);
    final products = await _load('products', _products, (d) => _products = d);
    var result = List<Map<String, dynamic>>.from(products);
    if (categoryId != null && categoryId != 'all') {
      result = result.where((p) => p['categoryId'] == categoryId).toList();
    }
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      result = result.where((p) =>
        (p['name'] as String).toLowerCase().contains(q) ||
        (p['sku'] as String).toLowerCase().contains(q)
      ).toList();
    }
    return result;
  }

  Future<Map<String, dynamic>?> getProduct(String id) async {
    await Future.delayed(_latency);
    final products = await _load('products', _products, (d) => _products = d);
    try {
      return products.firstWhere((p) => p['id'] == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> listCategories() async {
    await Future.delayed(_latency);
    return _load('categories', _categories, (d) => _categories = d);
  }

  Future<List<Map<String, dynamic>>> listOrders() async {
    await Future.delayed(_latency);
    final orders = await _load('orders', _orders, (d) => _orders = d);
    return List<Map<String, dynamic>>.from(orders);
  }
}
