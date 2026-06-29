import 'package:flutter/material.dart';
import 'package:ombor_hisobot/models/models.dart';
import 'package:ombor_hisobot/services/firebase_service.dart';
import 'package:ombor_hisobot/utils/theme.dart';

class MijozlarScreen extends StatefulWidget {
  const MijozlarScreen({super.key});

  @override
  State<MijozlarScreen> createState() => _MijozlarScreenState();
}

class _MijozlarScreenState extends State<MijozlarScreen> {
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
                    hintText: 'Mijoz nomi, email yoki telefon...',
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
          child: StreamBuilder<List<Mijoz>>(
            stream: FirebaseService.getMijozlar(),
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
                          m.telefon.contains(_query) ||
                          m.email.toLowerCase().contains(_query))
                      .toList();
              if (filtered.isEmpty) {
                return const Center(
                    child: Text("Mijoz topilmadi",
                        style: TextStyle(color: AppColors.textSecondary)));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final m = filtered[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(m.nomi[0],
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700)),
                      ),
                      title: Text(m.nomi,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle:
                          Text(m.telefon, style: const TextStyle(fontSize: 13)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: m.faol
                                  ? AppColors.accent.withOpacity(0.1)
                                  : AppColors.danger.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(m.faol ? 'Faol' : 'Nofaol',
                                style: TextStyle(
                                    color: m.faol
                                        ? AppColors.accent
                                        : AppColors.danger,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ),
                          IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  size: 18, color: AppColors.textSecondary),
                              onPressed: () => _showForm(context, m)),
                          IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 18, color: AppColors.danger),
                              onPressed: () => _confirmDelete(context, m)),
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

  void _showForm(BuildContext context, Mijoz? mijoz) {
    final nomi = TextEditingController(text: mijoz?.nomi);
    final telefon = TextEditingController(text: mijoz?.telefon);
    final email = TextEditingController(text: mijoz?.email);
    final shahar = TextEditingController(text: mijoz?.shahar);
    bool faol = mijoz?.faol ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(mijoz == null ? "Mijoz qo'shish" : "Mijozni tahrirlash",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                  controller: nomi,
                  decoration: const InputDecoration(labelText: 'Mijoz nomi *')),
              const SizedBox(height: 12),
              TextField(
                  controller: telefon,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Telefon *')),
              const SizedBox(height: 12),
              TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 12),
              TextField(
                  controller: shahar,
                  decoration: const InputDecoration(labelText: 'Shahar')),
              const SizedBox(height: 12),
              SwitchListTile(
                value: faol,
                onChanged: (v) => setS(() => faol = v),
                title: const Text('Faol holat'),
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.accent,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (nomi.text.isEmpty || telefon.text.isEmpty) return;
                  final m = Mijoz(
                    id: mijoz?.id ?? '',
                    nomi: nomi.text.trim(),
                    telefon: telefon.text.trim(),
                    email: email.text.trim(),
                    shahar: shahar.text.trim(),
                    faol: faol,
                    yaratilganSana: mijoz?.yaratilganSana ?? DateTime.now(),
                  );
                  if (mijoz == null) {
                    await FirebaseService.addMijoz(m);
                  } else {
                    await FirebaseService.updateMijoz(m);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(mijoz == null ? "Saqlash" : "Yangilash"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Mijoz m) {
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
              await FirebaseService.deleteMijoz(m.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("O'chirish"),
          ),
        ],
      ),
    );
  }
}
