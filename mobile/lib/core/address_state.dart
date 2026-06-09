import 'package:flutter/foundation.dart';

class Address {
  String id;
  String label;
  String recipient;
  String phone;
  String full;
  bool isDefault;

  Address({
    required this.id,
    required this.label,
    required this.recipient,
    required this.phone,
    required this.full,
    this.isDefault = false,
  });
}

class AddressState extends ChangeNotifier {
  static final AddressState _instance = AddressState._();
  factory AddressState() => _instance;
  AddressState._();

  int _seq = 2;
  final List<Address> _items = [
    Address(
      id: 'addr-1',
      label: 'Kantor Pusat',
      recipient: 'Andi Pratama',
      phone: '0812-3456-7890',
      full: 'Jl. Sudirman No. 45, Jakarta Pusat 10220',
      isDefault: true,
    ),
    Address(
      id: 'addr-2',
      label: 'Gudang Proyek',
      recipient: 'Site Manager',
      phone: '0813-1111-2222',
      full: 'Kawasan Industri MM2100 Blok F-7, Cibitung, Bekasi 17520',
    ),
  ];

  List<Address> get items => List.unmodifiable(_items);
  Address? get defaultAddress => _items.where((a) => a.isDefault).firstOrNull ?? _items.firstOrNull;

  void add({required String label, required String recipient, required String phone, required String full, bool makeDefault = false}) {
    _seq += 1;
    final addr = Address(id: 'addr-$_seq', label: label, recipient: recipient, phone: phone, full: full);
    if (makeDefault || _items.isEmpty) {
      for (final a in _items) {
        a.isDefault = false;
      }
      addr.isDefault = true;
    }
    _items.add(addr);
    notifyListeners();
  }

  void update(String id, {required String label, required String recipient, required String phone, required String full}) {
    final a = _items.firstWhere((x) => x.id == id);
    a.label = label;
    a.recipient = recipient;
    a.phone = phone;
    a.full = full;
    notifyListeners();
  }

  void remove(String id) {
    final wasDefault = _items.firstWhere((x) => x.id == id).isDefault;
    _items.removeWhere((x) => x.id == id);
    if (wasDefault && _items.isNotEmpty) _items.first.isDefault = true;
    notifyListeners();
  }

  void setDefault(String id) {
    for (final a in _items) {
      a.isDefault = a.id == id;
    }
    notifyListeners();
  }
}
