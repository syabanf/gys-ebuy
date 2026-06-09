import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

/// One linkable GYS E-Ordering app (demo ports served by `pnpm preview`).
class GysApp {
  final String name;
  final String subtitle;
  final String url;
  final IconData icon;
  final bool current;
  const GysApp(this.name, this.subtitle, this.url, this.icon, {this.current = false});
}

// On a single-root deploy (Vercel) this app is served under /mobile/, and the
// other apps live under /distributor/ and /internal/ on the same origin.
// Locally each app runs on its own port.
bool get _deployed => Uri.base.path.startsWith('/mobile');
String _appUrl(String subPath, String localUrl) =>
    _deployed ? Uri.base.resolve(subPath).toString() : localUrl;

List<GysApp> gysApps() => [
  GysApp('Buyer Mobile', 'Aplikasi pembeli (Flutter Web)', _appUrl('/mobile/', 'http://localhost:4002'), Icons.smartphone_outlined, current: true),
  GysApp('Portal Distributor', 'Web distributor', _appUrl('/distributor/', 'http://localhost:4000'), Icons.storefront_outlined),
  GysApp('GYS Internal', 'Konsol Sales & IT', _appUrl('/internal/', 'http://localhost:4001'), Icons.admin_panel_settings_outlined),
];

Future<void> _open(BuildContext context, GysApp app) async {
  final messenger = ScaffoldMessenger.of(context);
  Navigator.of(context).pop();
  final ok = await launchUrl(Uri.parse(app.url), webOnlyWindowName: '_blank');
  if (!ok) {
    messenger.showSnackBar(SnackBar(content: Text('Tidak bisa membuka ${app.name}')));
  }
}

/// Bottom sheet that lets the user jump to the other GYS apps.
void showGysAppSwitcher(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: GysColors.neutral200, borderRadius: BorderRadius.circular(2))),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Aplikasi GYS E-Ordering', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: GysColors.neutral900)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Pindah ke aplikasi lain (demo) — terbuka di tab baru.', style: TextStyle(fontSize: 13, color: GysColors.neutral500)),
            ),
          ),
          ...gysApps().map((app) => ListTile(
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(color: GysColors.brand50, borderRadius: BorderRadius.circular(10)),
                  child: Icon(app.icon, color: GysColors.brand700, size: 22),
                ),
                title: Text(app.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(app.subtitle, style: const TextStyle(fontSize: 12, color: GysColors.neutral500)),
                trailing: app.current
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(color: GysColors.brand50, borderRadius: BorderRadius.circular(20)),
                        child: const Text('Saat ini', style: TextStyle(fontSize: 11, color: GysColors.brand700, fontWeight: FontWeight.w700)),
                      )
                    : const Icon(Icons.open_in_new, size: 18, color: GysColors.neutral400),
                onTap: app.current ? null : () => _open(ctx, app),
              )),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

/// App-bar icon button that opens the GYS app switcher.
class AppSwitcherButton extends StatelessWidget {
  const AppSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Pindah aplikasi',
      icon: const Icon(Icons.grid_view_rounded),
      onPressed: () => showGysAppSwitcher(context),
    );
  }
}
