import 'package:flutter/foundation.dart';

class AppNotif {
  final String id;
  final String type; // order | payment | approval | delivery | system
  final String title;
  final String body;
  final String at;
  bool read;

  AppNotif({required this.id, required this.type, required this.title, required this.body, required this.at, this.read = false});
}

class NotifState extends ChangeNotifier {
  static final NotifState _instance = NotifState._();
  factory NotifState() => _instance;
  NotifState._();

  final List<AppNotif> _items = [
    AppNotif(id: 'n1', type: 'approval', title: 'Akun disetujui', body: 'Selamat! Akun Anda telah disetujui GYS. Anda bisa mulai memesan.', at: '9 Jun 2026 · 08:30'),
    AppNotif(id: 'n2', type: 'payment', title: 'Menunggu pembayaran', body: 'Pesanan GYS-2026-000124 menunggu pembayaran. Selesaikan dalam 3 jam.', at: '9 Jun 2026 · 08:15'),
    AppNotif(id: 'n3', type: 'delivery', title: 'Pesanan dikirim', body: 'GYS-2026-000120 sedang dalam perjalanan ke lokasi Anda.', at: '6 Jun 2026 · 14:30'),
    AppNotif(id: 'n4', type: 'order', title: 'Pesanan selesai', body: 'GYS-2026-000118 telah selesai. Terima kasih!', at: '25 Mei 2026 · 11:20', read: true),
    AppNotif(id: 'n5', type: 'system', title: 'Promo', body: 'Dapatkan poin GYS untuk setiap pembelian. Cek di menu Profil.', at: '20 Mei 2026 · 09:00', read: true),
  ];

  List<AppNotif> get items => List.unmodifiable(_items);
  int get unread => _items.where((n) => !n.read).length;

  void markAllRead() { for (final n in _items) { n.read = true; } notifyListeners(); }
  void markRead(String id) { final n = _items.firstWhere((x) => x.id == id); n.read = true; notifyListeners(); }
}
