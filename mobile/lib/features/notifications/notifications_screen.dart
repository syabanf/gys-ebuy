import 'package:flutter/material.dart';
import '../../core/notif_state.dart';
import '../../core/theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _store = NotifState();

  @override
  void initState() {
    super.initState();
    _store.addListener(_onChange);
  }

  @override
  void dispose() {
    _store.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

  ({IconData icon, Color bg, Color fg}) _style(String type) {
    return switch (type) {
      'approval' => (icon: Icons.verified_outlined, bg: const Color(0xFFDCFCE7), fg: const Color(0xFF166534)),
      'payment' => (icon: Icons.payment_outlined, bg: const Color(0xFFFEF3C7), fg: const Color(0xFF92400E)),
      'delivery' => (icon: Icons.local_shipping_outlined, bg: GysColors.brand50, fg: GysColors.brand700),
      'order' => (icon: Icons.receipt_long_outlined, bg: const Color(0xFFDBEAFE), fg: const Color(0xFF1E40AF)),
      _ => (icon: Icons.campaign_outlined, bg: GysColors.neutral100, fg: GysColors.neutral600),
    };
  }

  @override
  Widget build(BuildContext context) {
    final items = _store.items;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          if (_store.unread > 0)
            TextButton(onPressed: _store.markAllRead, child: const Text('Tandai dibaca')),
        ],
      ),
      body: items.isEmpty
          ? const Center(child: Text('Belum ada notifikasi.', style: TextStyle(color: GysColors.neutral500)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final n = items[i];
                final s = _style(n.type);
                return InkWell(
                  onTap: () => _store.markRead(n.id),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: n.read ? Colors.white : GysColors.brand50.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: GysColors.neutral200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 38, width: 38, decoration: BoxDecoration(color: s.bg, shape: BoxShape.circle), child: Icon(s.icon, color: s.fg, size: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(n.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
                                  if (!n.read) Container(height: 8, width: 8, decoration: const BoxDecoration(color: GysColors.brand500, shape: BoxShape.circle)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(n.body, style: const TextStyle(fontSize: 13, color: GysColors.neutral600, height: 1.4)),
                              const SizedBox(height: 4),
                              Text(n.at, style: const TextStyle(fontSize: 11, color: GysColors.neutral400)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
