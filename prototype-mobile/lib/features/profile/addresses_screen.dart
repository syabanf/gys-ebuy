import 'package:flutter/material.dart';
import '../../core/address_state.dart';
import '../../core/theme/app_colors.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final _store = AddressState();

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

  void _openForm({Address? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddressForm(existing: existing),
    );
  }

  void _confirmDelete(Address a) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus alamat?'),
        content: Text('Hapus "${a.label}"? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () { _store.remove(a.id); Navigator.pop(ctx); },
            child: const Text('Hapus', style: TextStyle(color: GysColors.danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _store.items;
    return Scaffold(
      appBar: AppBar(title: const Text('Alamat Pengiriman')),
      body: items.isEmpty
          ? const Center(child: Text('Belum ada alamat tersimpan.', style: TextStyle(color: GysColors.neutral500)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final a = items[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: a.isDefault ? GysColors.brand500 : GysColors.neutral200, width: a.isDefault ? 1.5 : 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(a.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          if (a.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: GysColors.brand50, borderRadius: BorderRadius.circular(20)),
                              child: const Text('Utama', style: TextStyle(fontSize: 11, color: GysColors.brand700, fontWeight: FontWeight.w700)),
                            ),
                          const Spacer(),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: GysColors.neutral400),
                            onSelected: (v) {
                              if (v == 'edit') _openForm(existing: a);
                              if (v == 'default') _store.setDefault(a.id);
                              if (v == 'delete') _confirmDelete(a);
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'edit', child: Text('Ubah')),
                              if (!a.isDefault) const PopupMenuItem(value: 'default', child: Text('Jadikan Utama')),
                              const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(a.recipient, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GysColors.neutral700)),
                      Text(a.phone, style: const TextStyle(fontSize: 13, color: GysColors.neutral500)),
                      const SizedBox(height: 4),
                      Text(a.full, style: const TextStyle(fontSize: 13, color: GysColors.neutral600, height: 1.4)),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: GysColors.brand500,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Alamat'),
      ),
    );
  }
}

class _AddressForm extends StatefulWidget {
  final Address? existing;
  const _AddressForm({this.existing});

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  late final TextEditingController _label;
  late final TextEditingController _recipient;
  late final TextEditingController _phone;
  late final TextEditingController _full;
  bool _makeDefault = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _label = TextEditingController(text: e?.label ?? '');
    _recipient = TextEditingController(text: e?.recipient ?? '');
    _phone = TextEditingController(text: e?.phone ?? '');
    _full = TextEditingController(text: e?.full ?? '');
  }

  @override
  void dispose() {
    _label.dispose();
    _recipient.dispose();
    _phone.dispose();
    _full.dispose();
    super.dispose();
  }

  void _save() {
    if (_label.text.trim().isEmpty || _full.text.trim().isEmpty) return;
    final store = AddressState();
    if (widget.existing != null) {
      store.update(widget.existing!.id, label: _label.text.trim(), recipient: _recipient.text.trim(), phone: _phone.text.trim(), full: _full.text.trim());
    } else {
      store.add(label: _label.text.trim(), recipient: _recipient.text.trim(), phone: _phone.text.trim(), full: _full.text.trim(), makeDefault: _makeDefault);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(height: 4, width: 40, decoration: BoxDecoration(color: GysColors.neutral200, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text(isEdit ? 'Ubah Alamat' : 'Tambah Alamat', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _field('Label (mis. Kantor, Gudang)', _label),
          const SizedBox(height: 12),
          _field('Nama Penerima', _recipient),
          const SizedBox(height: 12),
          _field('Nomor Telepon', _phone, keyboard: TextInputType.phone),
          const SizedBox(height: 12),
          _field('Alamat Lengkap', _full, maxLines: 3),
          if (!isEdit) ...[
            const SizedBox(height: 4),
            CheckboxListTile(
              value: _makeDefault,
              onChanged: (v) => setState(() => _makeDefault = v ?? false),
              activeColor: GysColors.brand500,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Jadikan alamat utama', style: TextStyle(fontSize: 14)),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: Text(isEdit ? 'Simpan Perubahan' : 'Simpan Alamat'))),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {int maxLines = 1, TextInputType? keyboard}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GysColors.neutral700)),
        const SizedBox(height: 6),
        TextField(controller: c, maxLines: maxLines, keyboardType: keyboard),
      ],
    );
  }
}
