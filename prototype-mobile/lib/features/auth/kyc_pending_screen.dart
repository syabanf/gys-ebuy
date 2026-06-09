import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class KycPendingScreen extends StatelessWidget {
  const KycPendingScreen({super.key});

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
              Container(
                height: 88,
                width: 88,
                decoration: BoxDecoration(
                  color: GysColors.brand50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hourglass_top_rounded, color: GysColors.brand500, size: 44),
              ),
              const SizedBox(height: 24),
              const Text('Pendaftaran Terkirim', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: GysColors.neutral900)),
              const SizedBox(height: 12),
              const Text(
                'Tim GYS Sales sedang meninjau dokumen Anda. Anda akan mendapat notifikasi via email & push notification ketika sudah disetujui (biasanya 1-2 hari kerja).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: GysColors.neutral500, height: 1.5),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: GysColors.neutral200),
                ),
                child: const Column(
                  children: [
                    _Step(no: 1, label: 'Dokumen diunggah', done: true),
                    SizedBox(height: 12),
                    _Step(no: 2, label: 'Sedang ditinjau GYS Sales', done: false, active: true),
                    SizedBox(height: 12),
                    _Step(no: 3, label: 'Verifikasi selesai', done: false),
                    SizedBox(height: 12),
                    _Step(no: 4, label: 'Akses dibuka', done: false),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Kembali ke Login'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Lanjutkan ke Demo (Skip Approval)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final int no;
  final String label;
  final bool done;
  final bool active;

  const _Step({required this.no, required this.label, required this.done, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 28,
          width: 28,
          decoration: BoxDecoration(
            color: done ? GysColors.brand500 : (active ? GysColors.warning : GysColors.neutral100),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text('$no', style: TextStyle(color: active ? Colors.white : GysColors.neutral500, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: done ? GysColors.neutral900 : GysColors.neutral700, fontWeight: active ? FontWeight.w600 : FontWeight.w400))),
      ],
    );
  }
}
