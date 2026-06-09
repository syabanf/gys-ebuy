import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String orderNumber;
  const OrderConfirmationScreen({super.key, required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GysColors.neutral50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                height: 96,
                width: 96,
                decoration: const BoxDecoration(color: GysColors.success, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 56),
              ),
              const SizedBox(height: 24),
              const Text('Pesanan Berhasil!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: GysColors.neutral900)),
              const SizedBox(height: 8),
              Text('Nomor pesanan', style: TextStyle(fontSize: 13, color: GysColors.neutral500)),
              const SizedBox(height: 4),
              Text(orderNumber, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: GysColors.brand700, letterSpacing: 0.5)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: GysColors.neutral200)),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.email_outlined, color: GysColors.brand700, size: 20),
                        SizedBox(width: 10),
                        Expanded(child: Text('Konfirmasi pesanan dikirim ke email Anda', style: TextStyle(fontSize: 13))),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.notifications_outlined, color: GysColors.brand700, size: 20),
                        SizedBox(width: 10),
                        Expanded(child: Text('Anda akan menerima notifikasi setiap perubahan status pesanan', style: TextStyle(fontSize: 13))),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/orders'),
                  child: const Text('Lihat Detail Pesanan'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Kembali ke Katalog'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
