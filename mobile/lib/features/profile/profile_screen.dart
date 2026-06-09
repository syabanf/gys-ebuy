import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_switcher.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil'), actions: const [AppSwitcherButton()]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: GysColors.neutral200)),
            child: Row(
              children: [
                const CircleAvatar(radius: 28, backgroundColor: GysColors.brand500, child: Text('AP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PT Karya Konstruksi Nusantara', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      SizedBox(height: 2),
                      Text('Andi Pratama · Kontraktor', style: TextStyle(fontSize: 13, color: GysColors.neutral500)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.edit_outlined, color: GysColors.neutral500), onPressed: () {}),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: GysColors.neutral200)),
            child: ListTile(
              leading: Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(color: GysColors.brand50, borderRadius: BorderRadius.circular(9)),
                child: const Icon(Icons.grid_view_rounded, color: GysColors.brand700, size: 20),
              ),
              title: const Text('Aplikasi GYS Lainnya', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('Portal Distributor & Konsol Internal', style: TextStyle(fontSize: 12, color: GysColors.neutral500)),
              trailing: const Icon(Icons.chevron_right, color: GysColors.neutral400),
              onTap: () => showGysAppSwitcher(context),
            ),
          ),
          const SizedBox(height: 16),
          _Section(items: const [
            (Icons.location_on_outlined, 'Alamat Pengiriman', '/addresses'),
            (Icons.account_balance_outlined, 'Akun Bank', null),
            (Icons.description_outlined, 'Dokumen Bisnis', null),
          ]),
          const SizedBox(height: 12),
          _Section(items: const [
            (Icons.notifications_outlined, 'Notifikasi', null),
            (Icons.language_outlined, 'Bahasa', null),
            (Icons.lock_outline, 'Keamanan', null),
          ]),
          const SizedBox(height: 12),
          _Section(items: const [
            (Icons.help_outline, 'Bantuan', null),
            (Icons.gavel_outlined, 'Syarat & Ketentuan', null),
            (Icons.privacy_tip_outlined, 'Kebijakan Privasi', null),
          ]),
          const SizedBox(height: 24),
          TextButton.icon(
            icon: const Icon(Icons.logout, color: GysColors.danger),
            label: const Text('Keluar', style: TextStyle(color: GysColors.danger, fontWeight: FontWeight.w600)),
            onPressed: () => context.go('/login'),
          ),
          const SizedBox(height: 8),
          const Center(child: Text('GYS E-Ordering · Prototype Phase 0 · v0.0.1', style: TextStyle(fontSize: 11, color: GysColors.neutral400))),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final List<(IconData, String, String?)> items;
  const _Section({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: GysColors.neutral200)),
      child: Column(
        children: List.generate(items.length, (i) {
          final (icon, label, route) = items[i];
          return Column(
            children: [
              ListTile(
                leading: Icon(icon, color: GysColors.neutral500),
                title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right, color: GysColors.neutral400),
                onTap: route != null ? () => context.push(route) : null,
              ),
              if (i < items.length - 1) const Divider(height: 1, indent: 56),
            ],
          );
        }),
      ),
    );
  }
}
