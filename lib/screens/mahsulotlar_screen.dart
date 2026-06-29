import 'package:flutter/material.dart';
import 'package:ombor_hisobot/models/models.dart';
import 'package:ombor_hisobot/services/firebase_service.dart';
import 'package:ombor_hisobot/utils/theme.dart';

class MahsulotlarScreen extends StatefulWidget {
  const MahsulotlarScreen({super.key});

  @override
  State<MahsulotlarScreen> createState() => _MahsulotlarScreenState();
}

class _MahsulotlarScreenState extends State<MahsulotlarScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: 'Mahsulot nomi yoki kategoriya...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _search.clear();
                              setState(() => _query = '');
                            })
                        : null,
                  ),
                  onChanged: (v) => setState(() => _query = v.toLowerCase()),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => _showForm(context, null),
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Qo'shish"),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Mahsulot>>(
            stream: FirebaseService.getMahsulotlar(),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final all = snap.data ?? [];
              final filtered = _query.isEmpty
                  ? all
                  : all
                      .where((m) =>
                          m.nomi.toLowerCase().contains(_query) ||
                          m.kategoriya.toLowerCase().contains(_query))
                      .toList();
              if (filtered.isEmpty) {
                return const Center(
                    child: Text("Mahsulot topilmadi",
                        style: TextStyle(color: AppColors.textSecondary)));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final m = filtered[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.nomi,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                const SizedBox(height: 2),
                                Text(m.kategoriya,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    _InfoChip(
                                        label:
                                            'Tannarx: ${Fmt.money(m.tannarx)}'),
                                    const SizedBox(width: 6),
                                    _InfoChip(
                                        label: 'Narx: ${Fmt.money(m.narx)}'),
                                    const SizedBox(width: 6),
                                    _InfoChip(label: m.birlik),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: m.miqdor < 0
                                      ? AppColors.danger.withOpacity(0.1)
                                      : m.miqdor == 0
                                          ? Colors.orange.withOpacity(0.1)
                                          : AppColors.accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('${m.miqdor}',
                                    style: TextStyle(
                                      color: m.miqdor < 0
                                          ? AppColors.danger
                                          : m.miqdor == 0
                                              ? Colors.orange
                                              : AppColors.accent,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    )),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                      icon: const Icon(Icons.edit_outlined,
                                          size: 18,
                                          color: AppColors.textSecondary),
                                      onPressed: () => _showForm(context, m)),
                                  IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          size: 18, color: AppColors.danger),
                                      onPressed: () =>
                                          _confirmDelete(context, m)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showForm(BuildContext context, Mahsulot? mahsulot) {
    final nomi = TextEditingController(text: mahsulot?.nomi);
    final birlik = TextEditingController(text: mahsulot?.birlik);
    final tannarx =
        TextEditingController(text: mahsulot?.tannarx.toStringAsFixed(0));
    final narx = TextEditingController(text: mahsulot?.narx.toStringAsFixed(0));
    final miqdor = TextEditingController(text: mahsulot?.miqdor.toString());
    String? selectedKatId = mahsulot?.kategoriyaId;
    String? selectedKatNomi = mahsulot?.kategoriya;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => SingleChildScrollView(
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                  mahsulot == null
                      ? "Mahsulot qo'shish"
                      : "Mahsulotni tahrirlash",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                  controller: nomi,
                  decoration:
                      const InputDecoration(labelText: 'Mahsulot nomi *')),
              const SizedBox(height: 12),
              // Kategoriya dropdown
              StreamBuilder<List<Kategoriya>>(
                stream: FirebaseService.getKategoriyalar(),
                builder: (ctx, snap) {
                  final kats = snap.data ?? [];
                  return DropdownButtonFormField<String>(
                    initialValue: selectedKatId,
                    decoration:
                        const InputDecoration(labelText: 'Kategoriya *'),
                    items: kats
                        .map((k) =>
                            DropdownMenuItem(value: k.id, child: Text(k.nomi)))
                        .toList(),
                    onChanged: (v) {
                      selectedKatId = v;
                      selectedKatNomi = kats.firstWhere((k) => k.id == v).nomi;
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              TextField(
                  controller: birlik,
                  decoration: const InputDecoration(
                      labelText: 'Birlik (kilo, dona, pochka...)')),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                          controller: tannarx,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Tannarx *'))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: TextField(
                          controller: narx,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Narx *'))),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                  controller: miqdor,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Miqdor *')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (nomi.text.isEmpty || selectedKatId == null) return;
                  final m = Mahsulot(
                    id: mahsulot?.id ?? '',
                    nomi: nomi.text.trim(),
                    kategoriya: selectedKatNomi ?? '',
                    kategoriyaId: selectedKatId ?? '',
                    birlik: birlik.text.trim(),
                    tannarx: double.tryParse(tannarx.text) ?? 0,
                    narx: double.tryParse(narx.text) ?? 0,
                    miqdor: int.tryParse(miqdor.text) ?? 0,
                  );
                  if (mahsulot == null) {
                    await FirebaseService.addMahsulot(m);
                  } else {
                    await FirebaseService.updateMahsulot(m);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(mahsulot == null ? "Saqlash" : "Yangilash"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Mahsulot m) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("O'chirish"),
        content: Text("${m.nomi} ni o'chirmoqchimisiz?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Bekor qilish")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              await FirebaseService.deleteMahsulot(m.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("O'chirish"),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: AppColors.background, borderRadius: BorderRadius.circular(4)),
      child: Text(label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
    );
  }
}
