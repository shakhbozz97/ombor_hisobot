import 'package:flutter/material.dart';
import 'package:ombor_hisobot/models/models.dart';
import 'package:ombor_hisobot/services/firebase_service.dart';
import 'package:ombor_hisobot/utils/theme.dart';

class FoydalanuvchilarScreen extends StatelessWidget {
  const FoydalanuvchilarScreen({super.key});

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
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text("Foydalanuvchi yaratish"),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<AppUser>>(
            stream: FirebaseService.getFoydalanuvchilar(),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snap.data ?? [];
              if (items.isEmpty) {
                return const Center(
                    child: Text("Foydalanuvchi yo'q",
                        style: TextStyle(color: AppColors.textSecondary)));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (ctx, i) {
                  final u = items[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                            u.ismFamilya.isNotEmpty ? u.ismFamilya[0] : 'U',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                      title: Text(u.ismFamilya,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u.login, style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(u.rol,
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: u.faol,
                            onChanged: (v) async {
                              final updated = AppUser(
                                  id: u.id,
                                  login: u.login,
                                  ismFamilya: u.ismFamilya,
                                  rol: u.rol,
                                  faol: v,
                                  yaratilganSana: u.yaratilganSana);
                              await FirebaseService.updateFoydalanuvchi(
                                  updated);
                            },
                            activeThumbColor: AppColors.accent,
                          ),
                          IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  size: 18, color: AppColors.textSecondary),
                              onPressed: () => _showForm(context, u)),
                          IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 18, color: AppColors.danger),
                              onPressed: () => _confirmDelete(context, u)),
                        ],
                      ),
                      isThreeLine: true,
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

  void _showForm(BuildContext context, AppUser? user) {
    final login = TextEditingController(text: user?.login);
    final ismFamilya = TextEditingController(text: user?.ismFamilya);
    String selectedRol = user?.rol ?? 'Xodim';
    final roles = ['Admin', 'Menejer', 'Xodim'];

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
              Text(user == null ? "Foydalanuvchi yaratish" : "Tahrirlash",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                  controller: ismFamilya,
                  decoration:
                      const InputDecoration(labelText: 'Ism Familya *')),
              const SizedBox(height: 12),
              TextField(
                  controller: login,
                  decoration: const InputDecoration(labelText: 'Login *')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedRol,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: roles
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setS(() => selectedRol = v ?? 'Xodim'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (login.text.isEmpty || ismFamilya.text.isEmpty) return;
                  final u = AppUser(
                    id: user?.id ?? '',
                    login: login.text.trim(),
                    ismFamilya: ismFamilya.text.trim(),
                    rol: selectedRol,
                    faol: user?.faol ?? true,
                    yaratilganSana: user?.yaratilganSana ?? DateTime.now(),
                  );
                  if (user == null) {
                    await FirebaseService.addFoydalanuvchi(u);
                  } else {
                    await FirebaseService.updateFoydalanuvchi(u);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(user == null ? "Saqlash" : "Yangilash"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppUser u) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("O'chirish"),
        content: Text("${u.ismFamilya} ni o'chirmoqchimisiz?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Bekor qilish")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              await FirebaseService.deleteFoydalanuvchi(u.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("O'chirish"),
          ),
        ],
      ),
    );
  }
}
