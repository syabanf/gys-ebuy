import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController(text: '0812-3456-7890');
  final _passwordController = TextEditingController(text: 'demo');
  bool _loading = false;
  bool _obscure = true;

  static const _demoBuyers = [
    ('PT Karya Konstruksi Nusantara', 'Kontraktor'),
    ('CV Fabrikasi Maju Jaya', 'Fabrikator'),
    ('Toko Besi Sumber Rejeki', 'Retail'),
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GysColors.neutral50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Center(
                child: Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: GysColors.brand500,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('GYS', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Selamat Datang', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: GysColors.neutral900)),
              const SizedBox(height: 6),
              const Text('Masuk ke akun GYS E-Ordering Anda', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: GysColors.neutral500)),
              const SizedBox(height: 36),

              const Text('Nomor Telepon', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GysColors.neutral700)),
              const SizedBox(height: 6),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: 'Contoh: 0812-3456-7890'),
              ),
              const SizedBox(height: 16),

              const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GysColors.neutral700)),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: GysColors.neutral400),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: () {}, child: const Text('Lupa Password?')),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('Masuk'),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum punya akun? ', style: TextStyle(color: GysColors.neutral500, fontSize: 14)),
                  TextButton(onPressed: () => context.push('/register'), child: const Text('Daftar')),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: const [
                  Expanded(child: Divider(color: GysColors.neutral200)),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Login cepat (demo)', style: TextStyle(fontSize: 12, color: GysColors.neutral400))),
                  Expanded(child: Divider(color: GysColors.neutral200)),
                ],
              ),
              const SizedBox(height: 12),
              ..._demoBuyers.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: _login,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: GysColors.neutral200)),
                        child: Row(
                          children: [
                            Container(
                              height: 38,
                              width: 38,
                              decoration: BoxDecoration(color: GysColors.brand50, borderRadius: BorderRadius.circular(9)),
                              child: const Icon(Icons.person_outline, color: GysColors.brand700, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(b.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: GysColors.neutral900)),
                                  Text(b.$2, style: const TextStyle(fontSize: 12, color: GysColors.neutral500)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward, color: GysColors.neutral400, size: 18),
                          ],
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
