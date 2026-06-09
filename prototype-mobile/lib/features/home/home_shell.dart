import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/cart_state.dart';

class HomeShell extends StatefulWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  @override
  void initState() {
    super.initState();
    CartState().addListener(_onCartChanged);
  }

  @override
  void dispose() {
    CartState().removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() => setState(() {});

  int _indexFor(String path) {
    if (path.startsWith('/catalog')) return 1;
    if (path.startsWith('/orders')) return 2;
    if (path.startsWith('/profile')) return 3;
    return 0;
  }

  void _onTap(int i) {
    switch (i) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/catalog');
        break;
      case 2:
        context.go('/orders');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).matchedLocation;
    final cartCount = CartState().count;

    return Scaffold(
      body: widget.child,
      floatingActionButton: cartCount > 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/cart'),
              backgroundColor: GysColors.brand500,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.shopping_cart_outlined),
              label: Text('Keranjang ($cartCount)'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexFor(path),
        onDestinationSelected: _onTap,
        backgroundColor: Colors.white,
        indicatorColor: GysColors.brand50,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: GysColors.brand700), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront, color: GysColors.brand700), label: 'Katalog'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long, color: GysColors.brand700), label: 'Pesanan'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: GysColors.brand700), label: 'Profil'),
        ],
      ),
    );
  }
}
