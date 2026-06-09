import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _step = 0;
  String _businessType = 'contractor';
  bool _agreed = false;

  static const _businessTypes = [
    ('contractor', 'Kontraktor'),
    ('fabricator', 'Fabrikator'),
    ('retailer', 'Toko Retail'),
    ('sub-distributor', 'Sub-Distributor'),
  ];

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      context.go('/kyc-pending');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar (${_step + 1}/3)'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => _step > 0 ? setState(() => _step--) : context.pop()),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(value: (_step + 1) / 3, backgroundColor: GysColors.neutral200, color: GysColors.brand500, minHeight: 4),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: switch (_step) {
                  0 => _buildBusinessStep(),
                  1 => _buildContactStep(),
                  _ => _buildKycStep(),
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: (_step == 2 && !_agreed) ? null : _next,
                child: Text(_step == 2 ? 'Kirim Pendaftaran' : 'Lanjut'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Profil Bisnis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: GysColors.neutral900)),
        const SizedBox(height: 6),
        const Text('Ceritakan tentang bisnis Anda.', style: TextStyle(fontSize: 14, color: GysColors.neutral500)),
        const SizedBox(height: 24),
        const Text('Nama Perusahaan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        const TextField(decoration: InputDecoration(hintText: 'PT/CV/Toko ...')),
        const SizedBox(height: 16),
        const Text('Tipe Bisnis', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ..._businessTypes.map((bt) {
          final selected = _businessType == bt.$1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => setState(() => _businessType = bt.$1),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected ? GysColors.brand50 : Colors.white,
                  border: Border.all(color: selected ? GysColors.brand500 : GysColors.neutral200, width: selected ? 2 : 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? GysColors.brand500 : GysColors.neutral400, size: 22),
                    const SizedBox(width: 12),
                    Text(bt.$2, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        const Text('NPWP', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        const TextField(decoration: InputDecoration(hintText: '00.000.000.0-000.000')),
      ],
    );
  }

  Widget _buildContactStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        Text('Kontak & Alamat', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: GysColors.neutral900)),
        SizedBox(height: 6),
        Text('Kontak utama dan alamat operasional.', style: TextStyle(fontSize: 14, color: GysColors.neutral500)),
        SizedBox(height: 24),
        Text('Nama Penanggung Jawab', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        TextField(),
        SizedBox(height: 16),
        Text('Nomor Telepon', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        TextField(keyboardType: TextInputType.phone),
        SizedBox(height: 16),
        Text('Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        TextField(keyboardType: TextInputType.emailAddress),
        SizedBox(height: 16),
        Text('Alamat Operasional', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        TextField(maxLines: 3),
      ],
    );
  }

  Widget _buildKycStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Unggah Dokumen KYC', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: GysColors.neutral900)),
        const SizedBox(height: 6),
        const Text('Tim GYS akan memverifikasi dokumen ini.', style: TextStyle(fontSize: 14, color: GysColors.neutral500)),
        const SizedBox(height: 24),
        _UploadTile(title: 'NPWP', subtitle: 'Dokumen NPWP perusahaan', icon: Icons.description_outlined),
        const SizedBox(height: 12),
        _UploadTile(title: 'NIB', subtitle: 'Nomor Induk Berusaha', icon: Icons.assignment_outlined),
        const SizedBox(height: 12),
        _UploadTile(title: 'KTP Direksi', subtitle: 'Kartu Tanda Penduduk pemilik/direksi', icon: Icons.badge_outlined),
        const SizedBox(height: 24),
        CheckboxListTile(
          value: _agreed,
          onChanged: (v) => setState(() => _agreed = v ?? false),
          activeColor: GysColors.brand500,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Saya menyetujui Syarat & Ketentuan dan Kebijakan Privasi GYS, termasuk pemrosesan data pribadi sesuai UU PDP.', style: TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}

class _UploadTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _UploadTile({required this.title, required this.subtitle, required this.icon});

  @override
  State<_UploadTile> createState() => _UploadTileState();
}

class _UploadTileState extends State<_UploadTile> {
  bool _uploaded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _uploaded = !_uploaded),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _uploaded ? GysColors.brand50 : Colors.white,
          border: Border.all(color: _uploaded ? GysColors.brand500 : GysColors.neutral200),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: _uploaded ? GysColors.brand500 : GysColors.neutral100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_uploaded ? Icons.check : widget.icon, color: _uploaded ? Colors.white : GysColors.neutral500, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: GysColors.neutral900)),
                  const SizedBox(height: 2),
                  Text(_uploaded ? 'Terunggah · ketuk untuk ganti' : widget.subtitle, style: TextStyle(fontSize: 12, color: _uploaded ? GysColors.brand700 : GysColors.neutral500)),
                ],
              ),
            ),
            Icon(_uploaded ? Icons.refresh : Icons.upload_outlined, color: GysColors.neutral400, size: 22),
          ],
        ),
      ),
    );
  }
}
