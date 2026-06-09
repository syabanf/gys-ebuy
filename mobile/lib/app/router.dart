import 'package:go_router/go_router.dart';
import '../features/auth/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/kyc_pending_screen.dart';
import '../features/home/home_shell.dart';
import '../features/home/dashboard_screen.dart';
import '../features/catalog/catalog_screen.dart';
import '../features/catalog/product_detail_screen.dart';
import '../features/cart/cart_screen.dart';
import '../features/cart/checkout_screen.dart';
import '../features/cart/payment_screen.dart';
import '../features/cart/order_confirmation_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/orders/order_detail_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/addresses_screen.dart';
import '../features/notifications/notifications_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/kyc-pending', builder: (context, state) => const KycPendingScreen()),
    ShellRoute(
      builder: (context, state, child) => HomeShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const DashboardScreen()),
        GoRoute(path: '/catalog', builder: (context, state) => const CatalogScreen()),
        GoRoute(path: '/orders', builder: (context, state) => const OrdersScreen()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      ],
    ),
    GoRoute(path: '/product/:id', builder: (context, state) => ProductDetailScreen(id: state.pathParameters['id']!)),
    GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
    GoRoute(path: '/checkout', builder: (context, state) => const CheckoutScreen()),
    GoRoute(path: '/payment', builder: (context, state) => const PaymentScreen()),
    GoRoute(path: '/order-confirmation/:orderNumber', builder: (context, state) => OrderConfirmationScreen(orderNumber: state.pathParameters['orderNumber']!)),
    GoRoute(path: '/orders/:id', builder: (context, state) => OrderDetailScreen(id: state.pathParameters['id']!)),
    GoRoute(path: '/addresses', builder: (context, state) => const AddressesScreen()),
    GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
  ],
);
