import 'package:flutter/material.dart';
import 'package:ombor_hisobot/models/models.dart';
import 'package:ombor_hisobot/services/firebase_service.dart';
import 'package:ombor_hisobot/utils/theme.dart';

class KategoriyalarScreen extends StatelessWidget {
  const KategoriyalarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showForm(context, null),
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Kategoriya qo'shish"),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Kategoriya>>(
            stream: FirebaseService.getKategoriyalar(),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snap.data ?? [];
              if (items.isEmpty) {
                return const Center(
                    child: Text("Kategoriya yo'q",
                        style: TextStyle(color: AppColors.textSecondary)));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (ctx, i) {
                  final k = items[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.category_outlined,
                            color: AppColors.primary, size: 20),
                      ),
                      title: Text(k.nomi,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${k.mahsulotlarSoni} ta mahsulot',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(Fmt.date(k.yaratilganSana),
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
                          IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  size: 18, color: AppColors.textSecondary),
                              onPressed: () => _showForm(context, k)),
                          IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 18, color: AppColors.danger),
                              onPressed: () => _confirmDelete(context, k)),
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

  void _showForm(BuildContext context, Kategoriya? kat) {
    final ctrl = TextEditingController(text: kat?.nomi);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
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
                kat == null ? "Kategoriya qo'shish" : "Kategoriyani tahrirlash",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
                controller: ctrl,
                decoration:
                    const InputDecoration(labelText: 'Kategoriya nomi *')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (ctrl.text.isEmpty) return;
                final k = Kategoriya(
                    id: kat?.id ?? '',
                    nomi: ctrl.text.trim(),
                    yaratilganSana: kat?.yaratilganSana ?? DateTime.now());
                if (kat == null) {
                  await FirebaseService.addKategoriya(k);
                } else {
                  await FirebaseService.updateKategoriya(k);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(kat == null ? "Saqlash" : "Yangilash"),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Kategoriya k) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("O'chirish"),
        content: Text("${k.nomi} ni o'chirmoqchimisiz?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Bekor qilish")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              await FirebaseService.deleteKategoriya(k.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("O'chirish"),
          ),
        ],
      ),
    );
  }
}
